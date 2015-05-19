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
pixel.imgData = ""
pixel.gravity = gravity

pixel.__index = pixel

function pixel.count()
	
	count = 0
	
	for k, pxl in pairs(pixel.pixels) do
		if pxl then
			count = count + 1
		end
	end
	
	return count

end

function pixel.setImage(newImg)
	
	pixel.image = newImg
	pixel.imgData = newImg:getData()

end

function pixel.drawPixels(physAlpha)
	
	for k, pxl in pairs(pixel.pixels) do
		love.graphics.setColor(pxl.clr.r,pxl.clr.g,pxl.clr.b,pxl.clr.a)		
		--love.graphics.point(pxl.pos.x, pxl.pos.y)
		love.graphics.point(( pxl.lastPos.x * physAlpha ) + (pxl.pos.x * (1 - physAlpha)), ( pxl.lastPos.y * physAlpha ) + (pxl.pos.y * (1 - physAlpha)))
	end
	
	love.graphics.setColor(255,255,255,255)		
	
end

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
	
	mapPos = point(math.floor(pos.x), math.floor(pos.y))
	
	if pixel.pixelMap[mapPos.y] == nil then
		pixel.pixelMap[mapPos.y] = {}
	end
	
	if (pixel.pixelMap[mapPos.y][mapPos.x] == nil) then
		return nil
	end
	
	return pixel.pixels[pixel.pixelMap[mapPos.y][mapPos.x]]
	
end

function pixel.movePixels(updateDelta)
	
	--if love.timer.getTime() - pixel.lastSimTime > pixel.minSimTime then
		--pixel.lastSimTime = love.timer.getTime()
		for k, pxl in pairs(pixel.pixels) do
			if not (pxl == nil) then
				pxl:move(updateDelta)
			end
		end
	--end
	
end

function pixel:destroy()
	
	if self:inImage(self:getDispPos()) then
		pixel.imgData:setPixel(self:getDispPos().x, self:getDispPos().y, self.orgClr.r * 0.85, self.orgClr.g * 0.85 , self.orgClr.b * 0.85, self.orgClr.a)
	end
	
	pixel.clearMapPos(self)
	
	pixel.pixels[self.id] = nil	
	
	self = nil

end

function pixel.mt:__call(pos, vel) 
	
	local pxl = {}
	
	existing = pixel.getFromMap(pos)
	
	if  existing == nil then
		setmetatable(pxl, pixel)
		pxl.pos = pos
		pxl.lastPos = pos
		pxl.vel = vel
		pxl.img = pixel.image
		if pxl:inImage() then
			r,g,b,a = pixel.image:getData():getPixel(pos.x, pos.y)
			--pxl.clr = Color(r,g,b,a)
			pxl.orgClr = Color(r,g,b,a)
			pxl.clr = Color(255,0,0,a)
			pixel.imgData:setPixel(pos.x, pos.y, r,g,b,0)
		else
			pxl.clr = Color(0,0,0,0)
			pxl.orgClr = Color(0,0,0,0)
		end
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
	
	--pixel.imgData = pixel.image:getData()
	if not nPos then
		nPos = self.pos
	end
	
	if ((nPos.x >= 0) and (nPos.x <= (pixel.imgData:getWidth() - 1))) and
	   ((nPos.y >= 0) and (nPos.y <= (pixel.imgData:getHeight() - 1))) then
		return true
	end
	
	return false

end

function pixel:getDispPos()
	
	return point(math.floor(self.pos.x), math.floor(self.pos.y))

end

--pixel.lowestVel = point(7680,5670)

function pixel:move(updateDelta)
	
	self.lastPos = self.pos
	
	simDelta = updateDelta 

	pixel.clearMapPos(self)

	self.vel = self.vel + (pixel.gravity * simDelta)
	local checkPos = self.pos + self.vel:getNormal()
	
	checkPos.x = math.floor(checkPos.x)
	checkPos.y = math.floor(checkPos.y)
		
	pxl2 = pixel.getFromMap(checkPos)
	
	if pxl2 then
		self:resolveCollision(pxl2, true)
	else
		if self:inImage(checkPos) then
			r,g,b,a  = pixel.imgData:getPixel(checkPos.x, checkPos.y)
		end
		
		if a > 0 then
			self:resolveCollision(checkPos, false)
		end
		
	end
	
	self.pos = self.pos + (self.vel * simDelta)
	
	if (self.pos.x < 0 and  self.vel.x < 0) or 
	   (self.pos.x > pixel.imgData:getWidth() and  self.vel.x > 0) then
		self:destroy()
		return
	end
	
	if self.pos == self.lastPos then
		
		if self.notMoving then
			if love.timer.getTime() - self.deadTimer >= 1.5 then
				self:destroy()
				return
			end
		else
			self.deadTimer = love.timer.getTime()
			self.notMoving = true
		end
	else
		self.notMoving = false
	end
	
	pixel.putInMap(self)
	
end

function pixel:resolveCollision(pxl2, canMove)
	
	if canMove then
		normal = point(pxl2.pos.x - self.pos.x, pxl2.pos.y - self.pos.y):normalize()
		a1 = self.vel:dot(normal)
		a2 = pxl2.vel:dot(normal)
		p = (2 * (a1 - a2)) / (self.mass + pxl2.mass)
		v1 = self.vel:copy()
		v2 = pxl2.vel:copy()
		
		v1.x = v1.x - p * pxl2.mass * normal.x
		v1.y = v1.y - p * pxl2.mass * normal.y
		
		v2.x = v2.x + p * self.mass * normal.x
		v2.y = v2.y + p * self.mass * normal.y
		
		self.vel = v1 * 0.9
		pxl2.vel = v2 * 0.9
		
	else
		normal = point(pxl2.x - self.pos.x, pxl2.y - self.pos.y):normalize()
		a1 = self.vel:dot(normal)
		a2 = point(0,0):dot(normal)
		p = (2 * (a1 - a2)) / (self.mass + (self.mass * self.mass))
		v1 = self.vel:copy()
		v2 = point(0,0)
		
		v1.x = v1.x - p * (self.mass * self.mass) * normal.x
		v1.y = v1.y - p * (self.mass * self.mass) * normal.y
		
		v2.x = v2.x + p * self.mass * normal.x
		v2.y = v2.y + p * self.mass * normal.y	
		
		self.vel = v1 * 0.9
		
	end
		
	

end

function pixel:__tostring()
	
	return "( " .. tostring(self.x) .. ", " .. tostring(self.y) .. " )"
	
end

function pixel:__eq(p2)
	
	return self.id == p2.id

end

setmetatable(pixel, pixel.mt)

