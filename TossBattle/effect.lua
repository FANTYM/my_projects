require "point"

effect = {}
effect.__index = effect
effect.effects = {}
effect.curIndex = 0

function effect:__eq(eff2)

	if (self.id == eff2.id) then
	   return true
	end
	
	return false

end

function effect:setScale(newScale)
	
	if not newScale then
		self.scale = 1
		return
	end
	
	self.scale = newScale

end

function effect:setAngle(newAngle)
	
	if not newAngle then
		self.angle = 0
		return
	end
	self.angle = newAngle

end

function effect.new(effName, position, velocity, dispImage, timeToLive, animInfo)

	local newEff = {}
	setmetatable(newEff, effect)
	
	newEff.name = effName
	newEff.pos = position
	newEff.vel = velocity
	newEff.img = dispImage
	newEff.angle = 0
	newEff.scale = 1
	newEff.isDead = false
	newEff.created = love.timer.getTime()
	newEff.visible = true
	newEff.ttl = timeToLive
	
	if animInfo then
		
		newEff.hasAnim = true
		newEff.anims = {}
		
		-- setup images
		newEff.srcImgData = dispImage:getData()
		newEff.img = love.graphics.newImage(love.image.newImageData(animInfo.fSize.x, animInfo.fSize.y))
		newEff.imgData = newEff.img:getData()
		
		-- passed info animInfo{ name=, loop= , fps= , fSize = }
		
		animInfo.index = 0
		animInfo.fCount = point(math.floor(newEff.srcImgData:getWidth() / animInfo.fSize.x), math.floor(newEff.srcImgData:getHeight() / animInfo.fSize.y))
		animInfo.tCount = animInfo.fCount.x * animInfo.fCount.y
		animInfo.curFrame = animInfo.curFrame or 0
		animInfo.lastFrameTime = love.timer.getTime()
		animInfo.timePerFrame = 1 / animInfo.fps
		animInfo.fRow = math.floor(animInfo.curFrame / animInfo.fCount.y);
		animInfo.fCol = math.floor(animInfo.curFrame % animInfo.fCount.x);
		newEff.imgData:paste(newEff.srcImgData, 0,0, animInfo.fCol * animInfo.fSize.x, animInfo.fRow * animInfo.fSize.x, animInfo.fSize.x, animInfo.fSize.y)
		newEff.img:refresh()
		
		newEff.anims[0] = animInfo
		newEff.curAnim = 0
		
	else
	
		newEff.hasAnim = false
		newEff.anims[0] = { name="none", loop=false , fps=0 , fSize = point(newEff.img:getWidth(), newEff.img:getHeight()), fCount = point(0,0), tFrames = 0}
		newEff.curAnim = 0
		
	end
	
	newEff.index = effect.curIndex
	effect.effects[effect.curIndex] = newEff
	effect.curIndex = effect.curIndex + 1
	
	return newEff

end

function effect:reColor(oldColor, newColor)
	
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

function effect:doAnim()
	
	fDelta = love.timer.getTime() - self.anims[self.curAnim].lastFrameTime
	
	if fDelta > self.anims[self.curAnim].timePerFrame then
		frameAdvance = math.ceil(fDelta / self.anims[self.curAnim].timePerFrame)
		self.anims[self.curAnim].curFrame = self.anims[self.curAnim].curFrame + 1
		if self.anims[self.curAnim].curFrame > (self.anims[self.curAnim].tCount - 1) then
			if self.anims[self.curAnim].loop then
				self.anims[self.curAnim].curFrame = self.anims[self.curAnim].curFrame - self.anims[self.curAnim].tCount
			else
				self.hasAnim = false
				effect.effects[self.index] = nil
			end
		end
		
		self.anims[self.curAnim].fRow = math.floor(self.anims[self.curAnim].curFrame / self.anims[self.curAnim].fCount.y);
		self.anims[self.curAnim].fCol = math.floor(self.anims[self.curAnim].curFrame % self.anims[self.curAnim].fCount.x);
		
		self.imgData:paste(self.srcImgData, 0,0, self.anims[self.curAnim].fCol * self.anims[self.curAnim].fSize.x, self.anims[self.curAnim].fRow * self.anims[self.curAnim].fSize.x, self.anims[self.curAnim].fSize.x, self.anims[self.curAnim].fSize.y)
		self.img:refresh()
		self.anims[self.curAnim].lastFrameTime = love.timer.getTime()
	end
	
	

end

function effect.drawEffects()
	
	for k, eff in pairs(effect.effects) do
		
		eff:draw()
		
	end

end

function effect:draw()
	
	if self.hasAnim then
		self:doAnim()
	end
	
	if self.visible then
		self.pos = self.pos + self.vel
		--love.graphics.draw(self.img, self.pos.x, self.pos.y, math.rad(self.angle),self.scale,self.scale,(self.anims[self.curAnim].fSize.x  * self.scale), (self.anims[self.curAnim].fSize.y * self.scale))
		love.graphics.draw(self.img, self.pos.x, self.pos.y, math.rad(self.angle),self.scale,self.scale,(self.anims[self.curAnim].fSize.x  ) * 0.5, (self.anims[self.curAnim].fSize.y ) * 0.5)
	end
	
	if (love.timer.getTime() - self.created) > self.ttl then
		if not (self.ttl == -1) then
			effect.effects[self.index] = nil
		else
			self.created = self.created + 991894851
		end
		
	end

end

function effect:__tostring()
	
	return "Name: " .. self.name .. ", Velocity: " .. tostring(self.vel) .. ", Position: " .. tostring(self.pos)
	
end

