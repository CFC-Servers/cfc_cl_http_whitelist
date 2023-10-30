CFCHTTP.Net = CFCHTTP.Net or {}

function CFCHTTP.newRateLimitBucket( capacity, rate )
    local bucket = {
        capacity = capacity,
        rate = rate,
        tokens = capacity,
        last = SysTime()
    }

    function bucket:consume( amount )
        local now = SysTime()
        local delta = now - self.last

        self.last = now
        self.tokens = math.min( self.tokens + delta * self.rate, self.capacity )

        if self.tokens < amount then
            return false
        end

        self.tokens = self.tokens - amount
        return true
    end

    return bucket
end

function CFCHTTP.Net.receiveWithMiddleware( name, cb, ... )
    for _, v in pairs( { ... } ) do
        cb = v( cb )
    end

    net.Receive( name, cb )
end

CFCHTTP.Net._rateLimitBuckets = CFCHTTP.Net._rateLimitBuckets or {}

function CFCHTTP.Net.rateLimit( name, capacity, rate )
    return function( cb )
        return function( n, ply )
            if not IsValid( ply ) then return end

            local identifier = ply:SteamID() .. name
            local bucket = CFCHTTP.Net._rateLimitBuckets[identifier]
            if not bucket then
                bucket = CFCHTTP.newRateLimitBucket( capacity, rate )
                CFCHTTP.Net._rateLimitBuckets[identifier] = bucket
                ply:CallOnRemove( identifier .. "_cleanup", function()
                    CFCHTTP.Net._rateLimitBuckets[identifier] = nil
                end )
            end

            if not bucket:consume( 1 ) then
                -- print( "CFCHTTP: Rate limit exceeded for " .. name .. " from " .. ply:Nick() )
                -- TODO add system to print rate limit violaters while not allowing console spamming
                return
            end
            cb( n, ply )
        end
    end
end

function CFCHTTP.Net.requirePermission( perm )
    return function( cb )
        return function( n, ply )
            if not CAMI then
                if not ply:IsSuperAdmin() then return end
                return cb( n, ply )
            end

            CAMI.PlayerHasAccess( ply, perm, function( b )
                if not b then return end
                cb( n, ply )
            end )
        end
    end
end

