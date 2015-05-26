gameTime = 0

require "point"
gravity = point(0,96.04)
require "viewInformation"
require "pixel"
require "entity"
require "ents"
require "Color"
require "Cycler"
require "Flash"
require "tweenVal"
require "player"
require "ImageScanner"
require "effect"
require "keys"

math.randomseed(os.time())

titleFont = love.graphics.newFont("differentiator.ttf", 20)
gameFont = love.graphics.newFont("differentiator.ttf", 10)
gameTitle = "Toss Battle"
players = {}
--keys = {}
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
 
physFPS = 30
physFPSStep = 1 / physFPS
physAccum = 0
physMax = 1 ---physFPSStep * 5
physAlpha = 0


mouseTimer = gameTime
updateTimer = love.timer.getTime()
--drawTimer = gameTime
lastScreenUpdate = gameTime

gameStates = { MENU = 0 , PLAY = 1, SCORES = 2, TERRAIN=3, curState = 0 }

screenSize = point(love.graphics.getWidth(), love.graphics.getHeight())
gameSize = point(math.floor(screenSize.x + (screenSize.x * 0.3)), screenSize.y)

viewInfo = viewInformation.new(point(0,0), gameSize, screenSize, 1)

tankFire = love.graphics.newImage("tank_fire.png")
basicShot = love.graphics.newImage("basic_shot.png")
explosion = love.graphics.newImage("explosion.png")
angleMeter =  love.graphics.newImage("angle_meter.png")
power_bar =  love.graphics.newImage("power_bar.png")
power_bar_bg = love.graphics.newImage("power_bar_bg.png")
power_bar_disp = love.graphics.newImage(love.image.newImageData(power_bar:getWidth(), power_bar:getHeight()))

terrain = love.graphics.newImage(love.image.newImageData(gameSize.x, gameSize.y))
tData = terrain:getData()
sky = love.graphics.newImage(love.image.newImageData(gameSize.x, gameSize.y))
sData = sky:getData()
screen = love.graphics.newCanvas( ) --love.graphics.newImage(love.image.newImageData(screenSize.x, screenSize.y))

pixel.setImage(terrain)
ents.setImage(terrain)



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
	
	
	function makeSky(x,y,r,g,b,a)
		
		vertPerc = ( y / screenSize.y)
		b = 255 - (127 * (vertPerc))
		g = 128 + (127 * (1 - vertPerc))
		a = 255
		
		return r,g,b,a
		
	end
	
	sData:mapPixel(makeSky)
	sky:refresh()

	-- Increase Power
	keys.registerEvent("kp+", function() 
		if gameStates.curState == gameStates.PLAY then
			players[curPly].power = players[curPly].power + 1
			if players[curPly].power > players[curPly].maxPower then
				players[curPly].power = players[curPly].maxPower
			end
			doPowerBar()
		end
	end)
	keys.setKeyRate("kp+", 0.01)
	
	-- Decrease Power
	keys.registerEvent("kp-", function() 
		if gameStates.curState == gameStates.PLAY then
			players[curPly].power = players[curPly].power - 1
			if players[curPly].power < 0 then
				players[curPly].power = 0
			end
			doPowerBar()
		end
	end)
	keys.setKeyRate("kp-", 0.01)
	
	-- Fire!!!
	keys.registerEvent(" ", function() 
		if gameStates.curState == gameStates.PLAY then
			fireShot(players[curPly])
		end
	end)
	keys.setKeyRate(" ", 0.5)
	
	-- Scroll View Right
	keys.registerEvent("left", function()
		if gameStates.curState == gameStates.PLAY then
			moveRate = (moveRate - 25)
			viewInfo:setPos(viewInfo.pos + point(moveRate,0))
		end
	end)
	keys.setKeyRate("left", 0.01)
	
	-- Scroll View Left
	keys.registerEvent("right", function()
		if gameStates.curState == gameStates.PLAY then
			moveRate = (moveRate + 25)
			viewInfo:setPos(viewInfo.pos + point(moveRate,0))
		end
	end)
	keys.setKeyRate("right", 0.01)
	
	-- Decrease Angle of shot
	keys.registerEvent("up", function()
		if gameStates.curState == gameStates.PLAY then
			players[curPly].angle = players[curPly].angle - 1
			if players[curPly].angle < -90 then
				players[curPly].angle = -90
			end
			--print(players[curPly].angle)
		end

	end)
	keys.setKeyRate("up", 0.01)
	
	-- Increase Angle of shot
	keys.registerEvent("down", function()
		if gameStates.curState == gameStates.PLAY then
			players[curPly].angle = players[curPly].angle + 1
			if players[curPly].angle > 90 then
				players[curPly].angle = 90
			end
			--print(players[curPly].angle)
		end
	end)
	keys.setKeyRate("down", 0.01)
	
	keys.registerEvent("escape", function() 
		os.exit() 
	end)
	
	keys.registerEvent("return", function()
		if gameStates.curState == gameStates.MENU then
			gameStates.curState = gameStates.TERRAIN
		elseif gameStates.curState == gameStates.SCORES then
			gameStates.curState = gameStates.MENU
		end
	end)
	
	
	keys.registerEvent("d", function() 
		
		print("**************** Debug Print *************************")
		print("")
		print("Effect Count: " .. tostring(effect.count()))
		print("Pixel Count: " .. tostring(pixel.count()))
		print("******************************************************")
		--print("Pixel List: ")
		
		--for	k,v in pairs(pixel.pixels) do
			
			--print("pixelID: " .. tostring(k))
			--print("pixelPos: " .. tostring(v.pos))
			--print("pixelVel: " .. tostring(v.vel))
			
		--end
		
	
	end)
	
	love.keyboard.setKeyRepeat( true )
	
end

function love.draw()

	love.graphics.draw( screen )

end


local didPhys = false
function love.update(loveDelta)

	curTime = love.timer.getTime()
	local updateDelta = curTime - updateTimer
	local mouseDelta = gameTime - mouseTimer

	physAccum = physAccum + updateDelta

	if physAccum > physMax then physAccum = physMax end
	
	while physAccum >= physFPSStep do

		gameTime = gameTime + physFPSStep
		effect.thinkEffects(physFPSStep)
		Cycler.runCycles(physFPSStep)
		pixel.movePixels(physFPSStep)
		ents.think(physFPSStep)
		physAccum = physAccum - physFPSStep
		physAlpha = physAccum / physFPSStep
		didPhys = true
		
	end
	
	if didPhys then
		renderScreen()
		didPhys = false
	end
		
	if gameStates.curState == gameStates.MENU then
	
		if (mouse["l"] and mouse["l"].down) and (mouseDelta >= 0.5) then
			local thisEff = effect.new("test" .. tostring(math.random()), mouse.pos, point(0,0), tankFire, 10, {name = "", fCount = point(8,8), fps = 16, loop = true})
			thisEff.pos = thisEff.pos - point(0,64)
			mouseTimer = gameTime
		end
		
		updateTimer = love.timer.getTime()		
	
	elseif gameStates.curState == gameStates.TERRAIN then

		generateTerrain()
		playerOne = player.new("Fantym", point(50,200), Color(255,0,0,255))
		players[curPly] = playerOne
		doPowerBar()
		gameStates.curState = gameStates.PLAY
		
		updateTimer = love.timer.getTime()		
		
	elseif gameStates.curState == gameStates.PLAY then
		
		moveRate = moveRate  * 0.999
		
		-- Test mouse click, makes explosion effect
		if (mouse["l"] and mouse["l"].down) and (mouseDelta >= 0.5) then
			effect.new("test3" .. tostring(math.random()), mouse.pos, point(0,-20), explosion, -1, {name = "", fCount = point(13,1), fps = 20, loop = false})
			mouseTimer = gameTime
		end
		
		updateTimer = love.timer.getTime()		
		
	elseif gameStates.curState == gameStates.SCORES then
		
		if updateDelta > 10 then
			gameStates.curState = gameStates.MENU
		end
		
		
	end
	
	
	
end

function renderScreen()

	screen:clear()
	love.graphics.setCanvas(screen)
		
		if gameStates.curState == gameStates.MENU then

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
			love.graphics.draw( sky    , -viewInfo.pos.x(), -viewInfo.pos.y(), 0, 1, 1, 0, 0, 0, 0)
			terrain:refresh()
			love.graphics.draw( terrain, -viewInfo.pos.x(), -viewInfo.pos.y(), 0, 1, 1, 0, 0, 0, 0)
			
			ents.draw(physAlpha)
			pixel.drawPixels(physAlpha)
			Flash.drawFlashes()
			
			love.graphics.draw(power_bar_bg)
			love.graphics.draw(power_bar_disp)
			
			
			
			
			
		elseif gameStates.curState == gameStates.SCORES then

			font = love.graphics.getFont()
			
			love.graphics.setColor(255 * textCycler:getValue() ,255 * (1 - textCycler:getValue()), 128 + (127 * textCycler:getValue()),255)
			love.graphics.print("Game Over", (screenSize.x * 0.5) - (font:getWidth("Game Over") * 0.5), 200)
			love.graphics.print("Press [Enter] to return to the menu", (screenSize.x * 0.5) - (font:getWidth("Press [Enter] to return to the menu") * 0.5), 330)
			
			
			
		end
	effect.drawEffects()
	love.graphics.setCanvas() 
	
end

function love.keypressed( keyStr )
   

	keys.press(keyStr)
	
	--print(keyStr .. " pressed.")
   
end

function love.keyreleased( keyStr )
   

	keys.release(keyStr)
	
	--print(keyStr .. " released.")
  
end

function love.mousepressed( x, y, button )
	--print("Mouse " .. tostring(button) .. " is down")
	
	if not mouse[button] then
		mouse[button] = {}
	end
	
	mouse[button].down = true
	mouse[button].pos = point(x,y)
	
end

function love.mousereleased( x, y, button )
	--print("Mouse " .. tostring(button) .. " is up")
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

function doPowerBar()

	--power_bar_disp:getData():paste(power_bar_bg:getData(), 0,0, 0,0, power_bar:getWidth(), power_bar:getHeight() )
	--power_bar_disp:refresh()
	power_bar_disp:getData():mapPixel(imgWipeFunc)
	power_bar_disp:getData():paste(power_bar:getData(), 0,0, 0,0, (players[curPly].power / players[curPly].maxPower) * power_bar:getWidth(), power_bar:getHeight())
	power_bar_disp:refresh()

end

function fireShot(ply)
	
	local shotPos = ply.pos + point(math.sin(math.rad(-ply.angle)) * -16, math.cos(math.rad(-ply.angle)) * -16)
	local newShot = ents.newEntity("testShot" .. tostring(math.random()), shotPos, (shotPos - ply.pos):getNormal() * ply.power, basicShot, nil, function() end, 
			function(self, colInfo)
				doExplosion(self.pos, self.cRadius * 2, 150, self.vel * -1)
				--ents.remove(self.id)
				ents.entList[self.id] = nil
				--self = nil
			end)
	newShot:setScale(0.25)

end

function doExplosion(where, radius, power, hitVel)
	
	local pixelCount = 0
	local destroyPerc = 0.9
	local deadCount = 0
	local thisBoom = effect.new("exp" .. tostring(where), where, point(0,0), explosion, -1, {name = "", fCount = point(13,1), fps = 20, loop = false})
	thisBoom:setScale(0.5)
	for y = -radius, radius do
		for x = -radius, radius do
			newPos = where + point(x,y)
			if where:closerThan(newPos, radius) then
				if pixel.inImage(nil, newPos) then
					pixelCount = pixelCount + 1
					if deadCount / pixelCount < destroyPerc then
						tData:setPixel(newPos.x, newPos.y, 0,0,0,0)
						deadCount = deadCount  + 1
					else
						r,g,b,a = tData:getPixel(newPos.x, newPos.y)
						if not (a == 0) then
							diffVec = newPos - where
							diffVec:normalize()
							diffVec = diffVec * power 
							pixel(newPos, diffVec + (gravity * -2))
							
						end
					end
				end
			end
		end
	end

end

function imgWipeFunc(x,y,r,g,b,a)
	
	return 0,0,0,0
		
end
	
function generateTerrain()
	
	
	
	
	tData:mapPixel(imgWipeFunc)
	
	
	terrainArray = {}
	
	for x = 0, gameSize.x - 1 do
		
		terrainArray[x] = math.floor(math.random() * (gameSize.y * (0.2 + (math.random() * 0.3))))
		terrainArray[x] = (terrainArray[x] * 2) + (math.cos(math.rad(x * 100)) * (-15 + (math.random() * 30)))
		
		
		terrainArray[x] = terrainArray[x] + (math.sin(-1) * (-25 + (math.random() * 50)))
		
		
	end
	
	
	
	for s = 0, 15 + (math.random() * 10) do
		
		for p = 0, 5 + (math.random() * 15) do
		
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
			if finPerc > 0.475275 then
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

