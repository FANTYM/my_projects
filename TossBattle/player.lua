require "Color"
player            = {}
player.__index    = player
player.tankBody   = love.graphics.newImage("tank_body.png"):getData()
player.tankBarrel = love.graphics.newImage("tank_barrel.png"):getData()
player.tankTreads = love.graphics.newImage("tank_treads.png"):getData()

function player.new(plyName, plyPos, plyColor)
	
	nPly = {}
	setmetatable(nPly, player)
	nPly.name = plyName
	nPly.color = plyColor
	nPly.vel = point(0,0)
	nPly.pos = plyPos
	nPly.angle = 45
	nPly.power = 100
	nPly.maxPower = 500
	nPly.gravity = point(0,20)
	nPly.lastThink = love.timer.getTime()
	nPly.cRadius = 16
	
	
	treadCopy = love.image.newImageData(player.tankTreads:getWidth(), player.tankTreads:getHeight())
	treadCopy:paste(player.tankTreads,0,0,0,0,player.tankTreads:getWidth(), player.tankTreads:getHeight())
	nPly.treadsImg = love.graphics.newImage(treadCopy)
	
	bodyCopy = love.image.newImageData(player.tankBody:getWidth(), player.tankBody:getHeight())
	bodyCopy:paste(player.tankBody,0,0,0,0,player.tankBody:getWidth(), player.tankBody:getHeight())
	nPly.bodyImg = love.graphics.newImage(bodyCopy)
	
	barrelCopy = love.image.newImageData(player.tankBarrel:getWidth(), player.tankBarrel:getHeight())
	barrelCopy:paste(player.tankBarrel,0,0,0,0,player.tankBarrel:getWidth(), player.tankBarrel:getHeight())
	nPly.barrelImg = love.graphics.newImage(barrelCopy)
	
	nPly.treadEnt = entity.new(plyName .. "_tread", plyPos, point(0,0), nPly.treadsImg, {name = "rollTreads", fCount = point(3,1), fps = 12, loop = true}, function() end, function() end)
	nPly.treadEnt:reColor(Color(255,255,255,255), nPly.color)
	nPly.bodyEnt = entity.new(plyName .. "_body", plyPos, point(0,0), nPly.bodyImg,nil,  function() end, function() end)
	nPly.bodyEnt:reColor(Color(255,255,255,255), nPly.color)
	nPly.barrelEnt = entity.new(plyName .. "_barrel", plyPos, point(0,0), nPly.barrelImg,nil, function() end, function() end)
	nPly.barrelEnt:reColor(Color(255,255,255,255), nPly.color)
	
	return ents.addEnt(nPly)

end

function player:think()
	
	thinkDelta = love.timer.getTime() - self.lastThink

	
	self.vel = self.vel + (self.gravity * thinkDelta)
	self.treadEnt.vel = self.vel
	self.bodyEnt.vel = self.vel
	self.barrelEnt.vel = self.vel
	
	self.pos = self.pos + (self.vel * thinkDelta)
	self.treadEnt.pos = self.pos
	self.bodyEnt.pos = self.pos
	self.barrelEnt.pos = self.pos + point(0,2)
	
	colCheckPos = self.pos + (self.vel:getNormal() * self.cRadius)
	if pixel.inImage(nil, colCheckPos) then
				
		r,g,b,a = pixel.imgData:getPixel(colCheckPos.x, colCheckPos.y)
		--print(a)
		if a > 250 then
			
			self.vel = (self.gravity * -1) * thinkDelta
			self.pos = self.pos + self.vel
			
			
		end
	
	end
	
	self.lastThink = love.timer.getTime()
	
end
	
function player:draw(drawDelta)
	
	
	self.barrelEnt.angle = self.angle
	self.barrelEnt:draw(drawDelta)
	self.treadEnt:draw(drawDelta)
	self.bodyEnt:draw(drawDelta)
	

end


