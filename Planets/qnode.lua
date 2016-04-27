local qnode = {}
qnode.__index = qnode

function qnode.new(val)
  return setmetatable({value = val}, qnode)
end

function qnode:n(nq)
  self.north = nq
  nq.south  = self
end

function qnode:s(sq)
  sq:n(self)
end

function qnode:e(eq)
  self.east = eq
  eq.west = self
end

function qnode:w(wq)
  wq:e(self)
end

return qnode
