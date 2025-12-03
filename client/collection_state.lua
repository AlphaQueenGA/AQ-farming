local CollectState = {
  collecting = {} -- [locId][nodeKey] = true
}

function CollectState.makeNodeKey(pos, colId)
  return ('%s:%.2f:%.2f:%.2f'):format(colId, pos.x, pos.y, pos.z)
end

function CollectState.lock(locId, nodeKey)
  CollectState.collecting[locId] = CollectState.collecting[locId] or {}
  if CollectState.collecting[locId][nodeKey] then
    return false
  end
  CollectState.collecting[locId][nodeKey] = true
  return true
end

function CollectState.unlock(locId, nodeKey)
  if CollectState.collecting[locId] then
    CollectState.collecting[locId][nodeKey] = nil
  end
end

return CollectState