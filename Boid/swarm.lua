swarm = {}
swarm.__index = swarm

swarms = {}

function swarm.new()
	local new = {}
	setmetatable(new, swarm)
	table.insert(swarms, new)
	return new
end

function swarm:add(Boid)
	table.insert(self, Boid)
	Boid.alone = false
	Boid.group = self
end

function swarm:enum(handler)
	for k, v in ipairs(self) do
		handler(k, v)
	end
end

function swarm:disband()
	for k, v in ipairs(self) do
		v.alone = true
	end
end 

function swarm:join()
	for k, v in ipairs(self) do
		v.alone = false 
	end
end
