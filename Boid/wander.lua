local wander = {}
wander.__index = wander

function wander.new(initial_angle, field_of_view, turning_rate)
	local new = {}
	new.fov = field_of_view/2.
	new.ca = initial_angle
	new.tr = turning_rate
	new.ta = math.random(new.ca - new.fov, new.ca + new.fov)
	if new.ta < new.ca then
		new.sig = -1.
	else
		new.sig = 1.
	end
	setmetatable(new, wander)
	return new
end

function wander:getNext(dt)
	self.ca = self.ca + self.sig*self.tr*dt
	local b = self.ca <= self.ta
	if self.sig == 1 then
		b = self.ca >= self.ta
	end
	if b then
		self.ta = math.random(self.ca - self.fov, self.ca + self.fov)
		if self.ta < self.ca then
			self.sig = -1.
		else
			self.sig = 1.
		end
	end
	return self.ca
end

function wander:adjust(new_angle)
	local a = new_angle - self.ca
	self.ta = self.ta + a
	self.ca = new_angle
end

return wander
