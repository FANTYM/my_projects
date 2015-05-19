require "point"
require "Color"
pixel = {}
pixel.mt = {}
pixel.pixelMap = {{}}
pixel.pixels = {}
pixel.pixelID = 0
pixel.minSimTime = 0.0
pixel.lastSimTime = gameTime
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
	
	--pixel.image = newImg
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
		return nil
	end
	
	if (pixel.pixelMap[mapPos.y][mapPos.x] == nil) then
		return nil
	end
	
	return pixel.pixels[pixel.pixelMap[mapPos.y][mapPos.x]]
	
end

function pixel.movePixels(updateDelta)
	
	for k, pxl in pairs(pixel.pixels) do
		if not (pxl == nil) then
			pxl:move(updateDelta)
		end
	end
	
end

function pixel:destroy()
	
	pixel.clearMapPos(self)
	
	if self:inImage(self:getDispPos()) then
		pixel.imgData:setPixel(self:getDispPos().x, self:getDispPos().y, self.orgClr.r * 0.85, self.orgClr.g * 0.85 , self.orgClr.b * 0.85, self.orgClr.a)
	end
	
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
			r,g,b,a = pixel.imgData:getPixel(pos.x, pos.y)
			--pxl.clr = Color(r,g,b,a)
			pxl.orgClr = Color(r,g,b,a)
			pxl.clr = Color(255,math.random() * 255,0,a)
			pixel.imgData:setPixel(pos.x, pos.y, r,g,b,0)
		else
			pxl.clr = Color(0,0,0,0)
			pxl.orgClr = Color(0,0,0,0)
		end
		pxl.mass = 3
		pxl.id = pixel.pixelID
		pxl.deadTimer = gameTime
		pxl.notMoving = false
		pixel.pixelID = pixel.pixelID + 1
		pixel.pixels[pxl.id] = pxl
		pixel.putInMap(pxl)
	else
		
		pixel.putInMap(existing)
		
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
	
	self.lastPos = self:getDispPos()
	didHit = false
	
	simDelta = updateDelta 

	pixel.clearMapPos(self)

	self.vel = self.vel + (pixel.gravity * simDelta)
	local newPos = self.pos + (self.vel * simDelta)
	local checkPos = self.pos + self.vel:getNormal()
	
	newPos.x = math.floor(newPos.x)
	newPos.y = math.floor(newPos.y)
	
	
	pxl2 = pixel.getFromMap(newPos)
	
	if pxl2 then
		self:resolveCollision(pxl2, true, simDelta)
		--print("hit Pixel")
		didHit = true
		self.pos = self.pos + (self.vel * simDelta)
	else
		if self:inImage(newPos) then
			r,g,b,a  = pixel.imgData:getPixel(newPos.x, newPos.y)
			
			if a > 0 then
				self:resolveCollision(newPos, false, simDelta)
				--print("hit ground")
				didHit = true
			else
				self.pos = self.pos + (self.vel * simDelta)
			end
		end
	end
	
	--if not didHit then
		--self.pos = self.pos + (self.vel * simDelta)
	--else
	--	--self.pos = self.lastPos -- + (self.vel * simDelta)
	--end
	
	if (self.pos.x < 0 and  self.vel.x < 0) or 
	   (self.pos.x > pixel.imgData:getWidth() and  self.vel.x > 0) then
		self:destroy()
		return
	end
	
	if self:getDispPos() == self.lastPos then
		
		if self.notMoving then
			if gameTime - self.deadTimer >= 0.1 then
				self:destroy()
				return
			end
		else
			self.deadTimer = gameTime
			self.notMoving = true
		end
	else
		self.notMoving = false
	end
	
	pixel.putInMap(self)
	
end

function pixel:resolveCollision(pxl2, canMove, physStep)
	
	if canMove  or (pxl2.x == nil) then
		
		normal = point(pxl2.pos.x - self.pos.x, pxl2.pos.y - self.pos.y):normalize()
		a1 = self.vel:dot(normal)
		a2 = pxl2.vel:dot(normal)
		p = (2 * (a1 - a2)) / (self.mass + pxl2.mass)
		v1 = self.vel:copy()
		v2 = pxl2.vel:copy()
		
		v1.x = v1.x - (p * pxl2.mass * normal.x)
		v1.y = v1.y - (p * pxl2.mass * normal.y)
		
		v2.x = v2.x + (p * self.mass * normal.x)
		v2.y = v2.y + (p * self.mass * normal.y)
		
		self.vel = v1 * 0.9 
		pxl2.vel = v2 * 0.9
		
		pushVec1 = self.pos - pxl2.pos
		pushVec2 = pxl2.pos - self.pos
		
		self.pos = self.pos + (pushVec1 * physStep)
		pxl2.pos = pxl2.pos + (pushVec2 * physStep)
		
	else
		self.vel = (self.vel - gravity)
		normal = point(pxl2.x - self.pos.x, pxl2.y - self.pos.y):normalize()
		a1 = self.vel:dot(normal)
		a2 = point(0,0):dot(normal)
		p = (2 * (a1 - a2)) / (self.mass + 90000)
	
		self.vel.x = self.vel.x - (p * 90000 * normal.x)
		self.vel.y = self.vel.y - (p * 90000 * normal.y)
		
		pushVec1 = self.pos - pxl2
		
		self.pos = self.pos + pushVec1 -- * physStep)
		
		---self.vel = self.vel * 0.01
		
	end
		
	

end

function pixel:__tostring()
	
	return "( " .. tostring(self.x) .. ", " .. tostring(self.y) .. " )"
	
end

function pixel:__eq(p2)
	
	return self.id == p2.id

end

setmetatable(pixel, pixel.mt)

