require "point"
require "Color"
pixel = {}
pixel.mt = {}
pixel.pixelMap = {{}}
pixel.pixels = {}
pixel.pixelID = 0

pixel.__index = pixel

function pixel.movePixels()
	
	for k, pxl in pairs(pixel.pixels) do
	
		if not (pxl == nil) then
		
		
	end

end

function pixel.mt:getPixel(img, pPos)
	
	local foundPixel = false
	mapPos = point(math.floor(pPos.x), math.floor(pPos.y))
	
	if pixel.pixelMap[mapPos.y] == nil then
		pixel.pixelMap[mapPos.y] = {}
	end
	
	if not (pixel.pixelMap[mapPos.y][mapPos.x] == nil) then
		foundPixel = true
	end
	
	if foundPixel then
		return pixel.pixels[pixel.pixelMap[mapPos.y][mapPos.x]]
	else
		return pixel(img, pPos, point(0,0), true)
	end

end

function pixel.mt:__call(img, pos, vel, createPixel) 
	
	local pxl = {}
	--local createPixel = false
	
	if not createPixel then 
		
		mapPos = point(math.floor(pxl.pos.x), math.floor(pxl.pos.y))
		
		if pixel.pixelMap[mapPos.y] == nil then
			pixel.pixelMap[mapPos.y] = {}
		end
		
		if pixel.pixelMap[mapPos.y][mapPos.x] == nil then
			createPixel = true
		else
			pxl = pixel.pixels[pixel.pixelMap[mapPos.y][mapPos.x]]
			if pxl == nil then
				createPixel = true
			end
		end
		
	end

	if createPixel then
		setmetatable(pxl, pixel)
		pxl.pos = pos
		pxl.vel = vel
		r,g,b,a = img:getData():getPixel(pos.x,pos.y)
		pxl.clr = Color(r,g,b,a)
		pxl.img = img
		pxl.lastSim = love.timer.getTime()
		pxl.id = pixel.pixelID
		pixel.pixelID = pixel.pixelID + 1
		pixel.pixels[pxl.id] = pxl
	end
	
	return pxl

end



function pixel:move()
	
	imgData = self.img:getData()
	simDelta = love.timer.getTime() - self.lastSim
	
	imgData:setPixel(self.x, self.y, 0, 0, 0, 0)
	
	newPos = self.pos + (self.vel * simDelta)
	
	if (imgData:getPixel(newPos.x, newPos.y).a != 0) then
		
		self:resolveCollision(newPos)
		
	end
	
	
	imgData:setPixel(self.x, self.y, self.clr.r, self.clr.g, self.clr.b, self.clr.a)
	
	self.img:refresh()
	
end

function pixel:resolveCollision(cPos)
	
	local pxl2 = pixel.getPixel(cPos)
	local normal = point(pxl2.pos.x - self.pos.x, pxl2.pos.y - self.pos.y):normalize()
    local a1 = self.vel.dot(normal)
    local a2 = pxl2.vel.dot(normal)
    local p = (2 * (a1 - a2)) / (2)
    local v1 = ent1.vel:copy()
        
	v1.x = v1.x - p * pxl2.mass * normal.x
    v1.y = v1.y - p * pxl2.mass * normal.y
    local v2 = pxl2.vel:copy()
    v2.x = v2.x + p * self.mass * normal.x
    v2.y = v2.y + p * self.mass * normal.y
        
    self.vel = v1
    pxl2.vel = v2

end

function pixel:__tostring()
	
	return "( " .. tostring(self.x) .. ", " .. tostring(self.y) .. " )"
	
end

setmetatable(pixel, pixel.mt)

