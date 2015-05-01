point = {}
point.mt = {}

point.__index = point

function point.mt:__call( nPx, nPy ) 
	
	local pnt = {}
	setmetatable(pnt, point)
	pnt.x = nPx
	pnt.y = nPy
	pnt.isPoint = true
	
	return pnt

end

function point:__sub(p2)
	
	return point(self.x - p2.x, self.y - p2.y)

end

function point:__add(p2)
	
	return point(self.x + p2.x, self.y + p2.y)

end

function point:__eq(p2)

	if (self.x == p2.x) and 
	   (self.y == p2.y) then
	   return true
	end
	
	return false

end

function point:__unm()
	
	return point(self.x * -1, self.y * -1)

end

function point:__mul(p2)
	
	if type(p2) == "table" then
		return point(self.x * p2.x, self.y * p2.y)
	else
		return point(self.x * p2, self.y * p2)
	end
	

end

function point:copy()

	return point(self.x, self.y)
	
end

function point:dist(p2)

	return math.sqrt( (p2.x - (self.x * self.x)) + (p2.y - (self.y * self.y)))

end

function point:length()
	
	return math.sqrt( ((self.x * self.x)) + ((self.y * self.y)))

end

function point:closerThan(p2, dist)

	local checkDist = dist * dist
	return  not (checkDist < (((p2.x - self.x)^2) + ((p2.y - self.y)^2)))

end

function point:normalize()
	
	local curLen = self:length()
	if curLen <=0 then
		return point(0,0)
	end
	
	self.x = self.x / curLen
	self.y = self.y / curLen
	
	return self
	
end

function point:dot(p2)

	return (self.x * p2.x) + (self.y * p2.y)

end

function point:rotate(angle, aroundPoint)
	
	aroundPoint = aroundPoint or point(0,0)

	sine = math.sin(math.rad(angle))
	cosine = math.cos(math.rad(angle))

	newPoint = point(cosine * (self.x - aroundPoint.x) -   sine * (self.y - aroundPoint.y) + aroundPoint.x, 
					   sine * (self.x - aroundPoint.x) + cosine * (self.y - aroundPoint.y) + aroundPoint.y)

	self.x = newPoint.x 
	self.y = newPoint.y 

	return newPoint

end

function point:__tostring()
	
	return "( " .. tostring(self.x) .. ", " .. tostring(self.y) .. " )"
	
end

setmetatable(point, point.mt)

