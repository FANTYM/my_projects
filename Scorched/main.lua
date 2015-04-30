require "point"
require "Color"
require "Cycler"
require "Flash"

math.randomseed(os.time())

keys = {}
curKey = "";
keyRate = 0.02
keyTimer = love.timer.getTime()
screenSize = point(love.graphics.getWidth(), love.graphics.getHeight())
gameSize = point(screenSize.x * 2, screenSize.y)
viewPos = point(0,0)
gameStates = { MENU = 0 , PLAY = 1, SCORES = 2, curState = 0 }
terrain = love.graphics.newImage(love.image.newImageData(gameSize.x, gameSize.y))
sky = love.graphics.newImage(love.image.newImageData(gameSize.x, gameSize.y))
players = {}
updateTimer = love.timer.getTime()
drawTimer = love.timer.getTime()
fpsTimer = love.timer.getTime()
fpsCount = 0
curFPS = 0
avgFPS = 0

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
		
		font = love.graphics.getFont()
		love.graphics.setColor(255,255,255,255)
		love.graphics.print("Scorched Earth", (screenSize.x * 0.5) - (font:getWidth("Scorched Earth") * 0.5), (screenSize.y * 0.5) - (font:getHeight("Scorched Earth")))
		love.graphics.print("Press [Enter] to play", (screenSize.x * 0.5) - (font:getWidth("Press [Enter] to play") * 0.5), (screenSize.y * 0.5) + (font:getHeight("Scorched Earth")))
		
	elseif gameStates.curState == gameStates.PLAY then

		love.graphics.setColor(255,255,255,255)		
	
		love.graphics.draw( sky, viewPos.x, viewPos.y, 0,1,1,0,0,0,0)
		love.graphics.draw( terrain, viewPos.x, viewPos.y,0,1,1,0,0,0,0)
		
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
	
	if gameStates.curState == gameStates.MENU then
	
		if keys["return"] and utDelta > 0.5 then
			generateTerrain()
			gameStates.curState = gameStates.PLAY
		end
	
	elseif gameStates.curState == gameStates.PLAY then

		
		if (keys["kp+"] or (keys["="] and (keys["lshift"] or keys["rshift"]) ) ) and (keyDelta >= keyRate) then
			keyTimer = love.timer.getTime()		
			generateTerrain()
		end
		
		if (keys["kp-"] or keys["-"]) and (keyDelta >= keyRate) then
			keyTimer = love.timer.getTime()		
		end
		
		if keys[" "] and (keyDelta >= keyRate) then
			keyTimer = love.timer.getTime()		
		end

		if keys["left"] and (keyDelta >= (keyRate * 3)) then
			viewPos.x = viewPos.x + 25
			if viewPos.x > 0 then
				viewPos.x = 0
			end
			print(viewPos.x)
			keyTimer = love.timer.getTime()		
		end
		
		if keys["right"] and (keyDelta >= (keyRate * 3))  then
			viewPos.x = viewPos.x - 25
			if viewPos.x < -(gameSize.x * 0.5) then
				viewPos.x = -(gameSize.x * 0.5)
			end
			print(viewPos.x)
			keyTimer = love.timer.getTime()		
		end
		
		if keys["up"] and (keyDelta >= (keyRate * 4)) then
			keyTimer = love.timer.getTime()		
		end
		
		if keys["down"] and (keyDelta >= (keyRate * 4))  then
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
	
end

function love.mousereleased( x, y, button )
	print("Mouse " .. tostring(button) .. " is up")

end

function love.mousemoved( x, y, dx, dy )
	--print("Mouse has moved")
end

function doExplosion(where, radius, power)
	
	

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
	
	
	
	for s = 0, 100 + (math.random() * 100) do
		
		for p = 0, (math.random() * 5) do
		
			for x = 1, gameSize.x - 2 do
					
				terrainArray[x - 1] = (terrainArray[x] + terrainArray[x + 1]) * 0.5
			
			end
			
		end 
		
		for x = 0, gameSize.x - 1 do
			
			prevX = x - 1
			nextX = x + 1
			if prevX < 0 then
				prevX = prevX + gameSize.x 
			end
			
			if nextX > gameSize.x - 1 then
				nextX = nextX - gameSize.x 
			end
			
			terrainArray[x] = (terrainArray[prevX] + terrainArray[x] + terrainArray[nextX]) / 3.001
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
		
		if y > (terrainArray[x] - 10) then
			for i = -2, 2 do
				for u = -2, 2 do
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

