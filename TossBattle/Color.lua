Color = {}
Color.mt = {}

Color.__index = Color

function Color.clamp(inNum, minNum, maxNum)
	
	local retNum = inNum
	
	if inNum < minNum then
		retNum = minNum
	end
	if inNum > maxNum then
		retNum = maxNum
	end
	
	return retNum
	
end

function Color.mt:__call(red,green,blue,alpha) 
	
	local clr = {}
	setmetatable(clr, Color)
	clr.r = red
	clr.g = green
	clr.b = blue
	clr.a = alpha
	
	return clr

end

function Color:__sub(clr2)
	
	newClr = Color(self.r - clr2.r, self.g - clr2.g, self.b - clr2.b, self.a - clr2.a)
	
	newClr.r = Color.clamp(newClr.r, 0,255)
	newClr.g = Color.clamp(newClr.g, 0,255)
	newClr.b = Color.clamp(newClr.b, 0,255)
	newClr.a = Color.clamp(newClr.a, 0,255)
	
	return newClr

end

function Color:__add(clr2)
	
	newClr = Color(self.r + clr2.r, self.g + clr2.g, self.b + clr2.b, self.a + clr2.a)
	
	newClr.r = Color.clamp(newClr.r, 0,255)
	newClr.g = Color.clamp(newClr.g, 0,255)
	newClr.b = Color.clamp(newClr.b, 0,255)
	newClr.a = Color.clamp(newClr.a, 0,255)
	
	return newClr


end

function Color:__eq(clr2)

	if (self.r == clr2.r) and 
	   (self.g == clr2.g) and
	   (self.b == clr2.b) and
	   (self.a == clr2.a) then
	   return true
	end
	
	return false

end

function Color:__unm()
	
	newClr = Color(self.a - self.r, self.a - self.g, self.a - self.b, self.a)
	
	newClr.r = Color.clamp(newClr.r, 0,255)
	newClr.g = Color.clamp(newClr.g, 0,255)
	newClr.b = Color.clamp(newClr.b, 0,255)
	newClr.a = Color.clamp(newClr.a, 0,255)
	
	return newClr

end

function Color:__mul(clr2)
	
	if type(clr2) == "table" then
		
		newClr = Color(self.r * clr2.r, self.g * clr2.g, self.b * clr2.b, self.a * clr2.a)
		
		newClr.r = Color.clamp(newClr.r, 0,255)
		newClr.g = Color.clamp(newClr.g, 0,255)
		newClr.b = Color.clamp(newClr.b, 0,255)
		newClr.a = Color.clamp(newClr.a, 0,255)
		
		return newClr
		
	else

		newClr = Color(self.r * clr2, self.g * clr2, self.b * clr2, self.a * clr2)
	
		newClr.r = Color.clamp(newClr.r, 0,255)
		newClr.g = Color.clamp(newClr.g, 0,255)
		newClr.b = Color.clamp(newClr.b, 0,255)
		newClr.a = Color.clamp(newClr.a, 0,255)
		
		return newClr
		
	end
	

end

function Color:copy()
	
	return Color(self.r, self.g, self.b, self.a)

end

function Color:__tostring()
	
	return "( " .. tostring(self.r) .. ", " .. tostring(self.g) .. ", " .. tostring(self.b) .. ", " .. tostring(self.a) .. " )"
	
end

setmetatable(Color, Color.mt)

