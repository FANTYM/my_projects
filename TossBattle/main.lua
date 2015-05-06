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

keyTimer = love.timer.getTime()
updateTimer = love.timer.getTime()
drawTimer = love.timer.getTime()
fpsTimer = love.timer.getTime()
lastTerrain = love.timer.getTime()

gameStates = { MENU = 0 , PLAY = 1, SCORES = 2, TERRAIN=3, curState = 0 }

screenSize = point(love.graphics.getWidth(), love.graphics.getHeight())
gameSize = point(math.floor(screenSize.x + (screenSize.x * 0.3)), screenSize.y)

basicShot = love.graphics.newImage("basic_shot.png")

viewInfo = viewInformation.new(point(0,0), gameSize, screenSize, 1)
--screenTween = tweenVal(point(0,0), point(0,0), 0)

terrain = love.graphics.newImage(love.image.newImageData(gameSize.x, gameSize.y))
sky = love.graphics.newImage(love.image.newImageData(gameSize.x, gameSize.y))

pixel.image = terrain
ents.collisionImage = terrain


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
	
	drawTimer = love.timer.getTime()
	drawDelta = love.timer.getTime() - drawTimer
	
	fpsCount = fpsCount + 1
	if love.timer.getTime() - fpsTimer >= 1 then
		curFPS = fpsCount - 1
		avgFPS = (avgFPS + curFPS) * 0.5
		fpsCount = 1
		fpsTimer = love.timer.getTime()
	end
	
	if gameStates.curState == gameStates.MENU then
		
		--font = love.graphics.getFont()
		love.graphics.setFont(titleFont)
		love.graphics.setColor(255,255,255,255)
		love.graphics.print(gameTitle, (screenSize.x * 0.5) - (titleFont:getWidth(gameTitle) * 0.5), (screenSize.y * 0.5) - (titleFont:getHeight(gameTitle)))
		love.graphics.print("Press [Enter] to play", (screenSize.x * 0.5) - (titleFont:getWidth("Press [Enter] to play") * 0.5), (screenSize.y * 0.5) + (titleFont:getHeight(gameTitle)))
		
	elseif gameStates.curState == gameStates.TERRAIN then
		
		local terrainText = "Generating Terrain"
		love.graphics.setFont(titleFont)
		love.graphics.setColor(255,255,255,255)
		love.graphics.print(terrainText, (screenSize.x * 0.5) - (titleFont:getWidth(terrainText) * 0.5), (screenSize.y * 0.5) - ((titleFont:getHeight(terrainText) * 2)))
		love.graphics.print("-..Please Wait..-", (screenSize.x * 0.5) - (titleFont:getWidth("-..Please Wait..-") * 0.5), (screenSize.y * 0.5) + (titleFont:getHeight(terrainText)))
	
	elseif gameStates.curState == gameStates.PLAY then
	
		love.graphics.setColor(255,255,255,255)		
		
		love.graphics.draw( sky    , viewInfo.pos.x(), viewInfo.pos.y(), 0, 1, 1, 0, 0, 0, 0)
		love.graphics.draw( terrain, viewInfo.pos.x(), viewInfo.pos.y(), 0, 1, 1, 0, 0, 0, 0)
		
		for _, ply in pairs(players) do
			
			ply:draw()
			
		end
		
		ents.draw()
		
		Flash.drawFlashes()
		
	elseif gameStates.curState == gameStates.SCORES then
		
		font = love.graphics.getFont()
		
		love.graphics.setColor(255 * textCycler:getValue() ,255 * (1 - textCycler:getValue()), 128 + (127 * textCycler:getValue()),255)
		love.graphics.print("Game Over", (screenSize.x * 0.5) - (font:getWidth("Game Over") * 0.5), 200)
		love.graphics.print("Press [Enter] to return to the menu", (screenSize.x * 0.5) - (font:getWidth("Press [Enter] to return to the menu") * 0.5), 330)
		
	end

end


function love.update(dt)

	curTime = love.timer.getTime()
	utDelta = love.timer.getTime() - updateTimer
	keyDelta = curTime - keyTimer

	if keys["escape"] then os.exit() end
	
	Cycler.runCycles()
	pixel.movePixels()
	ents.think()
	
	if gameStates.curState == gameStates.MENU then
	
		if keys["return"] and utDelta > 0.5 then
			gameStates.curState = gameStates.TERRAIN
			
		end
	
	elseif gameStates.curState == gameStates.TERRAIN then
		generateTerrain()
		--screenTween = tweenVal(0, -screenSize.x, 1)
		playerOne = player.new("Fantym", point(50,200), Color(255,0,0,255))
		players[curPly] = playerOne
		gameStates.curState = gameStates.PLAY
	elseif gameStates.curState == gameStates.PLAY then

		terrainDelta = love.timer.getTime() - lastTerrain
		if terrainDelta > 0.0333 then
				
			terrain:refresh()
			lastTerrain = love.timer.getTime()
		
		end
		if (keys["kp+"] or (keys["="] and (keys["lshift"] or keys["rshift"]) ) ) and (keyDelta >= keyRate) then
			keyTimer = love.timer.getTime()		
			players[curPly].power = players[curPly].power + 1
			if players[curPly].power > players[curPly].maxPower then
				players[curPly].power = players[curPly].maxPower
			end
		end
		
		if (keys["kp-"] or keys["-"]) and (keyDelta >= keyRate) then
			keyTimer = love.timer.getTime()		
			players[curPly].power = players[curPly].power - 1
			if players[curPly].power < 0 then
				players[curPly].power = 0
			end
		end
		
		if keys[" "] and (keyDelta >= (keyRate * 5)) then
			keyTimer = love.timer.getTime()		
			fireShot(players[curPly])
		end

		if keys["left"] and (keyDelta >= (keyRate * 3)) then
			moveRate = (moveRate + 25)
			
			viewInfo:setPos(viewInfo.pos + point(moveRate,0))
			
			keyTimer = love.timer.getTime()
		else
			moveRate = moveRate  * 0.999
		end
		
		if keys["right"] and (keyDelta >= (keyRate * 3))  then
			moveRate = (moveRate - 25)
			
			viewInfo:setPos(viewInfo.pos + point(moveRate,0))
			
			keyTimer = love.timer.getTime()		
		else
			moveRate = moveRate  * 0.999
		end
		
		if keys["up"] and (keyDelta >= (keyRate * 4)) then
						
			players[1].angle = players[1].angle - 5
			if players[1].angle < -90 then
				players[1].angle = -90
			end
			print(players[1].angle)
		
			keyTimer = love.timer.getTime()
			
		end
		
		if keys["down"] and (keyDelta >= (keyRate * 4))  then
			
			players[1].angle = players[1].angle + 5
			if players[1].angle > 90 then
				players[1].angle = 90
			end
			print(players[1].angle)

			keyTimer = love.timer.getTime()		
		end
		
		if (mouse["l"] and mouse["l"].down) and (keyDelta >= (keyRate * 4)) then

			keyTimer = love.timer.getTime()		
			
		end
		
	elseif gameStates.curState == gameStates.SCORES then
		
		if utDelta > 10 or (keys["return"] and utDelta > 1) then
			gameStates.curState = gameStates.MENU
			updateTimer = curTime
		end
		
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
	newShot = ents.newEntity("testShot" .. tostring(math.random()), shotPos, (shotPos - ply.pos):getNormal() * ply.power , 20, basicShot, 8, function() end, 
			function(self)
				doExplosion(self.pos, self.cRadius * 3, ply.power * self.mass, self.vel)
			end)
			newShot:setScale(0.25)

end

function doExplosion(where, radius, power, hitVel)
	
	print("Boom!")
	pixelCount = 0
	destroyPerc = 0.6
	deadCount = 0
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
							pixel(newPos , (diffVec + hitVel + point(0, -power)))
							
						end
					
					end
				end
			end
		end
	end
	--terrain:refresh()
	--print("pixels created: " .. tostring(pixelCount - deadCount))
	

end

function generateTerrain()
	
	terrainData = terrain:getData()
	
	function wipeFunc(x,y,r,g,b,a)
	
		return 0,0,0,0
		
	end
	
	terrainData:mapPixel(wipeFunc)
	
	
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
	
	terrainData:mapPixel(pix_func)
	
	function finalSmooth(x,y,r,g,b,a)
		
		if y > (terrainArray[x] - 1) then
			for i = -1, 1 do
				for u = -1, 1 do
					if (x + i) < terrainData:getWidth() - 1 and (x + i) > 0 then
						if (y + u) < terrainData:getHeight() - 1 and (y + u ) > 0 then
							nR,nG,nB,nA = terrainData:getPixel(x + i, y + u)
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
	
	terrainData:mapPixel(finalSmooth)
	
	--terrain:refresh()
	
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

