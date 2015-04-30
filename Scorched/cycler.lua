Cycler = {}
Cycler.__index = Cycler
Cycler.curID = 0
Cycler.cyclers = {}

function Cycler.new(rate, startValue, lowerBound, upperBound, loop, goingUp)
	
	local newCycler = {}
	setmetatable(newCycler, Cycler)
	newCycler.rate = rate
	newCycler.cycle = loop
	newCycler.goingUp = goingUp
	newCycler.value = startValue
	newCycler.lBound = lowerBound
	newCycler.uBound = upperBound
	newCycler.lastRun = love.timer.getTime()
	newCycler.id = Cycler.curID
	
	Cycler.cyclers[Cycler.curID] = newCycler
	Cycler.curID = Cycler.curID + 1
	
	return newCycler
	
end

function Cycler.runCycles()
	
	for k,v in pairs(Cycler.cyclers) do
		
		v:think()
	
	end

end


function Cycler:destroy()
		
	table.remove(Cycler.cyclers, self.id)
	
end

function Cycler:getValue()
	
	--self:think()
	return self.value
	
end

function Cycler:think()
	
	local deltaTime = love.timer.getTime() - self.lastRun
	self.lastRun = love.timer.getTime()
	
	if self.cycle then
		if self.goingUp then
			self.value = self.value + (self.rate * deltaTime)
			if self.value >= self.uBound then
				self.value = self.uBound
				self.goingUp = false
			end
		else
			self.value = self.value - (self.rate * deltaTime)
			if self.value <= self.lBound then
				self.value = self.lBound
				self.goingUp = true
			end
		end
	else
		if self.goingUp then
			self.value = self.value + (self.rate * deltaTime)
			if self.value >= self.uBound then
				self.value = self.lBound
				--Cycler.goingUp = false
			end
		else
			self.value = self.value - (self.rate * deltaTime)
			if self.value <= self.lBound then
				self.value = self.uBound
				--Cycler.goingUp = true
			end
		end
	end
	
	
end