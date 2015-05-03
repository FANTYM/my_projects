require "point"

ents = {}
ents.mt = {}
ents.entList = {}
ents.nextID = 0
ents.lastThink = love.timer.getTime()
ents.__index = ents
ents.gravity = point(0,20)
ents.collisionImage = ""

function ents.mt:__eq(ent2)

	if (self.id == ent2.id) then
	   return true
	end
	
	return false

end

function ents.mt:resolveCollision(ent2)

	local normal = point(ent2.pos.x - self.pos.x, ent2.pos.y - self.pos.y):normalize()

    local a1 = self.vel.dot(normal)
    local a2 = ent2.vel.dot(normal)
    local p = (2 * (a1 - a2)) / (self.mass + ent2.mass)
    local v1 = self.vel:copy()
        
	v1.x = v1.x - p * ent2.mass * normal.x
    v1.y = v1.y - p * ent2.mass * normal.y
    local v2 = ent2.vel:copy()
    v2.x = v2.x + p * self.mass * normal.x
    v2.y = v2.y + p * self.mass * normal.y
        
    self.vel = v1
    ent2.vel = v2

    local pushVec1 = self.pos - ent2.pos
    local pushVec2 = ent2.pos - self.pos
    local penDist = -self.getPenDist(ent2)
        
    self.pos = self.pos + ((pushVec1 * penDist) * self.timeDelta)
    ent2.pos = ent2.pos + ((pushVec2 * penDist) * self.timeDelta)


end

function ents.mt:getPenDist(ent2)

	local dist = self.pos:dist(ent2.pos)
	return dist - (self.cRadius * ent2.cRadius)

end

function ents.mt:draw(imgDest)
	
	imgData = imgDest:getData()
	
	imgData:paste(self.img:getData(), self.pos.x + self.cRadius, self.pos.y + self.cRadius, 0,0,16,16)

end

function ents.getByID(eId)

	for k, ent in pairs(ents.entList) do 
		
		if not (ent == nil) then
			
			if ent.id == eId then
				return ent
			end
			
		end
	
	end
	
	return nil
	
end

function ents.getByName(eName)

	for k, ent in pairs(ents.entList) do 
		
		if not (ent == nil) then
			
			if ent.name == eName then
				return ent
			end
			
		end
	
	end
	
	return nil

end

function ents.getID(eName)

	
	for k, ent in pairs(ents.entList) do 
		
		if not (ent == nil) then
			
			if ent.name == eName then
				return ent.id
			end
			
		end
	
	end
	
	return nil
	
end

function ents.remove(eInfo)
	
	if not (eInfo == nil) then
		
		if not (eInfo.name == nil) then
			table.remove(ents.entList, eInfo.id)
			return
		end
		
		if type(eInfo) == "number" then
			table.remove(ents.entList, eInfo)
			return
		end
		
		if type(eInfo) == "string" then
			table.remove(ents.entList, ents.getID(eInfo))
			return
		end
		
	end
	
end

function ents.draw()

	for k, ent in pairs(ents.entList) do 
		
		if not (ent == nil) then
			
			love.graphics.draw(ent.img, ent.pos.x, ent.pos.y, 0,0.25,0.25,ent.cRadius * 0.25, ent.cRadius * 0.25)
			
		end
	
	end

end

function ents.think()
	
	local thinkDelta = love.timer.getTime() - ents.lastThink
	ents.lastThink = love.timer.getTime()
	
	for k, ent in pairs(ents.entList) do 
		
		if not (ent == nil) then
			
			ent.vel = ent.vel + (ents.gravity * thinkDelta)
			ent.pos = ent.pos + (ent.vel * thinkDelta)
			
			colCheckPos = ent.pos + (ent.vel:getNormal() * ent.cRadius)
			
			if pixel.inImage(nil, colCheckPos) then
				
				r,g,b,a = ents.collisionImage:getData():getPixel(colCheckPos.x, colCheckPos.y)
				--print(a)
				if a > 250 then
					
					ent.vel = point(0,0)
					ent:collide()
					ents.entList[k] = nil
					
				end
			
			end
			
			if not (ent.think == nil) then
				ent:think()
			end
			
			if ent.vel:closerThan(point(0,0), 0.25) then
				
				--ents.entList[k] = nil
				if ent.isDead then
					if love.timer.getTime() - ent.deadTimer > 1 then
						ents.entList[k] = nil
					end
				else
					ent.isDead = true
					ent.deadTimer = love.timer.getTime()
				end
			else
				ent.isDead = false
				
			end
			
		end
	
	end
	
end

function ents.create(entName, position, velocity, mass, dispImage, collisionRadius, thinkFunction, collideFunction)

	local newEnt = {}
	setmetatable(newEnt, ents.mt)
	newEnt.name = entName
	newEnt.think = thinkFunction
	newEnt.collide = collideFunction
	newEnt.pos = position
	newEnt.vel = velocity
	newEnt.cRadius = collisionRadius
	newEnt.img = dispImage
	newEnt.mass = mass
	newEnt.friction = 0.95
	newEnt.isDead = false
	newEnt.deadTimer = love.timer.getTime()
	newEnt.id = ents.nextID
	ents.entList[ents.nextID] = newEnt
	ents.nextID = ents.nextID + 1
	return newEnt

end

function ents.mt:withinRadius(ent2, dist)

	local checkDist = dist * dist
	return  not (checkDist < (((ent2.pos.x - self.x)^2) + ((ent2.pos.y - self.y)^2)))

end


function ents.mt:__tostring()
	
	return "Name: " .. self.entName .. ", Velocity: " .. tostring(self.vel) .. ", Position: " .. tostring(self.pos)
	
end

