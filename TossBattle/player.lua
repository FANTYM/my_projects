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
	nPly.pos = plyPos
	nPly.angle = 45
	
	treadCopy = love.image.newImageData(player.tankTreads:getWidth(), player.tankTreads:getHeight())
	treadCopy:paste(player.tankTreads,0,0,0,0,player.tankTreads:getWidth(), player.tankTreads:getHeight())
	nPly.treadsImg = love.graphics.newImage(treadCopy)
	
	bodyCopy = love.image.newImageData(player.tankBody:getWidth(), player.tankBody:getHeight())
	bodyCopy:paste(player.tankBody,0,0,0,0,player.tankBody:getWidth(), player.tankBody:getHeight())
	nPly.bodyImg = love.graphics.newImage(bodyCopy)
	
	barrelCopy = love.image.newImageData(player.tankBarrel:getWidth(), player.tankBarrel:getHeight())
	barrelCopy:paste(player.tankBarrel,0,0,0,0,player.tankBarrel:getWidth(), player.tankBarrel:getHeight())
	nPly.barrelImg = love.graphics.newImage(barrelCopy)
	
	nPly.treadEnt = entity.new(plyName .. "_tread", plyPos, point(0,0), 20, nPly.treadsImg, (nPly.treadsImg:getWidth() + nPly.treadsImg:getHeight()) * 0.25 , function() end, function() end)
	nPly.treadEnt:reColor(Color(255,255,255,255), nPly.color)
	nPly.bodyEnt = entity.new(plyName .. "_body", plyPos, point(0,0), 20, nPly.bodyImg, (nPly.bodyImg:getWidth() + nPly.bodyImg:getHeight()) * 0.25 , function() end, function() end)
	nPly.bodyEnt:reColor(Color(255,255,255,255), nPly.color)
	nPly.barrelEnt = entity.new(plyName .. "_barrel", plyPos, point(0,0), 20, nPly.barrelImg, (nPly.barrelImg:getWidth() + nPly.barrelImg:getHeight()) * 0.25 , function() end, function() end)
	nPly.barrelEnt:reColor(Color(255,255,255,255), nPly.color)
	
	return nPly

end

function player:draw()
	
	
	self.treadEnt.pos = self.pos
	self.bodyEnt.pos = self.pos
	self.barrelEnt.pos = self.pos + point(0,2)
	self.barrelEnt.angle = self.angle
	self.barrelEnt:draw()
	self.treadEnt:draw()
	self.bodyEnt:draw()
	
	
	


end


