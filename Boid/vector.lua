local m = {}
m.__index = m

function m.new(x, y)
	local new = {x = x, y = y}
	setmetatable(new, m)
	return new
end

function m:assign(vector)
	self.x = vector.x
	self.y = vector.y
end

function m:copy()
	return m.new(self.x, self.y)
end

function m:length()
	return math.sqrt((self.x^2) + (self.y^2))
end

function m:normalize(d)
	local l = self:length()
	l = d/l
	self.x = self.x*l
	self.y = self.y*l
	l = nil
end

function m:angle()
	return math.atan2(y, x)
end

function m:rotate(angle)
	local l = self:length()
	self.x = l*math.cos(angle)
	self.y = l*math.sin(angle)
end
function m:scale(value)
	if isnum(value) then
		self:normalize(self:length()*value)
	end
end

return m
