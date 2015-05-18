require "entity"

ents = {}
ents.entList = {}
ents.nextID = 0
ents.lastThink = love.timer.getTime()
ents.__index = ents
ents.gravity = gravity
ents.collisionImage = ""


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

function ents.draw(physAlpha)

	for k, ent in pairs(ents.entList) do 
		
		if not (ent == nil) then
			
			ent:draw(physAlpha)
			
		end
	
	end

end

--/**
-- adapting from site http://www.euclideanspace.com/physics/dynamics/collision/twod/
--This function calulates the velocities after a 2D collision ent1FinalVel, ent2FinalVel, ent1FinalAngVel and ent2FinalAngVel from information about the colliding bodies
--@param double coeffOfRest coefficient of restitution which depends on the nature of the two colliding materials
--@param double ent1Mass total mass of body a
--@param double ent2Mass total mass of body b
--@param double ent1Inertia inertia for body a.
--@param double ent2Inertia inertia for body b.
--@param vector colPosEnt1 position of collision point relative to centre of mass of body a in absolute coordinates (if this is
--                 known in local body coordinates it must be converted before this is called).
--@param vector colPosEnt2 position of collision point relative to centre of mass of body b in absolute coordinates (if this is
--                 known in local body coordinates it must be converted before this is called).
--@param vector colNorm normal to collision point, the line along which the impulse acts.
--@param vector ent1Vel initial velocity of centre of mass on object a
--@param vector ent2Vel initial velocity of centre of mass on object b
--@param vector ent1AngVel initial angular velocity of object a
--@param vector ent2AngVel initial angular velocity of object b
--@param vector ent1FinalVel final velocity of centre of mass on object a
--@param vector ent2FinalVel final velocity of centre of mass on object a
--@param vector ent1FinalAngVel final angular velocity of object a
--@param vector ent2FinalAngVel final angular velocity of object b
--*/
--CollisionResponce(double coeffOfRest,double ent1Mass,double ent2Mass,matrix ent1Inertia,matrix ent2Inertia,vector colPosEnt1,vector colPosEnt2,vector colNorm, vector ent1Vel, vector ent2Vel, vector ent1AngVel, vector ent2AngVel, vector ent1FinalVel, vector ent2FinalVel, vector ent1FinalAngVel, vector ent2FinalAngVel) {
--  double k=1/(ent1Mass*ent1Mass)+ 2/(ent1Mass*ent2Mass) +1/(ent2Mass*ent2Mass) - colPosEnt1.x*colPosEnt1.x/(ent1Mass*ent1Inertia) - colPosEnt2.x*colPosEnt2.x/(ent1Mass*ent2Inertia)  - colPosEnt1.y*colPosEnt1.y/(ent1Mass*ent1Inertia)
--    - colPosEnt1.y*colPosEnt1.y/(ent2Mass*ent1Inertia) - colPosEnt1.x*colPosEnt1.x/(ent2Mass*ent1Inertia) - colPosEnt2.x*colPosEnt2.x/(ent2Mass*ent2Inertia) - colPosEnt2.y*colPosEnt2.y/(ent1Mass*ent2Inertia)
--    - colPosEnt2.y*colPosEnt2.y/(ent2Mass*ent2Inertia) + colPosEnt1.y*colPosEnt1.y*colPosEnt2.x*colPosEnt2.x/(ent1Inertia*ent2Inertia) + colPosEnt1.x*colPosEnt1.x*colPosEnt2.y*colPosEnt2.y/(ent1Inertia*ent2Inertia) - 2*colPosEnt1.x*colPosEnt1.y*colPosEnt2.x*colPosEnt2.y/(ent1Inertia*ent2Inertia);
--  double Jx = (coeffOfRest+1)/k * (ent1Vel.x - ent2Vel.x)( 1/ent1Mass - colPosEnt1.x*colPosEnt1.x/ent1Inertia + 1/ent2Mass - colPosEnt2.x*colPosEnt2.x/ent2Inertia)
--     - (coeffOfRest+1)/k * (ent1Vel.y - ent2Vel.y) (colPosEnt1.x*colPosEnt1.y / ent1Inertia + colPosEnt2.x*colPosEnt2.y / ent2Inertia);
--  double Jy = - (coeffOfRest+1)/k * (ent1Vel.x - ent2Vel.x) (colPosEnt1.x*colPosEnt1.y / ent1Inertia + colPosEnt2.x*colPosEnt2.y / ent2Inertia)
--    + (coeffOfRest+1)/k  * (ent1Vel.y - ent2Vel.y) ( 1/ent1Mass - colPosEnt1.y*colPosEnt1.y/ent1Inertia + 1/ent2Mass - colPosEnt2.y*colPosEnt2.y/ent2Inertia);
--  ent1FinalVel.x = ent1Vel.x - Jx/ent1Mass;
--  ent1FinalVel.y = ent1Vel.y - Jy/ent1Mass;
--  ent2FinalVel.x = ent2Vel.x - Jx/ent2Mass;
--  ent2FinalVel.y = ent2Vel.y - Jy/ent2Mass;
--  ent1FinalAngVel.x = ent1AngVel.x - (Jx*colPosEnt1.y - Jy*colPosEnt1.x) /ent1Inertia;
--  ent1FinalAngVel.y = ent1AngVel.y - (Jx*colPosEnt1.y - Jy*colPosEnt1.x) /ent1Inertia;
--  ent2FinalAngVel.x = ent2AngVel.x - (Jx*colPosEnt2.y - Jy*colPosEnt2.x) /ent2Inertia;
--  ent2FinalAngVel.y = ent2AngVel.y - (Jx*colPosEnt2.y - Jy*colPosEnt2.x) /ent2Inertia;
--}

function ents.CollisionResponse(coeffOfRest, ent1, ent2, colPos)
    ent1Mass = ent1.mass
	ent2Mass = ent2.mass
	ent1Inertia = ent1.inertia
	ent2Inertia = ent2.inertia
	colPosEnt1 = ent1.pos - colPos
	colPosEnt2 = ent2.pos - colPos
	colNorm = point(0,0)
	ent1Vel = ent1.vel
	ent2Vel = ent2.vel
	ent1AngVel = ent1.angVel
	ent2AngVel = ent2.angVel
	ent1FinalVel = point(0,0)
	ent2FinalVel = point(0,0)
	ent1FinalAngVel = 0
	ent2FinalAngVel = 0
	
	k = 1 / (ent1Mass * ent1Mass) + 2 / (ent1Mass * ent2Mass) + 1 / (ent2Mass * ent2Mass) - colPosEnt1.x * colPosEnt1.x / (ent1Mass * ent1Inertia) 
	k = k - colPosEnt2.x * colPosEnt2.x / (ent1Mass * ent2Inertia) - colPosEnt1.y * colPosEnt1.y / (ent1Mass * ent1Inertia) 
	k = k - colPosEnt1.y * colPosEnt1.y / (ent2Mass * ent1Inertia) - colPosEnt1.x * colPosEnt1.x / (ent2Mass * ent1Inertia) 
	k = k - colPosEnt2.x * colPosEnt2.x / (ent2Mass * ent2Inertia) - colPosEnt2.y * colPosEnt2.y / (ent1Mass * ent2Inertia) 
	k = k - colPosEnt2.y * colPosEnt2.y / (ent2Mass * ent2Inertia) + colPosEnt1.y * colPosEnt1.y * colPosEnt2.x * colPosEnt2.x / (ent1Inertia * ent2Inertia)
    k = k + colPosEnt1.x * colPosEnt1.x * colPosEnt2.y * colPosEnt2.y / (ent1Inertia * ent2Inertia) 
	k = k - 2 * colPosEnt1.x * colPosEnt1.y * colPosEnt2.x * colPosEnt2.y / (ent1Inertia * ent2Inertia)
	
	Jx = (coeffOfRest + 1) / k * (ent1Vel.x - ent2Vel.x) + (1 / ent1Mass - colPosEnt1.x * colPosEnt1.x / ent1Inertia + 1 / ent2Mass - colPosEnt2.x * colPosEnt2.x / ent2Inertia)
	Jx = Jx - (coeffOfRest + 1) / k * (ent1Vel.y - ent2Vel.y) + (colPosEnt1.x * colPosEnt1.y / ent1Inertia + colPosEnt2.x * colPosEnt2.y / ent2Inertia)
	Jy = -(coeffOfRest+1) / k * (ent1Vel.x - ent2Vel.x) + (colPosEnt1.x * colPosEnt1.y / ent1Inertia + colPosEnt2.x * colPosEnt2.y / ent2Inertia) 
	Jy = Jy + (coeffOfRest + 1) / k  * (ent1Vel.y - ent2Vel.y) + ( 1 / ent1Mass - colPosEnt1.y * colPosEnt1.y / ent1Inertia + 1 / ent2Mass - colPosEnt2.y * colPosEnt2.y / ent2Inertia)
	
	ent1FinalVel = point(ent1Vel.x - Jx / ent1Mass, ent1Vel.y - Jy / ent1Mass)
	ent2FinalVel = point(ent2Vel.x - Jx / ent2Mass, ent2Vel.y - Jy / ent2Mass)
	ent1FinalAngVel = point(ent1AngVel.x - (Jx * colPosEnt1.y - Jy * colPosEnt1.x) / ent1Inertia, ent1AngVel.y - (Jx * colPosEnt1.y - Jy * colPosEnt1.x) / ent1Inertia)
	ent2FinalAngVel = point(ent2AngVel.x - (Jx * colPosEnt2.y - Jy * colPosEnt2.x) / ent2Inertia, ent2AngVel.y - (Jx * colPosEnt2.y - Jy * colPosEnt2.x) / ent2Inertia)

	ent1.vel = ent1FinalVel
	ent1.angVel = ent1FinalAngVel
	ent2.vel = ent2FinalVel
	ent2.angVel = ent2FinalAngVel

--}
end

function ents.think(updateDelta)
	
	local thinkDelta = updateDelta --love.timer.getTime() - ents.lastThink
	--ents.lastThink = love.timer.getTime()
	
	for k, ent in pairs(ents.entList) do 
		
		if not (ent == nil) then
		
			ent:think(updateDelta)
				
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

