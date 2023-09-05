---@class LimitedCache
---@field private data table<string, {key: string, value: any, created: number}>
---@field private queue table<number, {key: string, value: any, created: number}>
---@field private limit number
---@field private ttlSeconds number
---@field private first number
---@field private last number
local cacheIndex = {}

function cacheIndex:Set( key, value )
    self:groomQueue()

    local v = {
        key = key,
        value = value,
        created = os.time(),
    }

    self.data[key] = v
    self:pushRight( v )
end

function cacheIndex:Get( key )
    self:groomQueue()

    local v = self.data[key]
    if v then
        return v.value
    end
end

function cacheIndex:pushRight( value )
    local last = self.last + 1
    self.last = last
    self.queue[last] = value
end

function cacheIndex:groomQueue()
    local amountOverLimit = self.last - self.first - self.limit

    for i = self.first, self.last do
        local v = self.queue[i]
        if os.time() - v.created > self.ttlSeconds then
            self.queue[i] = nil
            self.data[v.key] = nil
            self.first = self.first + 1
            amountOverLimit = amountOverLimit - 1
        elseif amountOverLimit > 0 then
            self.queue[i] = nil
            self.data[v.key] = nil
            self.first = self.first + 1
            amountOverLimit = amountOverLimit - 1
        else
            break
        end
        amountOverLimit = amountOverLimit - 1
    end
end

---@param limit number
---@param ttlSeconds number
local function New( limit, ttlSeconds )
    limit = limit or 1000
    ttlSeconds = ttlSeconds or (60 * 60)
    return setmetatable( {
        data = {},
        queue = {},

        limit = limit,
        ttlSeconds = ttlSeconds,

        first = 0,
        last = -1,
    }, {
        __index = cacheIndex,
    } )
end

CFCHTTP = CFCHTTP or {}
CFCHTTP.LimitedCache = {
    New = New,
}
