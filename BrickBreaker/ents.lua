require "entity"

ents = {}
ents.entList = {}
ents.nextID = 0
ents.lastThink = gameTime
ents.__index = ents
ents.gravity = gravity
ents.collisionImage = ""

function ents.setImage(newImg)
	
	--pixel.image = newImg
	ents.collisionImage = newImg:getData()

end

function ents.newEntity(entName, position, velocity,  dispImage, animInfo, thinkFunction, collideFunction)
	
	newEnt = entity.new(entName, position, velocity,  dispImage, animInfo, thinkFunction, collideFunction)
	newEnt.id = ents.nextID
	ents.entList[ents.nextID] = newEnt
	ents.nextID = ents.nextID + 1
	
	return newEnt
	
end

function ents.addEnt(ent)

	ent.id = ents.nextID
	ents.entList[ents.nextID] = ent
	ents.nextID = ents.nextID + 1
	
	return ent

end
	
function ents.resolveCollision(ent1, ent2, dTime)

	
	normal = point(ent2.pos.x - ent1.pos.x, ent2.pos.y - ent1.pos.y):normalize()

    a1 = ent1.vel:dot(normal)
    a2 = ent2.vel:dot(normal)
    p = (2 * (a1 - a2)) / (ent1.mass + ent2.mass)
    --v1 = ent1.vel:copy()
        
	ent1.vel.x = ent1.vel.x - p * ent2.mass * normal.x
    ent1.vel.y = ent1.vel.y - p * ent2.mass * normal.y
    --v2 = ent2.vel:copy()
    ent2.vel.x = ent2.vel.x + p * ent1.mass * normal.x
    ent2.vel.y = ent2.vel.y + p * ent1.mass * normal.y
        
    --ent1.vel = v1
    --ent2.vel = v2

    --pushVec1 = (ent1.pos - ent2.pos)
	--print(pushVec1)
    --pushVec2 = (ent2.pos - ent1.pos)
	--print(pushVec2)
    --penDist = -ent1:getPenDist(ent2)
	--print(penDist)
        
    --ent1:setPos(ent1.pos + (pushVec1 ))
    --ent2:setPos(ent2.pos + (pushVec2 ))


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
		
		if type(eInfo) == "number" then
			table.remove(ents.entList, eInfo)
			return
		end
		
		if type(eInfo) == "string" then
			table.remove(ents.entList, ents.getID(eInfo))
			return
		end
		
		if not (eInfo.id == nil) then
			table.remove(ents.entList, eInfo.id)
			return
		end
		
		
	end
	
end

function ents.draw(physAlpha)

	for k, ent in pairs(ents.entList) do 
		
		if not (ent == nil) then
			
			ent:draw(physAlpha)
			
		end
	
	end

end


function ents.think(updateDelta)
	
	
	for k, ent in pairs(ents.entList) do 
		if not (ent == nil) then
			
			ent.vel = ent.vel * ent.friction
			ent:think(updateDelta)
			
			local closeEnts = cellSystem.getCellContents(ent.pos, 2)
			
			for meh, checkEnt in pairs(closeEnts) do
				
				if not (ent == checkEnt) then
					aabbColTest = checkEnt:checkAABBCollison(ent)
					if  aabbColTest.hit then
						print("collision--------------------------------------------->")
						print("colNorm = " .. tostring(aabbColTest.normal)) 
						ent.vel = ent.vel + (ent.vel:length() * (aabbColTest.normal))
						checkEnt.vel = checkEnt.vel + (checkEnt.vel:length() * -(aabbColTest.normal))
						ent:collide({colEnt = checkEnt, normal = aabbColTest.normal})
						checkEnt:collide({colEnt = ent, normal = -aabbColTest.normal})
					end

				end
				
			end
			
			if ((ent.pos.x + ent.aabb.min.x) <= 0) then
				ent.vel.x = -ent.vel.x
				ent:setPos(ent.pos + point(-(ent.pos.x + ent.aabb.min.x), 0) ) 
				ent:collide({colEnt = nil, normal = point(1,0)})
			end
			
			if ((ent.pos.x + ent.aabb.max.x) >= screenSize.x) then
				ent.vel.x = -ent.vel.x
				ent:setPos(ent.pos + point(screenSize.x - (ent.pos.x + ent.aabb.max.x), 0) )
				ent:collide({colEnt = nil, normal = point(-1,0)})
			end
			
			if ((ent.pos.y + ent.aabb.min.y) <= 0) then
				ent.vel.y = -ent.vel.y
				ent:setPos(ent.pos + point(0,-(ent.pos.y + ent.aabb.min.y)) ) 
				ent:collide({colEnt = nil, normal = point(0,1)})
			end
			
			if ((ent.pos.y + ent.aabb.max.y) >= screenSize.y) then
				ent.vel.y = -ent.vel.y
				ent:setPos(ent.pos + point(0,screenSize.y - (ent.pos.y + ent.aabb.max.y)) )
				ent:collide({colEnt = nil, normal = point(0,-1)})
			end

			
		end
	
	end
	
end

function ents:__tostring()
	
	return "entCount: " .. tostring(#ents.entList)
	
end

