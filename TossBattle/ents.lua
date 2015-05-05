require "entity"

ents = {}
ents.entList = {}
ents.nextID = 0
ents.lastThink = love.timer.getTime()
ents.__index = ents
ents.gravity = point(0,20)
ents.collisionImage = ""


function ents.newEntity(entName, position, velocity, mass, dispImage, collisionRadius, thinkFunction, collideFunction)
	
	newEnt = entity.new(entName, position, velocity, mass, dispImage, collisionRadius, thinkFunction, collideFunction)
	newEnt.id = ents.nextID
	ents.entList[ents.nextID] = newEnt
	ents.nextID = ents.nextID + 1
	
	return newEnt
	
end
	
function ents.resolveCollision(ent1, ent2)

	local normal = point(ent2.pos.x - ent1.pos.x, ent2.pos.y - ent1.pos.y):normalize()

    local a1 = ent1.vel.dot(normal)
    local a2 = ent2.vel.dot(normal)
    local p = (2 * (a1 - a2)) / (ent1.mass + ent2.mass)
    local v1 = ent1.vel:copy()
        
	v1.x = v1.x - p * ent2.mass * normal.x
    v1.y = v1.y - p * ent2.mass * normal.y
    local v2 = ent2.vel:copy()
    v2.x = v2.x + p * ent1.mass * normal.x
    v2.y = v2.y + p * ent1.mass * normal.y
        
    ent1.vel = v1
    ent2.vel = v2

    local pushVec1 = ent1.pos - ent2.pos
    local pushVec2 = ent2.pos - ent1.pos
    local penDist = -ent1.getPenDist(ent2)
        
    ent1.pos = ent1.pos + ((pushVec1 * penDist) * ent1.timeDelta)
    ent2.pos = ent2.pos + ((pushVec2 * penDist) * ent1.timeDelta)


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
			
			ent:draw()
			
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

function ents:__tostring()
	
	return "entCount: " .. tostring(#ents.entList)
	
end

