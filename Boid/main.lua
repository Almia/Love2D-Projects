require "boid"
require "rect"
require "swarm"

function love.load()
	--love.window.setFullscreen(true)
	if love.system.getOS() ~= "Android" then 
		love.window.setTitle("Boid Simulation v1.3")
		love.window.setMode(1024, 730, {resizable=false, vsync=false, borderless = true})
		love.window.setPosition(171, 0)
	else
		love.mouse.getX = function ()
			local index, x = love.touch.getTouch(1)
			return x*love.window.getWidth()
		end
		love.mouse.getY = function ()
			local index, x, y = love.touch.getTouch(1)
			return y*love.window.getHeight()
		end
	end
	camera = {}
	camera.minX = 0
	camera.minY = 0
	camera.maxX = love.window.getWidth()
	camera.maxY = love.window.getHeight()
	camera.centerX = camera.maxX/2
	camera.centerY = camera.maxY/2
	boid.load()
	grabbed = false
	drag = false
	smooth = true
	gridsize = 128
	disband = false
	factor = 1.
	show_console = true
	math.randomseed(os.time())
	canvas = love.graphics.newCanvas(love.window.getWidth(), love.window.getHeight())
	flock = swarm.new()
	--d = boid.new(math.random(boid.world.min.x, boid.world.max.x), math.random(boid.world.min.y, boid.world.max.y), 500, math.random(-math.pi, math.pi))
	--flock:add(d)

end
local function normalizeToGrid(v)
	if v % gridsize ~= 0 then
		return normalizeToGrid(v - (v%gridsize))
	end
	return v
end

local function drawGrid(minx, miny, maxx, maxy)
	MinX, MinY, MaxX, MaxY = minx, miny, maxx, maxy
	minx = normalizeToGrid(minx)
	maxx = normalizeToGrid(maxx)
	miny = normalizeToGrid(miny)
	maxy = normalizeToGrid(maxy)
	while(minx < maxx) do
		love.graphics.line(minx, MinY, minx, MaxY)
		minx = minx + gridsize
	end
	while(miny < maxy) do
		love.graphics.line(MinX, miny, MaxX, miny)
		miny = miny + gridsize
	end
end

function love.draw()
	--[[love.graphics.setBackgroundColor(0, 0, 0)
	love.graphics.push()
	love.graphics.scale(factor, factor)
	love.graphics.push()
	love.graphics.translate(-camera.minX, -camera.minY)
	love.graphics.setColor(50, 50, 255, 100)
	love.graphics.polygon("fill", { boid.world.min.x, boid.world.min.y,
									boid.world.min.x, boid.world.max.y,
									boid.world.max.x, boid.world.max.y,
									boid.world.max.x, boid.world.min.y})
	love.graphics.setColor(50, 50, 255)
	love.graphics.polygon("line", { boid.world.min.x, boid.world.min.y,
									boid.world.min.x, boid.world.max.y,
									boid.world.max.x, boid.world.max.y,
									boid.world.max.x, boid.world.min.y})
	
	drawGrid(boid.world.min.x, boid.world.min.y, boid.world.max.x, boid.world.max.y)
	
	for k, v in ipairs(boids) do
		if v ~= follow then
			v:draw(0, 255, 0,100)
		end
	end
	
	if grabbed then
		follow:draw(255, 255, 255)
	end
	love.graphics.pop()
	love.graphics.pop()
	
	
	
	]]--
	
	love.graphics.draw(canvas)
	if show_console then
		if love.system.getOS() ~= "Android" then
			love.graphics.setColor(255, 255, 255, 100)
			love.graphics.rectangle("fill",5, 5, 370, 245)
			love.graphics.setColor(255, 255, 255)
			love.graphics.rectangle("line",5, 5, 370, 245)
		else
			love.graphics.setColor(255, 255, 255, 100)
			love.graphics.rectangle("fill",5, 5, 370, 95)
			love.graphics.setColor(255, 255, 255)
			love.graphics.rectangle("line",5, 5, 370, 95)
		end
		love.graphics.print("Boid Sim v1.4", 15, 15)
		love.graphics.print("Camera Position : ( "..math.floor(camera.centerX)..", "..math.floor(camera.centerY).." )", 15, 30)
		love.graphics.print("FPS : "..love.timer.getFPS(), 15, 45)
		if love.system.getOS() ~= "Android" then
			love.graphics.print("WASD or LMB to drag/move camera", 15, 60)
			love.graphics.print("LMB to grab/ungrab boids", 15, 75)
			love.graphics.print("RMB - Hold then click LMB to add Boids", 15, 90)
			love.graphics.print("Z - Smooth Camera ON or OFF (Status : "..tostring(smooth).." )", 15, 105)
			love.graphics.print("X - Toggle Map to Bounded/Boundless (Status : "..tostring(boid.boundless)..")", 15, 120)
			love.graphics.print("C - Join or Disband Boids", 15, 135)
			love.graphics.print("Q - Zoom In", 15, 150)
			love.graphics.print("E - Zoom Out", 15, 165)
			love.graphics.print("Zoom Factor : "..tostring(factor * 100).."%", 15, 180)
			love.graphics.print("F - Show/Hide Console", 15, 195)
			love.graphics.print("Boid Count : "..#flock, 15, 210)
			love.graphics.print("Press ESC to quit", 15, 225)
			love.graphics.circle("line", love.mouse.getX(), love.mouse.getY(), 16, 18)
		else
			love.graphics.print("Drag to move camera", 15, 60)
			love.graphics.print("Touch a boid to follow", 15, 75)
			if drag then
				love.graphics.circle("line", love.mouse.getX(), love.mouse.getY(), 32, 18)
			end
		end
	end
end

function love.mousepressed(x, y, button)
	x = boid.world:warpX(camera.minX + x/factor)
	y = boid.world:warpY(camera.minY + y/factor)
	if button == "l" then
		local b = boid.getNearest(x, y)
		if b then
			if (b.x - x)^2 + (b.y - y)^2 <= (32/factor)^2 then
				follow = b
				grabbed = true
			else
				grabbed = false
				if d == nil and #flock > 1 then
					d = boid.new(math.random(boid.world.min.x, boid.world.max.x), math.random(boid.world.min.y, boid.world.max.y), 500, math.random(-math.pi, math.pi))
					flock:add(d)
				end
				follow = d
			end
		end
		drag = true
		prevX = love.mouse.getX()
		prevY = love.mouse.getY()
	elseif button == "r" then
		flock:add(boid.new(x, y, 500, math.random(-math.pi, math.pi)))
	end
end 

function love.mousereleased(x, y, button)
	drag = false
end

function love.touchpressed(index, x, y)
	love.mousepressed(x*love.window.getWidth(), y*love.window.getHeight())
end

function love.touchreleased(id, x, y)
	love.mousereleased()
end

function love.keypressed(k)
	if love.system.getOS() ~= "Android" then
		if k == "z" then
			if factor <= 1 then 
				smooth = not smooth
			end
		elseif k == "x" then
			boid.boundless = not boid.boundless
		elseif k == "escape" then
			love.event.quit();
		elseif k == "c" then
			disband = not disband
			if disband then
				flock:disband()
			else
				flock:join()
			end
		elseif k == "q" then
			if factor < 5 then
				local f = factor
				if factor < 1. then 
					factor = factor + 0.1
				else
					factor = factor + 1
				end
				local dx = (camera.centerX - camera.minX)*(f/factor)
				local dy = (camera.centerY - camera.minY)*(f/factor)
				--camera.centerX = boid.world:boundX(camera.minX + dx)
				--camera.centerY = boid.world:boundY(camera.minY + dy)
				camera.minX = camera.centerX - dx
				camera.minY = camera.centerY - dy
				camera.maxX = camera.centerX + dx
				camera.maxY = camera.centerY + dy
				if factor == 2 then
					smooth = true
				end
			end
		elseif k == "e" then
			if factor > 0.2 then
				local f = factor
				if factor <= 1. then 
					factor = factor - 0.1
				else
					factor = factor - 1
				end
				local dx = (camera.centerX - camera.minX)*(f/factor)
				local dy = (camera.centerY - camera.minY)*(f/factor)
				--camera.centerX = boid.world:boundX(camera.minX + dx)
				--camera.centerY = boid.world:boundY(camera.minY + dy)
				camera.minX = camera.centerX - dx
				camera.minY = camera.centerY - dy
				camera.maxX = camera.centerX + dx
				camera.maxY = camera.centerY + dy
				if factor <= 1 then
					smooth = false
				end
			end
		elseif k == "f" then
			show_console = not show_console
		end
	elseif k == "escape" then
		love.event.quit();
	
	end
end

local function moveCameraByOffset(x, y)
	local dx = camera.maxX - camera.centerX
	local dy = camera.maxY - camera.centerY 
	camera.centerX = boid.world:boundX(camera.centerX + x*factor)
	camera.centerY = boid.world:boundY(camera.centerY + y*factor)
	camera.minX = camera.centerX - dx
	camera.maxX = camera.centerX + dx
	
	camera.minY =  camera.centerY - dy
	camera.maxY =  camera.centerY + dy
end

function love.update(dt)
	canvas:clear()
	canvas:renderTo(function()
	love.graphics.push()
	love.graphics.scale(factor, factor)
	love.graphics.push()
	love.graphics.translate(-camera.minX, -camera.minY)
	love.graphics.setColor(50, 50, 255, 100)
	love.graphics.polygon("fill", { boid.world.min.x, boid.world.min.y,
									boid.world.min.x, boid.world.max.y,
									boid.world.max.x, boid.world.max.y,
									boid.world.max.x, boid.world.min.y})
	love.graphics.setColor(50, 50, 255)
	love.graphics.polygon("line", { boid.world.min.x, boid.world.min.y,
									boid.world.min.x, boid.world.max.y,
									boid.world.max.x, boid.world.max.y,
									boid.world.max.x, boid.world.min.y})
	
	drawGrid(boid.world.min.x, boid.world.min.y, boid.world.max.x, boid.world.max.y)
	
	for k, v in ipairs(boids) do
		if v ~= follow and v.x < camera.maxX and v.y > camera.minY and v.x > camera.minX and v.y < camera.maxY then
			v:draw(0, 255, 0,100)
		end
	end
	
	if grabbed then
		follow:draw(255, 255, 255)
	end
	love.graphics.pop()
	love.graphics.pop()
	
	love.graphics.setColor(255, 255, 255)
	end)
	if grabbed then
		if smooth then
			local x = camera.centerX
			local y = camera.centerY
			local dx = (follow.x - x)
			local dy = (follow.y - y)
			local d = (math.sqrt(dx^2 + dy^2)*dt*2)*factor
			local a = math.atan2(dy, dx)
			moveCameraByOffset(d*math.cos(a), d*math.sin(a))
			x, y, dx, dy, d, a = nil, nil, nil, nil, nil, nil
		else
			local x = follow.x - camera.centerX 
			local y =  follow.y - camera.centerY
			moveCameraByOffset(x, y)
			x, y = nil, nil
		end 
	elseif love.keyboard.isDown("a") then
		moveCameraByOffset(-10/factor, 0)
	elseif love.keyboard.isDown("d") then
		moveCameraByOffset(10/factor, 0)
	elseif love.keyboard.isDown("s") then
		moveCameraByOffset(0, 10/factor)
	elseif love.keyboard.isDown("w") then
		moveCameraByOffset(0, -10/factor)
	elseif love.mouse.isDown("l") and drag then
		local x = love.mouse.getX()
		local y = love.mouse.getY()
		local d = math.sqrt((prevX - x)^2 + (prevY - y)^2)/factor
		local a = math.atan2( prevY - y, prevX - x)
		moveCameraByOffset(d*math.cos(a), d*math.sin(a))
		prevX = x
		prevY = y
		x, y, d, a = nil, nil, nil, nil
	
	end
	boid.updateAll(dt)
end
