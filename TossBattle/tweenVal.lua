tweenVal = {}
tweenVal.mt = {}

tweenVal.__index = tweenVal

function tweenVal.mt:__call( nStartVal, nEndVal, nTimeToArrive ) 
	
	local tv = {}
	setmetatable(tv, tweenVal)
	tv.created = love.timer.getTime()
	tv.TTL = nTimeToArrive
	tv.percent = 0
	tv.startVal = nStartVal
	tv.endVal = nEndVal
	tv.curVal = 0 --(tv.startVal * (1 - tv.percent)) + (tv.endVal * (tv.percent))
	tv.isDone = false
	tv:update()
	
	return tv

end

function tweenVal:__call( nStart, nEnd, nTime)
	--print(self)
	if not (nStart == nil) then
		self.startVal = nStart
		self.endVal = nEnd
		self.TTL = nTime
		self.created = love.timer.getTime()
		self.isDone = false
	end
	self:update()
	--print(self)
	return self.curVal

end

function tweenVal:timeLeft()
	
	return self.TTL - (love.timer.getTime() - self.created)

end

function tweenVal:update()
	
	self.percent = self.clamp( ((love.timer.getTime() - self.created) / self.TTL) , 0 , 1 )
	
	if self.percent == 1 then self.isDone = true end
	
	self.curVal = (self.startVal * (1 - self.percent)) + (self.endVal * (self.percent))
	
end

function tweenVal:__sub(num)
	
	self:update()
	return self.curVal - num

end

function tweenVal:__add(num)
	
	self:update()
	return self.curVal + num

end

function tweenVal:__eq(num)

	self:update()
	
	return (num == self.curVal)

end

function tweenVal:__unm()
	
	self:update()
	
	return -self.curVal

end

function tweenVal:__mul(num)
	
	self:update()	
	
	return (self.curVal * num)
	
end

function tweenVal:copy()

	local tv = {}
	setmetatable(tv, tweenVal)
	tv.created = tonumber(self.created)
	tv.TTL = tonumber(self.TTL)
	tv.percent = tonumber(self.percent)
	tv.startVal = tonumber(self.startVal)
	tv.endVal = tonumber(self.endVal)
	tv.curVal = tonumber(self.curVal)
	tv.isDone = (self.isDone == true)
	
	return tv 
	
end

function tweenVal.clamp(inNum, minNum, maxNum)
	
	local retNum = inNum
	
	if inNum < minNum then
		retNum = minNum
	end
	if inNum > maxNum then
		retNum = maxNum
	end
	
	return retNum
	
end

function tweenVal:__tostring()
	
	return "( " .. tostring(self.startVal) .. " - " .. tostring(self.curVal) .. " - " .. tostring(self.endVal) .. " )"
	
end

setmetatable(tweenVal, tweenVal.mt)

