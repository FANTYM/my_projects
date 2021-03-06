require "point"

entity = {}
entity.__index = entity

function entity:__eq(ent2)

	if (self.id == ent2.id) then
	   return true
	end
	
	return false

end

function entity:setScale(newScale)
	
	if not newScale then
		self.scale = 1
		return
	end
	
	self.scale = newScale

end

function entity:setAngle(newAngle)
	
	if not newAngle then
		self.angle = 0
		return
	end
	self.angle = newAngle

end

function entity:getPenDist(ent2)

	local dist = self.pos:dist(ent2.pos)
	return dist - (self.cRadius * ent2.cRadius)

end

function entity.new(entName, position, velocity, dispImage, animInfo, thinkFunction, collideFunction)

	local newEnt = {}
	setmetatable(newEnt, entity)
	newEnt.name = entName
	newEnt.gravity = gravity
	newEnt.pThink = thinkFunction
	newEnt.pCollide = collideFunction
	newEnt.pos = position
	newEnt.lastPos = newEnt.pos
	newEnt.vel = velocity
	newEnt.img = dispImage
	newEnt.imgData = newEnt.img:getData()
	newEnt.anims = {}
	newEnt.curAnim = 0
	if animInfo then
		
		newEnt.hasAnim = true
	-- setup images
		newEnt.srcImgData = dispImage:getData()
		
		-- passed info animInfo{ name=, loop= , fps= , fCount = , tFrames = }
		
		animInfo.index = 0
		animInfo.fSize = point(math.floor(newEnt.srcImgData:getWidth() / animInfo.fCount.x), math.floor(newEnt.srcImgData:getHeight() / animInfo.fCount.y))
		animInfo.curFrame = animInfo.curFrame or 0
		animInfo.tFrames = animInfo.tFrames or (animInfo.fCount.x * animInfo.fCount.y)
		animInfo.lastFrameTime = gameTime
		animInfo.timePerFrame = 1 / animInfo.fps
		animInfo.fRow = math.floor(animInfo.curFrame / animInfo.fCount.x);
		animInfo.fCol = math.floor(animInfo.curFrame % animInfo.fCount.x);
		
		newEnt.img = love.graphics.newImage(love.image.newImageData(animInfo.fSize.x, animInfo.fSize.y))
		newEnt.imgData = newEnt.img:getData()
		
		newEnt.imgData:paste(newEnt.srcImgData, 0,0, animInfo.fCol * animInfo.fSize.x, animInfo.fRow * animInfo.fSize.y, animInfo.fSize.x, animInfo.fSize.y)
		newEnt.img:refresh()
		newEnt.anims[0] = animInfo
		
	else
	
		newEnt.hasAnim = false
		newEnt.anims[0] = { name="none", loop=false , fps=0 , fSize = point(newEnt.img:getWidth(), newEnt.img:getHeight()), fCount = point(1,1), tFrames = 1, lastFrameTime = love.timer.getTime()}
		
		
	end
	
	newEnt.angle = 0
	newEnt.lastAngle = 0
	newEnt.angVel = point(0,0)
	newEnt.scale = 1
	newEnt.mass = (newEnt.anims[0].fSize.x * newEnt.anims[0].fSize.y) * 0.9
	newEnt.cRadius = (newEnt.anims[0].fSize.x + newEnt.anims[0].fSize.y) * 0.5
	newEnt.inertia = 0
	newEnt.torque = 0
	newEnt.friction = 0.95
	newEnt.bounce = 0.2
	newEnt.isDead = false
	newEnt.deadTimer = gameTime
	newEnt.visible = true
	newEnt.attachedEnts = {}
	newEnt.aabb = { min = point(-(newEnt.anims[0].fSize.y * 0.5), -(newEnt.anims[0].fSize.x * 0.5)) , max = point(newEnt.anims[0].fSize.y * 0.5 , newEnt.anims[0].fSize.x * 0.5) }

	return newEnt

end

function entity:separateAxisTest(ent2)
	
	if (self.aabb.max.x < ent2.aabb.min.x) or (self.aabb.min.x > ent2.aabb.max.x) then
		return false
	end
	
	if (self.aabb.max.y < ent2.aabb.min.y) or (self.aabb.min.y > ent2.aabb.max.y) then
		return false
	end
 
	return true

end

function entity:setPos(newPos)
	
	self.lastPos = self.pos
	self.pos = newPos
	
end

function entity:setAngle(newAng)
	
	self.lastAngle = self.angle
	self.angle = newAng
	
end

function entity:reColor(oldColor, newColor)
	
	imgData = self.img:getData()
	
	function pixFunc(x,y,r,g,b,a)
	
		if (r == oldColor.r) and
		   (g == oldColor.g) and
		   (b == oldColor.b) and
		   (a == oldColor.a) then
				r = newColor.r
				g = newColor.g
				b = newColor.b
				a = newColor.a
		end
		
		return r,g,b,a
	
	end
	
	imgData:mapPixel(pixFunc)
	
	self.img:refresh()
	
end

function entity:think(thinkDelta)

	self.lastPos = self.pos
	self.vel = self.vel + (self.gravity * thinkDelta)
	self.pos = self.pos + (self.vel * thinkDelta)
	
	if self.pThink then
		self:pThink()
	end
	

end

function entity:collide(colEnt)

	if self.pCollide then
		self:pCollide(colEnt)
	end
	
end


function entity:draw(physAdjust)

	if self.visible then
		if self.hasAnim then
			self:doAnim()
		end
		--love.graphics.draw(self.img, self.pos.x, self.pos.y, math.rad(self.angle),self.scale,self.scale,self.cRadius * self.scale, self.cRadius * self.scale)
		--love.graphics.draw(self.img, self.pos.x, self.pos.y, math.rad(self.angle),self.scale,self.scale,(self.anims[self.curAnim].fSize.x  ) * 0.5, (self.anims[self.curAnim].fSize.y ) * 0.5)
		love.graphics.draw(self.img, -viewInfo.pos.x() + (self.lastPos.x * physAdjust) + (self.pos.x * (1 - physAdjust)), -viewInfo.pos.y() + (self.lastPos.y * physAdjust) + (self.pos.y * (1 - physAdjust)), math.rad((self.lastAngle * physAdjust) + (self.angle * (1 - physAdjust))),self.scale,self.scale,(self.anims[self.curAnim].fSize.x  ) * 0.5, (self.anims[self.curAnim].fSize.y ) * 0.5)
	end
	

end

function entity:doAnim()
	
	local fDelta = gameTime - self.anims[self.curAnim].lastFrameTime
	
	if fDelta == 0 then return end
	if fDelta >= self.anims[self.curAnim].timePerFrame then
	
		frameAdvance = math.floor(fDelta / self.anims[self.curAnim].timePerFrame)
		--print("frameAdvance: " .. tostring(frameAdvance))
		self.anims[self.curAnim].curFrame = self.anims[self.curAnim].curFrame + frameAdvance
		--print("curFrame: " .. tostring(self.anims[self.curAnim].curFrame))
		--print("tFrames: " .. tostring(self.anims[self.curAnim].tFrames))
		if self.anims[self.curAnim].curFrame > (self.anims[self.curAnim].tFrames) then
			--print("curFrame over limit")
			if self.anims[self.curAnim].loop then
				--print("Loops")
				self.anims[self.curAnim].curFrame = self.anims[self.curAnim].curFrame - self.anims[self.curAnim].tFrames
				--print("curFrame: " .. tostring(self.anims[self.curAnim].curFrame))
				
			else
				--print("anim over")
				self.hasAnim = false
				effect.effects[self.index] = nil
			end
		end
		
		self.anims[self.curAnim].fRow = math.floor(self.anims[self.curAnim].curFrame / self.anims[self.curAnim].fCount.x)
		self.anims[self.curAnim].fCol = math.floor(self.anims[self.curAnim].curFrame % self.anims[self.curAnim].fCount.x)
		
		--print("fRow: " .. tostring(self.anims[self.curAnim].fRow))
		--print("fCol: " .. tostring(self.anims[self.curAnim].fCol))
		
		self.imgData:paste(self.srcImgData, 0,0, self.anims[self.curAnim].fCol * self.anims[self.curAnim].fSize.x, self.anims[self.curAnim].fRow * self.anims[self.curAnim].fSize.y, self.anims[self.curAnim].fSize.x, self.anims[self.curAnim].fSize.y)
		self.img:refresh()
		self.anims[self.curAnim].lastFrameTime = gameTime
	end
	
	

end

function entity:__tostring()
	
	return "Name: " .. self.entName .. ", Velocity: " .. tostring(self.vel) .. ", Position: " .. tostring(self.pos)
	
end

