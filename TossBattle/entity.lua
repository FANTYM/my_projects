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


function entity.new(entName, position, velocity, mass, dispImage, collisionRadius, thinkFunction, collideFunction)

	local newEnt = {}
	setmetatable(newEnt, entity)
	newEnt.name = entName
	newEnt.think = thinkFunction
	newEnt.collide = collideFunction
	newEnt.pos = position
	newEnt.vel = velocity
	newEnt.cRadius = collisionRadius
	newEnt.img = dispImage
	newEnt.angle = 0
	newEnt.scale = 1
	newEnt.mass = mass
	newEnt.friction = 0.95
	newEnt.isDead = false
	newEnt.deadTimer = love.timer.getTime()
	newEnt.visible = true

	return newEnt

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


function entity:draw()

	if self.visible then
		love.graphics.draw(self.img, self.pos.x, self.pos.y, math.rad(self.angle),self.scale,self.scale,self.cRadius * self.scale, self.cRadius * self.scale)
	end
	

end

function entity:__tostring()
	
	return "Name: " .. self.entName .. ", Velocity: " .. tostring(self.vel) .. ", Position: " .. tostring(self.pos)
	
end

