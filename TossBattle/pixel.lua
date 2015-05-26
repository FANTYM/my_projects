require "point"
require "Color"
pixel = {}
pixel.mt = {}
pixel.pixelMap = {{}}
pixel.pixels = {}
pixel.pixelID = 0
pixel.minSimTime = 0.0
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
		love.graphics.point(-viewInfo.pos.x() + ( pxl.lastPos.x * physAlpha ) + (pxl.pos.x * (1 - physAlpha)), -viewInfo.pos.y() + ( pxl.lastPos.y * physAlpha ) + (pxl.pos.y * (1 - physAlpha)))
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
			pxl.clr = Color(math.random() * 255 ,math.random() * 255,0,a)
			pixel.imgData:setPixel(pos.x, pos.y, r,g,b,0)
		else
			pxl.clr = Color(0,0,0,0)
			pxl.orgClr = Color(0,0,0,0)
		end
		pxl.mass = 13 + math.ceil((math.random() * 13))
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
function pixel:traceLine(startPos, endPos, step)
	--print(" ")
	--print("traceLine - startPos: " .. tostring(startPos) .. ", endPos: " .. tostring(endPos) .. ", step: " .. tostring(step))
	--print("stepLen: " .. tostring(step:length()))
	--print("traceLen: " .. tostring((endPos - startPos):length()))
	--print("numSteps: " .. tostring((endPos - startPos):length() / step:length())  )
	
	local sPos = startPos:copy()
	local cPos = point(math.floor(sPos.x), math.floor(sPos.y))
	local itCount = 0 
	
	if step:closerThan(point(0,0), 0) then
		
		return sPos, cPos
		
	end
	--while not sPos:closerThan(endPos, 1) do
	for tl = 0, (endPos - sPos):length(), step:length() do 
		--print(tl)
		itCount = itCount + 1
		pxl2 = pixel.getFromMap(cPos)
		
		if pxl2 then
			return sPos, cPos
		else
			if self:inImage(cPos) then
				r,g,b,a  = pixel.imgData:getPixel(cPos.x, cPos.y)
				if a > 0 then
					return sPos, cPos
				end
			end
		end
		sPos = sPos + step
		cPos = point(math.floor(sPos.x), math.floor(sPos.y))
		if itCount > 4 then 
			break
		end
	end
	

	return sPos, cPos --endPos

end

function pixel:move(updateDelta)
	
	self.lastPos = self:getDispPos()
	simDelta = updateDelta 
	pixel.clearMapPos(self)
	self.vel = self.vel + (pixel.gravity * simDelta)
	local newPos = self.pos + (self.vel * simDelta)

	newPos.x = math.floor(newPos.x)
	newPos.y = math.floor(newPos.y)
	
	self.pos, checkCol= self:traceLine(self.pos, newPos, (newPos - self.pos):getNormal())
	
	pxl2 = pixel.getFromMap(checkCol)
	
	if pxl2 == self then return end
	
	if pxl2 then
		self.pos = checkCol
		self:resolveCollision(pxl2, true, simDelta)
	else
		if self:inImage(checkCol) then
			r,g,b,a  = pixel.imgData:getPixel(checkCol.x, checkCol.y)
			if a > 0 then
				self.pos = checkCol
				self:resolveCollision(checkCol, false, simDelta)
			end
		end
	end
	
	self.pos = checkCol
	
	if (self.pos.x < 0 and  self.vel.x < 0) or 
	   (self.pos.x > pixel.imgData:getWidth() and  self.vel.x > 0) then
		self:destroy()
		return
	end
	
	if self:getDispPos() == self.lastPos then
		
		if self.notMoving then
			if gameTime - self.deadTimer >= 1 then
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

function pixel:getPlaneNormal(pPos)
	
	local curPos = point(0,0)
	local pxlInfo = {}
	local r, g, b, a
	--local strOut = ""
	local lowest = point(0,0)
	local highest = point(0,0)
	
	for y = -1,1 do
		pxlInfo[y] = {}
		
		for x = -1,1 do
			
			pxlInfo[y][x] = 0
			
			curPos.x = pPos.x + x
			curPos.y = pPos.y + y
			
			if self:inImage(curPos) then
				r,g,b,a  = pixel.imgData:getPixel(curPos.x, curPos.y)
				if a > 0 then
					pxlInfo[y][x] = 1
				else
					if x < lowest.x then
						lowest.x = x
					end
					if x > highest.x then
						highest.x = x
					end
					if y < lowest.y then
						lowest.y = y
					end
					if y > highest.y then
						highest.y = y
					end
				end
			end
			--strOut = strOut .. tostring(pxlInfo[y][x])
		end
		--strOut = strOut .. "\n"
	end
	
	--print(strOut)
	--print(lowest)
	--print(highest)
	local outVec = highest - lowest
	outVec = outVec:rotate(-90, lowest) 
	--print(lowest)
	
	return outVec		
	
end

function pixel:resolveCollision(pxl2, canMove, physStep)
	
	
	if canMove or (pxl2.x == nil) then
		
		colPos = point(pxl2.pos.x - self.pos.x, pxl2.pos.y - self.pos.y) * 0.5
		normal = point(pxl2.pos.x - self.pos.x, pxl2.pos.y - self.pos.y):getNormal():rotate(90, colPos)
		
		bounce = 0.2
		
		relVel = self.vel - pxl2.vel
		
		j = ( -(1 + bounce) * relVel:dot(normal)) / (normal:dot(normal) * ( (1/self.mass) + (1/pxl2.mass) ))
		
		v1 = self.vel + ((j / self.mass) * normal)
		v2 = pxl2.vel + ((j / pxl2.mass) * normal)
		
		self.vel = v1
		pxl2.vel = v2
		--print("pxl1: " .. tostring(self.vel))
		--print("pxl2: " .. tostring(pxl2.vel))
		--a1 = self.vel:dot(normal)
		--a2 = pxl2.vel:dot(normal)
		--p = (2 * (a1 - a2)) / (self.mass + pxl2.mass)
		--v1 = self.vel --:copy()
		--v2 = pxl2.vel --:copy()
		
		--v1.x = v1.x - (p * pxl2.mass * normal.x)
		--v1.y = v1.y - (p * pxl2.mass * normal.y)
		
		--v2.x = v2.x + (p * self.mass * normal.x)
		--v2.y = v2.y + (p * self.mass * normal.y)
		
		--self.vel = v1
		--pxl2.vel = v2
		
		--pushVec1 = self.pos - pxl2.pos
		--pushVec2 = pxl2.pos - self.pos
		
		--self.pos = self.pos + (pushVec1 * physStep)
		--pxl2.pos = pxl2.pos + (pushVec2 * physStep)
		
	else
		
		----   TODO: Create a function to get the ground normal 
		     --           From the collision image.
			 
		
		planeNorm = self:getPlaneNormal(pxl2)
		
		bounce = 0.2
		
		j = ( (1 + bounce) * self.vel:getNormal():dot(planeNorm) ) / (planeNorm:dot(planeNorm) * ( (1/self.mass)))
		
		v1 = self.vel + ((j / self.mass) * planeNorm)
		
		self.vel = v1
		
		--print("pxl1: " .. tostring(self.vel))
		--print("pxl2: ground")
		--v2 = pxl2.vel + ((j / pxl2.mass) * normal)
		
		--print("before:")
		--print(self.vel)
		--self:getPlaneNormal(pxl2)
		--planeNorm = point(0,-1)
		--planeNorm = self:getPlaneNormal(pxl2)
		--planeNorm = (pxl2 - self.pos):getNormal()
		--planeNorm = planeNorm:rotate( 45, pxl2)
		--self.vel = point(0,0)
		--self.vel =  self.vel + (planeNorm * (self.vel:length() * 2)) -- -2 * (self.vel:getNormal()):dot(planeNorm) * planeNorm
		--self.vel = -( 2 * (planeNorm:dot(self.vel)) * ( planeNorm - self.vel ))
		--print("after:")
		--print(self.vel)
		--print("")
		--  −(2(n · v) n − v)
		--planeNorm = (pxl2 - self.pos):getNormal()
		--planeNorm = planeNorm:rotate(-90, pxl2)
		--print(self.vel)
		--print(planeNorm)
		--print(planeNorm:dot(self.vel))
		--Vn = planeNorm * (planeNorm:dot(self.vel)) 
		--Vt = self.vel - Vn
		--self.vel = Vt - (0.2 * Vn)
		--self.vel = (self.vel - gravity)
		--normal = point(pxl2.x - self.pos.x, pxl2.y - self.pos.y):normalize()
		--a1 = self.vel:dot(normal)
		--a2 = point(0,0):dot(normal)
		--p = (2 * (a1 - a2)) / (self.mass )
		--self.vel.x = self.vel.x - (p * normal.x)
		--self.vel.y = self.vel.y - (p * normal.y)
		--pushVec1 = pxl2 - self.pos -- pxl2
		--self.pos = self.pos + (pushVec1 * physStep)
		--self.vel = self.vel * -1
		--self.vel = point(0,0)
		--self.vel = self.vel * 0.2
	end
		
	--if self.vel:length() > 3000 then
		--self.vel = point(0,0)
	--end
	

end

function pixel:__tostring()
	
	return "( " .. tostring(self.x) .. ", " .. tostring(self.y) .. " )"
	
end

function pixel:__eq(p2)
	
	return self.id == p2.id

end

setmetatable(pixel, pixel.mt)

