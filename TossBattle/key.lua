key = {}
key.__index = key
key.mt = {}

function key.mt:__call(strKey)
	
	newKey = {}
	setmetatable(newKey, key)
	newKey.pressed = false
	newKey.lastPress = love.timer.getTime()
	
	return newKey
	

end

function key:__lt(timeCheck)
	
	return (( self.pressed ) and ((love.timer.getTime() - self.lastPress) < timeCheck))
	
end

function key:press()

	self.pressed = true
	self.lastPress = love.timer.getTime()

end


function key:release()
	
	self.pressed = false

end


setmetatable(key, key.mt)