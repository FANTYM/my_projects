Flash = {}
Flash.__index = Flash
Flash.curID = 0
Flash.flashes = {}

function Flash.new(TTL, startColor, endColor)
	
	local newFlash = {}
	setmetatable(newFlash, Flash)
	newFlash.TTL = TTL
	newFlash.startColor = startColor
	newFlash.endColor = endColor
	newFlash.created = love.timer.getTime()
	newFlash.id = Flash.curID
	
	Flash.flashes[Flash.curID] = newFlash
	Flash.curID = Flash.curID + 1
	
	return newFlash
	
end

function Flash.drawFlashes()
	
	for k,v in pairs(Flash.flashes) do
		
		if v then
			flashDelta = love.timer.getTime() - v.created
			flashPerc = flashDelta / v.TTL
			love.graphics.setColor((v.startColor.r * (1 - flashPerc)) + (v.endColor.a * flashPerc), 
								   (v.startColor.g * (1 - flashPerc)) + (v.endColor.g * flashPerc),
								   (v.startColor.b * (1 - flashPerc)) + (v.endColor.b * flashPerc),
								   (v.startColor.a * (1 - flashPerc)) + (v.endColor.a * flashPerc) )
			love.graphics.rectangle( "fill", 0, 0, screenSize.x, screenSize.y)
			if flashDelta > v.TTL then
				v:destroy()
				print("destroy " .. tostring(v))
			end
		end
	
	
	end

end


function Flash:destroy()
		
	Flash.flashes[self.id] = nil
	
end

