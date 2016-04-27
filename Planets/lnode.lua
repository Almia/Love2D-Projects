local lnode = {}
lnode.__index = lnode

function lnode.new(val)
  return setmetatable({value = val}, lnode)
end

function lnode:nxt(nxtn)
  self.next = nxtn
  nxtn.prev = self
end

function lnode:prv(prvn)
  prvn:next(self)
end

return lnode
