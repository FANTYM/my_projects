AABB = {}
AABB.__index = AABB
function AABB.new(pPos, pWidth, pHeight) 
	
	hWidth = pWidth / 2
	hHeight = pHeight / 2
	
	newAABB = {}
	setmetatable(newAABB, AABB)
	newAABB.pos = pPos
	newAABB.min = point(-(pWidth * 0.5), -(pHeight * 0.5))
	newAABB.max = point((pWidth * 0.5), (pHeight * 0.5))
	newAABB.size = point(pWidth, pHeight)
	--newAABB.width = pWidth
	--newAABB.height = pHeight
	
	return newAABB
	
	
end

function AABB:setPos(nPos)
	
	self.pos = pPos
	self.min = point(-(self.size.x * 0.5), -(self.size.y * 0.5))
	self.max = point((self.size.x * 0.5), (self.size.y * 0.5))
	
end

function AABB:minkowskiDiff(otherAABB)
	
	local topLeft = self.min - otherAABB.max
	local fullSize = (self.size + otherAABB.size ) * 0.5
	
	return AABB.new(topLeft + fullSize, fullSize.x, fullSize.y) 

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