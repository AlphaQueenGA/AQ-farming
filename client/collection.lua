local M = {}
local locks = {}

function M.lock(locId, nodeKey)
    locks[locId] = locks[locId] or {}
    if locks[locId][nodeKey] then return false end
    locks[locId][nodeKey] = true
    return true
end

function M.unlock(locId, nodeKey)
    if locks[locId] then locks[locId][nodeKey] = nil end
end

return M