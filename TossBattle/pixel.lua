require "point"
require "Color"
pixel = {}
pixel.mt = {}
pixel.pixelMap = {{}}
pixel.pixels = {}
pixel.pixelID = 0
pixel.minSimTime = 0.041
pixel.lastSimTime = love.timer.getTime()

pixel.__index = pixel

function pixel.putInMap(pxl)

	mapPos = point(math.floor(pxl.pos.x), math.floor(pxl.pos.y))

	if pixel.pixelMap[mapPos.y] == nil then
		pixel.pixelMap[mapPos.y] = {}
	end
	
	pixel.pixelMap[mapPos.y][mapPos.x] = pxl.id
	
end

function pixel.clearMapPos(pos)

	mapPos = point(math.floor(pos.x), math.floor(pos.y))
	
	if pixel.pixelMap[mapPos.y] == nil then
		pixel.pixelMap[mapPos.y] = {}
	end
	
	pixel.pixelMap[mapPos.y][mapPos.x] = nil
	
end

function pixel.getFromMap(pos)
	
	mapPos = point(math.floor(pos.x), math.floor(pos.y))
	
	if pixel.pixelMap[mapPos.y] == nil then
		pixel.pixelMap[mapPos.y] = {}
	end
	
	if (pixel.pixelMap[mapPos.y][mapPos.x] == nil) then
		return nil
	end
	
	return pixel.pixels[pixel.pixelMap[mapPos.y][mapPos.x]]
	
end

function pixel.movePixels()
	
	if love.timer.getTime() - pixel.lastSimTime > pixel.minSimTime then
		pixel.lastSimTime = love.timer.getTime()
		pixelCount = 0
		actualCount = 0
		for k, pxl in pairs(pixel.pixels) do
			pixelCount = pixelCount + 1
			if not (pxl == nil) then
				actualCount = actualCount + 1
				pxl:move()
			
			end
			
		end
		print("pixelCount: " .. tostring(pixelCount))
		print("actualCount: " .. tostring(actualCount))
	end
	
end


function pixel.mt:__call(img, pos, vel) 
	
	local pxl = {}
	
	existing = pixel.getFromMap(pos)
	
	if  existing == nil then
		setmetatable(pxl, pixel)
		pxl.pos = pos
		pxl.vel = vel
		r,g,b,a = img:getData():getPixel(pos.x,pos.y)
		if (a == 0) then
			return nil
		end
		pxl.clr = Color(r,g,b,a)
		pxl.img = img
		pxl.mass = math.random() * 5
		pxl.lastSim = love.timer.getTime()
		pxl.id = pixel.pixelID
		pixel.pixelID = pixel.pixelID + 1
		pixel.pixels[pxl.id] = pxl
		print(pxl.id)
		pixel.putInMap(pxl)
	end
	
	return pxl

end

function pixel:inImage(nPos)
	
	if nPos then
		if ((nPos.x >= 0) and (nPos.x <= (imgData:getWidth() - 1))) and
		   ((nPos.y >= 0) and (nPos.y <= (imgData:getHeight() - 1))) then
			return true
		end
	else
		if ((self.pos.x >= 0) and (self.pos.x <= (imgData:getWidth() - 1))) and
		   ((self.pos.y >= 0) and (self.pos.y <= (imgData:getHeight() - 1))) then
			return true
		end
	end
	
	return false

end

function pixel:move()
	
	--print(#pixel.pixels)
	imgData = self.img:getData()
	simDelta = love.timer.getTime() - self.lastSim
	
	pixel.clearMapPos(self.pos)
	newPos = self.pos + (self.vel * simDelta) + (point(0,9.8) * simDelta)
	
	if self:inImage() then
		
		
		
	end
	
	
	
	if self:inImage(newPos) then
			
			r,g,b,a  = imgData:getPixel(newPos.x, newPos.y)
			
			if not ( a == 0) then
				
				self:resolveCollision(newPos)
				--self.vel = self.vel * -0.99
				
				
			end
			
	end
	
	
	
	if self:inImage() then
		
		imgData:setPixel(self.pos.x, self.pos.y, 0, 0, 0, 0)
		
		imgData:setPixel(newPos.x, newPos.y, self.clr.r, self.clr.g, self.clr.b, self.clr.a)
		self.img:refresh()
		
	end
	
	self.pos = newPos
	
	
	self.lastSim = love.timer.getTime()
	if not ( self.vel == point(0,0)) then
		pixel.putInMap(self)
	else
		pixel.pixels[self.id] = nil
	end
	
	
	
end

function pixel:resolveCollision(cPos)
	
	local pxl2 = pixel.getFromMap(cPos)
	
	if not (pxl2 == nil) then
		local normal = point(pxl2.pos.x - self.pos.x, pxl2.pos.y - self.pos.y):normalize()
		local a1 = self.vel:dot(normal)
		local a2 = pxl2.vel:dot(normal)
		local p = (2 * (a1 - a2)) / (2)
		local v1 = self.vel:copy()
			
		v1.x = v1.x - p * pxl2.mass * normal.x
		v1.y = v1.y - p * pxl2.mass * normal.y
		local v2 = pxl2.vel:copy()
		v2.x = v2.x + p * self.mass * normal.x
		v2.y = v2.y + p * self.mass * normal.y
			
		self.vel = v1
		pxl2.vel = v2
	else
		
		self.vel = point(0,0)
	
	end

end

function pixel:__tostring()
	
	return "( " .. tostring(self.x) .. ", " .. tostring(self.y) .. " )"
	
end

setmetatable(pixel, pixel.mt)

