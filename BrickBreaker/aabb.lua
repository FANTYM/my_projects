AABB = {}
AABB.__index = AABB
function AABB.new(pPos, pSize) 
	
	--hWidth = pWidth / 2
	--hHeight = pHeight / 2
	
	newAABB = {}
	setmetatable(newAABB, AABB)
	newAABB.pos = pPos
	newAABB.min = point(-(pSize.x * 0.5), -(pSize.y * 0.5))
	newAABB.max = point((pSize.x * 0.5), (pSize.y * 0.5))
	newAABB.size = pSize
	
	return newAABB
	
	
end

function AABB:getMin()
	return self.pos + self.min
end

function AABB:getMax()
	return self.pos + self.max
end


function AABB:minkowskiDiff(otherAABB)

	local topLeft = self:getMin() - otherAABB:getMax()
	local fullSize = (self.size + otherAABB.size ) 
	
	return AABB.new(topLeft + (fullSize * 0.5), fullSize) 

end

function AABB:closePointOnBounds(checkPos)

	local minDist = math.abs(checkPos.x - self.min.x)
	local boundPoint = point(self.min.x, checkPos.y)
	
	if math.abs(self.max.x - checkPos.x) < minDist then
		minDist = math.abs(self.max.x - checkPos.x)
		boundPoint = point(self.max.x, checkPos.y)
	end
	if math.abs(self.max.y - checkPos.y) < minDist then
		minDist = math.abs(self.max.y - checkPos.y)
		boundPoint = point(checkPos.x,self.max.y)
	end
	if math.abs(self.min.y - checkPos.y) < minDist then
		minDist = math.abs(self.min.y - checkPos.y)
		boundPoint = point(checkPos.x, self.min.y)
    end
	
	return boundPoint

end

function AABB:pointInside(checkPos)
	
	if (checkPos.x >= (self.min.x)) and
	   (checkPos.x <= (self.max.x)) and
	   (checkPos.y >= (self.min.y)) and
	   (checkPos.y <= (self.max.y)) then
			return true
	end
	
	return false
	
end