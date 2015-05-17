require "point"
require "pixel"
require "entity"
require "ents"
require "Color"
require "Cycler"
require "Flash"
require "tweenVal"
require "player"
require "viewInformation"
require "ImageScanner"
require "effect"

math.randomseed(os.time())

titleFont = love.graphics.newFont("differentiator.ttf", 20)
gameFont = love.graphics.newFont("differentiator.ttf", 10)
gameTitle = "Toss Battle"
players = {}
keys = {}
mouse = {}
curKey = "";
moveRate = 0
keyRate = 0.02
expPow = 50
fpsCount = 0
curFPS = 0
avgFPS = 0
curPly = 1
doDrop = false

physFPS = 100
physFPSStep = 1 / physFPS
physAccum = 0
physMax = physFPSStep * 1.5

keyTimer = love.timer.getTime()
mouseTimer = love.timer.getTime()
updateTimer = love.timer.getTime()
drawTimer = love.timer.getTime()
fpsTimer = love.timer.getTime()
lastTerrain = love.timer.getTime()

gameStates = { MENU = 0 , PLAY = 1, SCORES = 2, TERRAIN=3, curState = 0 }

screenSize = point(love.graphics.getWidth(), love.graphics.getHeight())
gameSize = point(math.floor(screenSize.x + (screenSize.x * 0.3)), screenSize.y)

tankFire = love.graphics.newImage("tank_fire.png")
basicShot = love.graphics.newImage("basic_shot.png")
explosion = love.graphics.newImage("explosion.png")

viewInfo = viewInformation.new(point(0,0), gameSize, screenSize, 1)
--screenTween = tweenVal(point(0,0), point(0,0), 0)

terrain = love.graphics.newImage(love.image.newImageData(gameSize.x, gameSize.y))
tData = terrain:getData()
sky = love.graphics.newImage(love.image.newImageData(gameSize.x, gameSize.y))

pixel.setImage(terrain)

ents.collisionImage = terrain

--
--terrainScan = ImageScanner.new(terrain, 1, 
--	function(x,y,clr)
--		if clr.a == 0 then
--			return true
--		end
--		return false
--	end,
--	function(x,y,clr,imgInfo)
--		for nY = y, 0, -1 do
--			pixel(point(x,nY), point(0,2))
--			--imgInfo.imgData:setPixel(x,nY, 0,0,0,0)
--		end
--	end)
--terrainScan:setUBounds(point(10,10))

colorPool = { Color(255,255,255,255),
  		      Color(255,  0,  0,255),
			  Color(  0,255,  0,255),
			  Color(  0,  0,255,255),
			  Color(255,255,  0,255),
			  Color(  0,255,255,255),
			  Color(255,  0,255,255),
			  Color(192,192,192,255),
			  Color(128,128,128,255),
			  Color(128,  0,  0,255),
			  Color(128,128,  0,255),
			  Color(  0,128,  0,255),
			  Color(128,  0,128,255),
			  Color(  0,128,128,255),
			  Color(  0,  0,128,255),
			  Color(240,128,128,255),
			  Color(255,140,  0,255),
			  Color(218,165, 32,255),
			  Color(189,183,107,255),
			  Color( 85,107, 47,255),
			  Color(124,252,  0,255),
			  Color(  0,100,  0,255),
			  Color(  0,250,154,255),
			  Color(102,205,170,255),
			  Color(  0,206,209,255),
			  Color(176,224,230,255),
			  Color( 70,130,180,255),
			  Color( 25, 25,112,255),
			  Color( 75,  0,130,255),
			  Color(123,104,238,255),
			  Color(255, 20,147,255),
			  Color(139, 69, 19,255),
			  Color(210,105, 30,255),
			  Color(222,184,135,255),
			  Color(176,196,222,255)
            }

function love.load()
	skyData = sky:getData()
	
	function makeSky(x,y,r,g,b,a)
		
		vertPerc = ( y / screenSize.y)
		b = 255 - (127 * vertPerc)
		g = 128 + ( 127 * (1 - vertPerc))
		a = 255
		
		return r,g,b,a
		
	end
	
	skyData:mapPixel(makeSky)
	
	sky:refresh()
	
end

function love.draw()
	
	drawDelta = love.timer.getTime() - drawTimer

	if gameStates.curState == gameStates.MENU then
	
		love.graphics.setFont(titleFont)
		love.graphics.setColor(255,255,255,255)
		love.graphics.print(gameTitle, (screenSize.x * 0.5) - (titleFont:getWidth(gameTitle) * 0.5), (screenSize.y * 0.5) - (titleFont:getHeight(gameTitle)))
		love.graphics.print("Press [Enter] to play", (screenSize.x * 0.5) - (titleFont:getWidth("Press [Enter] to play") * 0.5), (screenSize.y * 0.5) + (titleFont:getHeight(gameTitle)))
		effect.drawEffects(drawDelta)
		
	elseif gameStates.curState == gameStates.TERRAIN then
		
		local terrainText = "Generating Terrain"
		love.graphics.setFont(titleFont)
		love.graphics.setColor(255,255,255,255)
		love.graphics.print(terrainText, (screenSize.x * 0.5) - (titleFont:getWidth(terrainText) * 0.5), (screenSize.y * 0.5) - ((titleFont:getHeight(terrainText) * 2)))
		love.graphics.print("-..Please Wait..-", (screenSize.x * 0.5) - (titleFont:getWidth("-..Please Wait..-") * 0.5), (screenSize.y * 0.5) + (titleFont:getHeight(terrainText)))
		effect.drawEffects(drawDelta)
	
	elseif gameStates.curState == gameStates.PLAY then
		love.graphics.setColor(255,255,255,255)		
		love.graphics.draw( sky    , viewInfo.pos.x(), viewInfo.pos.y(), 0, 1, 1, 0, 0, 0, 0)
		love.graphics.draw( terrain, viewInfo.pos.x(), viewInfo.pos.y(), 0, 1, 1, 0, 0, 0, 0)

		for _, ply in pairs(players) do
			ply:draw(drawDelta)
		end
		
		ents.draw(drawDelta)
		pixel.drawPixels(drawDelta)
		Flash.drawFlashes(drawDelta)
		effect.drawEffects(drawDelta)
		
	elseif gameStates.curState == gameStates.SCORES then

		font = love.graphics.getFont()
		
		love.graphics.setColor(255 * textCycler:getValue() ,255 * (1 - textCycler:getValue()), 128 + (127 * textCycler:getValue()),255)
		love.graphics.print("Game Over", (screenSize.x * 0.5) - (font:getWidth("Game Over") * 0.5), 200)
		love.graphics.print("Press [Enter] to return to the menu", (screenSize.x * 0.5) - (font:getWidth("Press [Enter] to return to the menu") * 0.5), 330)
		
		effect.drawEffects(drawDelta)
		
	end
	
	drawTimer = love.timer.getTime()

end


function love.update(loveDelta)

	curTime = love.timer.getTime()
	updateDelta = love.timer.getTime() - updateTimer
	keyDelta = curTime - keyTimer
	mouseDelta = curTime - mouseTimer
	
	physAccum = physAccum + updateDelta

	if physAccum > physMax then physAccum = physMax end
	
	if keys["escape"] then os.exit() end
	
	if gameStates.curState == gameStates.MENU then
	
		if keys["return"] then
			gameStates.curState = gameStates.TERRAIN
		end
		
		if (mouse["l"] and mouse["l"].down) and (mouseDelta >= 0.5) then
			thisEff = effect.new("test", mouse.pos, point(0,0), tankFire, 5, {name = "", fCount = point(8,8), fps = 16, loop = false})
			thisEff.pos = thisEff.pos - point(0,64)
			keyTimer = love.timer.getTime()		
		end
	
	elseif gameStates.curState == gameStates.TERRAIN then

		generateTerrain()
		playerOne = player.new("Fantym", point(50,200), Color(255,0,0,255))
		players[curPly] = playerOne
		gameStates.curState = gameStates.PLAY
		
	elseif gameStates.curState == gameStates.PLAY then
		
		terrainDelta = love.timer.getTime() - lastTerrain
		if terrainDelta > 0.0333 then
				
			terrain:refresh()
			lastTerrain = love.timer.getTime()
		
		end
		
		if physAccum > physFPSStep then
			Cycler.runCycles(physFPSStep)
			pixel.movePixels(physFPSStep)
			ents.think(physFPSStep)
			physAccum = physAccum - physFPSStep
		end
		
		-- Increase Power
		if (keys["kp+"] or (keys["="] and (keys["lshift"] or keys["rshift"]) ) ) and (keyDelta >= keyRate) then
			players[curPly].power = players[curPly].power + 1
			if players[curPly].power > players[curPly].maxPower then
				players[curPly].power = players[curPly].maxPower
			end
			keyTimer = love.timer.getTime()		
		end
		
		-- Decrease Power
		if (keys["kp-"] or keys["-"]) and (keyDelta >= keyRate) then
			players[curPly].power = players[curPly].power - 1
			if players[curPly].power < 0 then
				players[curPly].power = 0
			end
			keyTimer = love.timer.getTime()
		end
		-- Fire!!!
		if keys[" "] and (keyDelta >= 0.5) then
			fireShot(players[curPly])
			keyTimer = love.timer.getTime()		
		end
		
		-- Scroll View Right
		if keys["left"] and (keyDelta >= (keyRate * 3)) then
			moveRate = (moveRate + 25)
			viewInfo:setPos(viewInfo.pos + point(moveRate,0))
			keyTimer = love.timer.getTime()
		else
			moveRate = moveRate  * 0.999
		end
		
		-- Scroll View Left
		if keys["right"] and (keyDelta >= (keyRate * 3))  then
			moveRate = (moveRate - 25)
			viewInfo:setPos(viewInfo.pos + point(moveRate,0))
			keyTimer = love.timer.getTime()		
		else
			moveRate = moveRate  * 0.999
		end
		
		-- Decrease Angle of shot
		if keys["up"] and (keyDelta >= (keyRate * 4)) then
			players[1].angle = players[1].angle - 1
			if players[1].angle < -90 then
				players[1].angle = -90
			end
			print(players[1].angle)
			keyTimer = love.timer.getTime()
		end
		
		-- Increase Angle of shot
		if keys["down"] and (keyDelta >= (keyRate * 4))  then
			players[1].angle = players[1].angle + 1
			if players[1].angle > 90 then
				players[1].angle = 90
			end
			print(players[1].angle)
			keyTimer = love.timer.getTime()		
		end
		
		-- Test mouse click, makes explosion effect
		if (mouse["l"] and mouse["l"].down) and (keyDelta >= (keyRate * 4)) then
			effect.new("test3", mouse.pos, point(0,-20), explosion, -1, {name = "", fCount = point(13,1), fps = 20, loop = false})
			keyTimer = love.timer.getTime()		
		end
		
	elseif gameStates.curState == gameStates.SCORES then
		
		if utDelta > 10 or (keys["return"] and utDelta > 1) then
			gameStates.curState = gameStates.MENU
			updateTimer = curTime
		end
		
	end
	
	if keys["d"] and (keyDelta >= (keyRate * 4)) then
		
		print("**************** Debug Print *************************")
		print("")
		print("Effect Count: " .. tostring(effect.count()))
		print("Pixel Count: " .. tostring(pixel.count()))
		print("FPS: " .. tostring(curFPS))
		print("avgFPS: " .. tostring(avgFPS))
		print("******************************************************")
		
		keyTimer = love.timer.getTime()
	end
	
end

function love.keypressed( key )
   
  keys[key] = true 
  print(key .. " pressed.")
   
end

function love.keyreleased( key )
   
   keys[key] = false
   print(key .. " released.")
  
end

function love.mousepressed( x, y, button )
	print("Mouse " .. tostring(button) .. " is down")
	
	if not mouse[button] then
		mouse[button] = {}
	end
	mouse[button].down = true
	mouse[button].pos = point(x,y)
	
end

function love.mousereleased( x, y, button )
	print("Mouse " .. tostring(button) .. " is up")
	if not mouse[button] then
		mouse[button] = {}
	end
	mouse[button].down = false
	mouse[button].pos = point(x,y)
	

end

function love.mousemoved( x, y, dx, dy )
	--print("Mouse has moved")
	mouse.pos = point(x,y)
	mouse.delta = point(dx,dy)
	
end

function fireShot(ply)
	
	shotPos = ply.pos + point(math.sin(math.rad(-ply.angle)) * -16, math.cos(math.rad(-ply.angle)) * -16)
	newShot = ents.newEntity("testShot" .. tostring(math.random()), shotPos, (shotPos - ply.pos):getNormal() * ply.power, basicShot, nil, function() end, 
			function(self)
				doExplosion(self.pos, self.cRadius * 2, newShot.mass * 3, self.vel)
			end)
			newShot:setScale(0.25)

end

function doExplosion(where, radius, power, hitVel)
	
	print("Boom!")
	pixelCount = 0
	destroyPerc = 0.6
	deadCount = 0
	thisBoom = effect.new("exp" .. tostring(where), where, hitVel, explosion, -1, {name = "", fCount = point(13,1), fps = 20, loop = false})
	thisBoom:setScale(0.5)
	for y = -radius, radius do
		for x = -radius, radius do
			newPos = where + point(x,y)
			if where:closerThan(newPos, radius) then
				if pixel.inImage(nil, newPos) then
					pixelCount = pixelCount + 1
					if deadCount / pixelCount < destroyPerc then
						terrain:getData():setPixel(newPos.x, newPos.y, 0,0,0,0)
						deadCount = deadCount  + 1
						--terrain:refresh()
					else
						
						r,g,b,a = terrain:getData():getPixel(newPos.x, newPos.y)
						if not (a == 0) then
							--diffVec = where - newPos
							diffVec = newPos - where
							diffVec:normalize()
							diffVec = diffVec * (power + (math.random() * (power * 0.5)))
							pixel(newPos , (diffVec + hitVel)) --- + point(0, -power)))
							
						end
					
					end
				end
			end
		end
	end
	--terrainScan:doRuns()
	doDrop = true
	--terrain:refresh()
	--print("pixels created: " .. tostring(pixelCount - deadCount))
	

end

function generateTerrain()
	
	
	function wipeFunc(x,y,r,g,b,a)
	
		return 0,0,0,0
		
	end
	
	tData:mapPixel(wipeFunc)
	
	
	terrainArray = {}
	
	for x = 0, gameSize.x - 1 do
		
		terrainArray[x] = math.floor(math.random() * (gameSize.y * (0.2 + (math.random() * 0.3))))
		terrainArray[x] = (terrainArray[x] * 2) + (math.cos(math.rad(x * 100)) * (-15 + (math.random() * 30)))
		
		
		terrainArray[x] = terrainArray[x] + (math.sin(-1) * (-25 + (math.random() * 50)))
		
		
	end
	
	
	
	for s = 0, 25 + (math.random() * 25) do
		
		for p = 0, 5 + (math.random() * 25) do
		
			for x = 1, gameSize.x - 2 do
					
				terrainArray[x - 1] = (terrainArray[x] + terrainArray[x + 1]) * 0.5
			
			end
			
		end 
		
		for x = 0, gameSize.x - 1 do
			
			prevX = x - 1
			nextX = x + 1
			if prevX < 0 then
				prevX = prevX + (gameSize.x  - 1)
			end
			
			if nextX > gameSize.x - 1 then
				nextX = nextX - (gameSize.x - 1)
			end
			--print(prevX)
			--print(x)
			--print(nextX)
			terrainArray[x] = (terrainArray[prevX] + terrainArray[x] + terrainArray[nextX]) / 3
		end
		
		
	end
	
	function pix_func(x,y,r,g,b,a)
		newPerc = 0
		if y > gameSize.y - terrainArray[x] then
			finPerc = (gameSize.y - y) / terrainArray[x]
			finPerc = (finPerc + (math.random() * (finPerc * 0.2))) * 0.5
			if finPerc > 0.5 then
				newPerc = (newPerc + (finPerc - 0.5) / 0.5) * 0.5
				g = 128 + (127 * (newPerc))
				r = 64 * (1 - newPerc)
				a = 255
			else
				g = 128 * finPerc
				r = 196 * finPerc
				a = 255
			end
		else	
			a=0
		end
		
		return r,g,b,a
		
	end
	
	tData:mapPixel(pix_func)
	
	function finalSmooth(x,y,r,g,b,a)
		
		if y > (terrainArray[x] - 1) then
			for i = -1, 1 do
				for u = -1, 1 do
					if (x + i) < tData:getWidth() - 1 and (x + i) > 0 then
						if (y + u) < tData:getHeight() - 1 and (y + u ) > 0 then
							nR,nG,nB,nA = tData:getPixel(x + i, y + u)
							r = (r + nR) * 0.5
							g = (g + nG) * 0.5
							b = (b + nB) * 0.5
							a = (a + nA) * 0.5
						end
					end
				end
			end
		end
		
		return r,g,b,a
		
	end
	
	tData:mapPixel(finalSmooth)
	
	terrain:refresh()
	
end


function valueInTable(tab, val)

	for i = 1, #tab do
		
		if tab[i] == val then
			return true
		end
		
	end
	
	return false
end

function clamp(inNum, minNum, maxNum)
	
	local retNum = inNum
	
	if inNum < minNum then
		retNum = minNum
	end
	if inNum > maxNum then
		retNum = maxNum
	end
	
	return retNum
	
end

