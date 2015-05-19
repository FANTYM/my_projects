keys = {}
keys.mt = {}
keys.keyTable = {}
keys.defaultRepeat = 0.25
keys.keyStack = {}

function keys.newKey(k, repeatRate, pressed)
	
	curKey = {}
	curKey.pressed = pressed or false
	curKey.lastPress = love.timer.getTime() - 10
	curKey.repeatRate = repeatRate
	curKey.func = function() end
	keys.keyTable[k] = curKey

	return curKey
	
end

function keys.registerEvent(k, func)
	
	curKey = keys.keyTable[k] or keys.newKey(k, keys.defaultRepeat)
	
	curKey.func = func

end

function keys:getKeyInfo(k)

	curKey = keys.keyTable[k] or keys.newKey(k, keys.defaultRepeat)
	
	return curKey

end

function keys:setKeyRate(k, rate)
	
	curKey = keys.keyTable[k] or keys.newKey(k, keys.defaultRepeat)
	
	curKey.repeatRate = rate

end


function keys:press(k)
	
	curKey = keys.keyTable[k] or keys.newKey(k, keys.defaultRepeat)
	
	if love.timer.getTime() - curKey.lastPress > curKey.repeatRate then
	
		curKey.pressed = true
		curKey.func()
		curKey.lastPress = love.timer.getTime()
		
	end
	
	

end

function keys:release(k)
	
	curKey = keys.keyTable[k] or keys.newKey(k, keys.defaultRepeat)
	
	curKey.pressed = false

end


setmetatable(keys, keys.mt)