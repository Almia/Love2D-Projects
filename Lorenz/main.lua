
local lg, lw = love.graphics, love.window

local sin = math.sin
local rand = math.random

local w, h = 800, 600
local canv = lg.newCanvas(w, h)
local scale = 15.0

local counts = 2048
local shift = 0.001

local function generatePoints(count)
    local r = {}
    for i = 1, count do
        r[i] = {}
        local t = r[i]
        t.x, t.y, t.z = 2.0, 2.0, 2.0
    end
    return r
end

local base = {}

local function generateSRB(count)
    local r = {}
    local a, b, c = rand()*16 + 8, rand()*32 + 16, rand()*8 + 1
    base.a, base.b, base.c = a, b, c
    for i = 1, count do
        r[i] = {}
        local t = r[i]
        t.a, t.b, t.c = a + i*shift, b + i*shift, c
    end
    return r
end

local function generatePrevs(count)
    local r = {}
    for i = 1, count do
        r[i] = {}
        local t = r[i]
        t.px, t.py, t.pz = 0, 0, 0
    end
    return r
end

local function generateColors(count)
    local r = {}
    for i = 1, count do
        r[i] = {}
        local t = r[i]
        t.r, t.g, t.b = rand(), rand(), rand()
    end
    return r
end

    
local points = generatePoints(counts)
local srb = generateSRB(counts)
local p = generatePrevs(counts)

local sg = generateColors(1)
local eg = generateColors(1)

local t = 0.002
local timer = 0.0

local clear = false

function love.load()

    lw.setMode(w, h, {
        vsync = false,
        borderless = true,
    })
end

local function lerp(ta, tb, tt)
    return ta + (tb - ta)*tt
end

local function gradient(ar, ag, ab, br, bg, bb, tt)
    return lerp(ar, br, tt), lerp(ag, bg, tt), lerp(ab, bb, tt)
end

function love.update(dt)
    timer = timer + dt

    for i = 1, counts do 
        local pt = points[i]
        local x, y, z = pt.x, pt.y, pt.z
        local abc = srb[i]
        local a, b, c =  abc.a, abc.b, abc.c

        px, py, pz = x, y, z
        x = px + t * a * (py - px)
        y = py + t * (px * (b - pz) - py)
        z = pz + t * (px * py - c * pz)

        local prev = p[i]
        prev.px, prev.py, prev.pz = px, py, pz
        pt.x, pt.y, pt.z = x, y, z
    end

    canv:renderTo(function ()
        --if(clear) then
            lg.clear()
            clear = false
        --end
        local tmp = 0.5 + sin(timer)*0.5
    
        lg.setLineStyle("smooth")

        for i = 1, counts do 
            local color1 = sg[1]
            local r1, g1, b1 = color1.r, color1.g, color1.b
            local color2 = eg[1]
            local r2, g2, b2 = color2.r, color2.g, color2.b

            local tr, tg, tb = gradient(r1, g1, b1, r2, g2, b2, i/counts)
            lg.setColor(tr, tg, tb)
            local pt = points[i]
            local x, y, z = pt.x, pt.y, pt.z
            local prev = p[i]
            local px, py, pz = prev.px, prev.py, prev.pz
            --lg.line(w*0.5 + py*scale, pz*scale, w*0.5 + y*scale, z*scale)
            lg.circle("fill", w*0.5 + x*scale, h*0.5 + y*scale, scale/4)

        end
        love.graphics.print("S: "..base.a, 16, 16)
        love.graphics.print("R: "..base.b, 16, 32)
        love.graphics.print("B: "..base.c, 16, 48)
        love.graphics.print("Press Q to generate again", 16, 64)
        lg.setColor(255, 255, 255)
    end)
end

function love.draw(dt)
    lg.draw(canv)
end

function love.keypressed(k)
    if(k == "q") then 
        points = generatePoints(counts)
        srb = generateSRB(counts)
        p = generatePrevs(counts)
        
        sg = generateColors(1)
        eg = generateColors(1)

        timer = 0.0

        clear = true

    elseif(k == "escape") then
        love.event.quit()
    end
end
