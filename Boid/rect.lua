rect = {}
rect.__index = rect

function rect.new(x1, y1, x2, y2)
	local new = {min = {x = x1, y = y1}, max = {x = x2, y = y2}, center = {x = (x2 - x1)/2, y = (y2 - y1)/2}}
	setmetatable(new, rect)
	return new
end

function rect:hasX(x)
	return x > self.min.x and x < self.max.x
end

function rect:hasY(y)
	return y > self.min.y and y < self.max.y
end

function rect:has(x, y)
	return self:hasX(x) and self:hasY(y)
end


function rect:boundX(x)
	if x < self.min.x then
		return self.min.x
	elseif x > self.max.x then
		return self.max.x
	end
	return x
end

function rect:boundY(y)
	if y < self.min.y then
		return self.min.y
	elseif y > self.max.y then
		return self.max.y
	end
	return y
end

local function infinite(v, minv, maxv)
	if v <= minv then
		return maxv - (v - minv)
	elseif v >= maxv then
		return (maxv - v) + minv
	end
	return v
end

function rect:warpX(x)
	return infinite(x, self.min.x, self.max.x)
end

function rect:warpY(y)
	return infinite(y, self.min.y, self.max.y)
end

function rect:warp(x, y)
	return self:warpX(x), self:warpY(y)
end

function rect:move(x1, y1, x2, y2)
	self.min.x = x1
	self.min.y = y1
	self.max.x = x2
	self.max.y = y2
	self.center.x = (x2 - x1)/2
	self.center.y = (y2 - y1)/2
end

function rect:moveCenter(x, y)
	local dx = self.center.x - self.min.x
	local dy = self.center.y - self.min.y
	self.center.x = x
	self.center.y = y
	self.min.x = x - dx
	self.min.y = y - dy
	self.max.x = x + dx
	self.max.y = y + dy 
end
	
