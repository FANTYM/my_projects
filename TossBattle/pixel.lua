require "point"
require "Color"
pixel = {}
pixel.mt = {}
pixel.pixelMap = {{}}
pixel.pixels = {}
pixel.pixelID = 0
pixel.minSimTime = 0.0
pixel.lastSimTime = love.timer.getTime()
pixel.image = ""
pixel.gravity = point(0,20)

pixel.__index = pixel

function pixel.putInMap(pxl)

	mapPos = pxl:getDispPos()

	if pixel.pixelMap[mapPos.y] == nil then
		pixel.pixelMap[mapPos.y] = {}
	end
	
	pixel.pixelMap[mapPos.y][mapPos.x] = pxl.id
	
end

function pixel.clearMapPos(pxl)

	mapPos = pxl:getDispPos()
	
	if pixel.pixelMap[mapPos.y] == nil then
		pixel.pixelMap[mapPos.y] = {}
	end
	
	pixel.pixelMap[mapPos.y][mapPos.x] = nil
	
end

function pixel.getFromMap(pos)
	
	mapPos = point(math.ceil(pos.x), math.ceil(pos.y))
	
	if pixel.pixelMap[mapPos.y] == nil then
		pixel.pixelMap[mapPos.y] = {}
	end
	
	if (pixel.pixelMap[mapPos.y][mapPos.x] == nil) then
		return nil
	end
	
	return pixel.pixels[pixel.pixelMap[mapPos.y][mapPos.x]]
	
end

function pixel.movePixels()
	
	--if love.timer.getTime() - pixel.lastSimTime > pixel.minSimTime then
		--pixel.lastSimTime = love.timer.getTime()
		for k, pxl in pairs(pixel.pixels) do
			if not (pxl == nil) then
				pxl:move()
			end
		end
	--end
	
end


function pixel.mt:__call(pos, vel) 
	
	local pxl = {}
	
	existing = pixel.getFromMap(pos)
	
	if  existing == nil then
		setmetatable(pxl, pixel)
		pxl.pos = pos
		pxl.vel = vel
		pxl.clr = Color(r,g,b,a)
		pxl.img = img
		pxl.mass = 1
		pxl.lastSim = love.timer.getTime()
		pxl.id = pixel.pixelID
		pxl.deadTimer = love.timer.getTime()
		pxl.notMoving = false
		pixel.pixelID = pixel.pixelID + 1
		pixel.pixels[pxl.id] = pxl
		pixel.putInMap(pxl)
	else
		
		return existing
		
	end
	
	return pxl

end

function pixel:inImage(nPos)
	
	imgData = pixel.image:getData()
	
	if ((nPos.x >= 0) and (nPos.x <= (imgData:getWidth() - 1))) and
	   ((nPos.y >= 0) and (nPos.y <= (imgData:getHeight() - 1))) then
		return true
	end
	
	return false

end

function pixel:getDispPos()
	
	return point(math.ceil(self.pos.x), math.ceil(self.pos.y))

end

function pixel:move()
	
	imgData = pixel.image:getData()
	simDelta = love.timer.getTime() - self.lastSim
	pixel.clearMapPos(self)
	local curPos = self:getDispPos()
	--print("curPos : " .. tostring(self:getDispPos()))
	self.vel = self.vel + (pixel.gravity * simDelta)
	if self:inImage(self:getDispPos()) then 
		imgData:setPixel(self:getDispPos().x, self:getDispPos().y, 0, 0, 0, 0)
	end
	local nextPos = self.pos + (self.vel * simDelta)
	nextPos.x = math.ceil(nextPos.x)
	nextPos.y = math.ceil(nextPos.y)
	
	if self:inImage(nextPos) then
		r,g,b,a  = imgData:getPixel(nextPos.x, nextPos.y)
		if a > 250 then
			local pxl2 = pixel.getFromMap(nextPos)
			if not (pxl2 == self) then
				if not (pxl2 == nil) then
					self:resolveCollision(pxl2)
				else
					self.vel = -pixel.gravity * simDelta
				end
			end
		end
	end
	
	self.pos = self.pos + (self.vel * simDelta)
	
	if self:inImage(self:getDispPos()) then
		imgData:setPixel(self:getDispPos().x, self:getDispPos().y, self.clr.r, self.clr.g, self.clr.b, self.clr.a)
	end
	self.lastSim = love.timer.getTime()

	if (self.vel:closerThan(point(0,0), 1)) then
		
		if self.notMoving then
			if love.timer.getTime() - self.deadTimer > 1 then
				pixel.pixels[self.id] = nil	
			end
		else
			self.deadTimer = love.timer.getTime()
			self.notMoving = true
		end
	else
		self.notMoving = false
		pixel.putInMap(self)
	end
	
end

function pixel:resolveCollision(pxl2)
	
	local normal = point(pxl2.pos.x - self.pos.x, pxl2.pos.y - self.pos.y):normalize()
	local a1 = self.vel:dot(normal)
	local a2 = pxl2.vel:dot(normal)
	local p = (2 * (a1 - a2)) / (self.mass + pxl2.mass)
	local v1 = self.vel:copy()
	local v2 = pxl2.vel:copy()
	
	v1.x = v1.x - p * pxl2.mass * normal.x
	v1.y = v1.y - p * pxl2.mass * normal.y
	
	v2.x = v2.x + p * self.mass * normal.x
	v2.y = v2.y + p * self.mass * normal.y
		
	self.vel = v1

	pxl2.vel = v2
	--pxl2.mass = 1

end

function pixel:__tostring()
	
	return "( " .. tostring(self.x) .. ", " .. tostring(self.y) .. " )"
	
end

function pixel:__eq(p2)
	
	return self.id == p2.id

end

setmetatable(pixel, pixel.mt)

