local vector = require "vector"
local wander = require "wander"
require "rect"
require "swarm"
boid = {}

boid.__index = boid
boids = {}

local cos = math.cos
local sin = math.sin
local atan2 = math.atan2

function boid.load()
	boid.boundless = true
	boid.world = rect.new(0, 0, 4096, 4096)
	boid.median = 8
	boid.neighborRadius = 256
	boid.collision = 32
	boid.cohesion = 0.01
	boid.seperation = 1
	boid.alignment = 0.1
	boid.view = 130*math.pi/180
end

function boid.getNearest(x, y)
	local d = 2147483647
	local record
	for k, v in ipairs(boids) do
		local d2 = (v.x - x)^2 + (v.y - y)^2
		if d2 <= d then
			d = d2
			record = v
		end
	end
	d = nil
	return record
end

local function angleInAngles(a, min, max)
	local d = max - min
	a = a - min
	return a < d and a > 0
end

function boid.new(x, y, velocity, facing)
	local new = {   x = x, y = y, 
					velocity = vector.new(velocity*cos(facing), sin(velocity*facing)), 
					speed = velocity, 
					facing = facing, 
					alone = true,
					wander = wander.new(facing, boid.view, math.pi)}
	setmetatable(new, boid)
	table.insert(boids, new)
	return new
end

function boid:update(dt)
	local tempAlone = false
	if not self.alone and type(self.group) == "table" then
		local ax, ay = 0., 0.
		local cx, cy = 0., 0.
		local sx, sy = 0.,0.
		local c = 0.
		local s = 0.
		for k, v in ipairs(self.group) do
			if v ~= self then
				local a = atan2(v.y - self.y, v.x - self.x )
				local d = ((v.x - self.x)^2) + ((v.y - self.y)^2)
				if  d <= boid.neighborRadius^2 and angleInAngles(a, self.facing - boid.view, self.facing + boid.view) then
					cx = cx + v.x
					cy = cy + v.y
					ax = ax + v.velocity.x 
					ay = ay + v.velocity.y
					if d <= (boid.collision^2)*2 then
						sx = sx + v.x - self.x
						sy = sy + v.y - self.y
						s = s + 1
					end
					c = c + 1
				end
				a, d = nil
			end
		end
		if c > 0 then
			ax = ax/c
			ay = ay/c
			cx = cx/c - self.x
			cy = cy/c - self.y
			if s > 0 then
				sx = -sx/s
				sy = -sy/s
			end
		
			self.velocity.x = self.velocity.x + ax*boid.alignment + cx*boid.cohesion + sx*boid.seperation
			self.velocity.y = self.velocity.y + ay*boid.alignment + cy*boid.cohesion + sy*boid.seperation
					
			self.velocity:normalize(self.speed)
		else
			tempAlone = true
		end
		ax, ay, cx, cy, sx, sy, c, s = nil, nil, nil, nil, nil, nil, nil, nil
	end
	if self.alone or tempAlone then
		self.wander:adjust(self.facing)
		local a = self.wander:getNext(dt)
		self.velocity.x = cos(a)
		self.velocity.y = sin(a)
		self.velocity:normalize(self.speed)
		a = nil
	end	
	
	if boid.boundless then 
		self.x = self.x + self.velocity.x*dt
		self.y = self.y + self.velocity.y*dt
		if not boid.world:hasX(self.x) then
			self.x = boid.world:boundX(boid.world:warpX(self.x))
		end
		if not boid.world:hasY(self.y) then
			self.y = boid.world:boundY(boid.world:warpY(self.y))
		end
	else 
		if not boid.world:hasX(self.x + self.velocity.x*dt) then
			self.velocity.x = -self.velocity.x
		end
		if not boid.world:hasY(self.y + self.velocity.y*dt) then
			self.velocity.y = -self.velocity.y
		end
		self.x = self.x + self.velocity.x*dt
		self.y = self.y + self.velocity.y*dt
	end
	self.facing = atan2(self.velocity.y, self.velocity.x)
	if self.alone then
		self.wander:adjust(self.facing)
	end
end

function boid.updateAll(dt)
	for k, v in ipairs(boids) do
		v:update(dt)
	end
end

function boid:draw(r, g, b, a)
	love.graphics.setColor(r, g, b, a)
	local x3 = self.x + boid.median*2*math.cos(self.facing)
	local y3 = self.y + boid.median*2*math.sin(self.facing)
	local x2 = self.x + boid.median*math.cos(self.facing + (120*math.pi/180))
	local y2 = self.y + boid.median*math.sin(self.facing + (120*math.pi/180))
	local x1 = self.x + boid.median*math.cos(self.facing - (120*math.pi/180))
	local y1 = self.y + boid.median*math.sin(self.facing - (120*math.pi/180))
	love.graphics.polygon("fill", {x1, y1, x2, y2, x3, y3})
	love.graphics.setColor(r, g, b)
	love.graphics.polygon("line", {x1, y1, x2, y2, x3, y3})
	x3, x3, x2, x2, x1, x1 = nil, nil, nil, nil, nil, nil
end

function boid:disband()
	self.alone = false
	self.wander:adjust(self.facing)
end

function boid:join()
	self.alone = true
	self.wander:adjust(self.facing)
end
