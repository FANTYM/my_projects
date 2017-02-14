gameTime = 0
require "point"
gravity = point(0,0)
require "cells"
cellSystem.size = point(128,128)
require "entity"
require "ents"
require "Color"
require "Cycler"
require "Flash"
require "tweenVal"
require "effect"
require "keys"

timeScale = 1


math.randomseed(os.time())

titleFont = love.graphics.newFont("differentiator.ttf", 20)
gameFont = love.graphics.newFont("differentiator.ttf", 10)
gameTitle = "Brick Breaker"
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
 
physFPS = 60
physFPSStep = 1 / physFPS
physAccum = 0
physMax = 1 ---physFPSStep * 5
physAlpha = 0

mouseTimer = gameTime
updateTimer = love.timer.getTime()
lastScreenUpdate = gameTime

textCycler = Cycler.new(0.01, 0, 0, 1, true, true)

gameStates = { MENU = 0 , PLAY = 1, SCORE = 2, PAUSE = 420, curState = 0 }

screenSize = point(love.graphics.getWidth(), love.graphics.getHeight())

baseBrick = love.graphics.newImage("brick.png")
playerPaddle = love.graphics.newImage("paddle.png")
hitBlast = love.graphics.newImage("blast.png")
theBall = love.graphics.newImage("ball.png")

screen = love.graphics.newCanvas()

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

function copyImg(srcImage)

	newImg = love.graphics.newImage(love.image.newImageData(srcImage:getWidth(), srcImage:getHeight()))
	
	newImg:getData():paste(srcImage:getData(), 0,0)
	
	return newImg

end 

			
player = ents.newEntity("player", point(screenSize.x * 0.5,screenSize.y - 64), point(0,0),  playerPaddle, nil, 
	function(self,dTime)
		self.vel = self.vel + (((point(0, screenSize.y - 64) - self.pos) * point(0,1)) * dTime)
	end, 
	function (self, colInfo)
		if colInfo.colEnt then
			
			if colInfo.colEnt.name == "ball" then
				--colInfo.colEnt.vel = colInfo.colEnt.vel * 1.1
			end
			
		end
	end)
player.color = colorPool[math.ceil(math.random() * #colorPool)]
player:reColor(player.color)	   
--player.mass = 500
player.friction = 0.9

ball = ents.newEntity("ball", point(screenSize.x * 0.5,screenSize.y * 0.75),  point(-20 + (math.ceil(math.random() * 40)),20),  copyImg(theBall), nil, thinkFunction, 
	function(self, colInfo)
		if colInfo.colEnt == nil then
			if colInfo.normal == point(0,-1) then
				print("ball lost")
				self:setPos(point(screenSize.x * 0.5,screenSize.y * 0.75))
				self:setPos(point(screenSize.x * 0.5,screenSize.y * 0.75))
				self.vel = point(-20 + (math.ceil(math.random() * 40)),20)
				player:setPos(point(screenSize.x * 0.5,screenSize.y - 64))
				player.vel = point(0,0)
			end
		else
			if colInfo.colEnt.name == "player" or
			   colInfo.colEnt.name == "brick" then
			   self.vel.y = -self.vel.y
			end
			
		end
		self.img = copyImg(theBall)
		self.color = colorPool[math.ceil(math.random() * #colorPool)]
		self:reColor(self.color)	
				
	end)
ball.color = colorPool[math.ceil(math.random() * #colorPool)]
ball:reColor(ball.color)	
ball.friction = 1.00
--ball.mass = 25

bricks = {}


function love.load()

	-- Release Ball
	keys.registerEvent(" ", function() 
		if gameStates.curState == gameStates.PLAY then
			--startBall()
			player.vel = point(0,0)
		end
	end)
	keys.setKeyRate(" ", 0.5)
	
	-- move paddle left
	keys.registerEvent("left", function()
		if gameStates.curState == gameStates.PLAY then
			moveRate = (moveRate + 50)
			player.vel = player.vel - point(player.anims[0].fSize.x * 2, 0)
		end
	end)
	keys.setKeyRate("left", 0.01)
	
	-- move paddle right
	keys.registerEvent("right", function()
		if gameStates.curState == gameStates.PLAY then
			moveRate = (moveRate + 50)
			player.vel = player.vel + point(player.anims[0].fSize.x * 2, 0)
		end
	end)
	keys.setKeyRate("right", 0.01)
	
	keys.registerEvent("escape", function() 
		os.exit() 
	end)
	
	keys.registerEvent("tab", function() 
		print("tab")
		print("gameStates.curState: " .. gameStates.curState)
		if not (gameStates.curState == gameStates.PAUSE) then
			print("Paused")
			gameStates.lastState = gameStates.curState
			gameStates.curState = gameStates.PAUSE
		else
			gameStates.curState = gameStates.lastState
			print("Unpaused")
		end
		
	end)
	keys.setKeyRate("tab", -1.00)
	
	keys.registerEvent("return", function()
		if gameStates.curState == gameStates.MENU then
			gameStates.curState = gameStates.PLAY
			local x = 0
			local y = 0
			
			for i = 0, 9 do --254 do
				
				bricks[i] = ents.newEntity("brick", point(3 + (x * baseBrick:getWidth()) + (baseBrick:getWidth() * 0.5) + (3 * x),(3 * y) + (baseBrick:getHeight() * 0.5) + ( y * baseBrick:getHeight())),  point(0,0),  copyImg(baseBrick), nil,
						function(self,dTime)
							self.vel = point(0,0) -- self.vel + ((self.lastPos - self.pos) * dTime)
						end, 
						function(self, colInfo)
							
							if colInfo.colEnt then
								if colInfo.colEnt.name == "ball" then
									local thisEff = effect.new("blast", colInfo.colPos, colInfo.normal, hitBlast, -1, {name = "", fCount = point(5,2), fps = 80, loop = false})
									thisEff.scale = 0.25
									if self.hitCount == nil then
										self.hitCount = 1
									else
										self.hitCount = self.hitCount + 1
									end
									
									if self.hitCount > 3 then
										cellSystem.removeFromCell(self)
										ents.entList[self.id] = nil
										self = nil
										return
									end
									self.img = copyImg(baseBrick)
									self.color = colorPool[math.ceil(math.random() * #colorPool)]
									self:reColor(self.color)	
									colInfo.colEnt.vel = colInfo.colEnt.vel * 1.75
								end
							end
									
						end)
				bricks[i].friction = 0
				bricks[i].color = colorPool[math.ceil(math.random() * #colorPool)]
				bricks[i]:reColor(bricks[i].color)
				x = x + 1
				if x > math.floor(screenSize.x / (baseBrick:getWidth() + 4) ) then
					x = 0
					y = y + 1
				end
			
			end
		elseif gameStates.curState == gameStates.SCORES then
			gameStates.curState = gameStates.MENU
		end
	end)
	
	
	keys.registerEvent("d", function() 
		
		print("**************** Debug Print *************************")
		print("")
		print("timeScale: " .. tostring(timeScale))
		print("")
		print("******************************************************")
	end)
	
	keys.registerEvent("kp-", function() timeScale = timeScale * 0.5 end)
	keys.setKeyRate("kp-", 0.01)
	keys.registerEvent("kp+", function() timeScale = timeScale * 1.5 end)
	keys.setKeyRate("kp+", 0.01)
	
	love.keyboard.setKeyRepeat( true )
	
end

function love.draw()

	love.graphics.draw( screen )

end

didPhys = false

function love.update(loveDelta)

	local curTime = love.timer.getTime()
	local updateDelta = curTime - updateTimer
	local mouseDelta = gameTime - mouseTimer

	if not (gameStates.curState == gameStates.PAUSE) then
	
		physAccum = physAccum + (updateDelta * timeScale)

		if physAccum > physMax then physAccum = physMax end
		
		while physAccum >= physFPSStep do
			
			gameTime = gameTime + physFPSStep	
			
			effect.thinkEffects(physFPSStep)
			Cycler.runCycles(physFPSStep)
			if gameStates.curState == gameStates.PLAY then
				ents.think(physFPSStep)
			end
			physAccum = physAccum - physFPSStep
			physAlpha = physAccum / physFPSStep
			didPhys = true
		end
	else
		updateTimer = love.timer.getTime()			
	end
	
	if didPhys then
		renderScreen()
		didPhys = false
	end
		
	if gameStates.curState == gameStates.MENU then
	
		if (mouse["l"] and mouse["l"].down) and (mouseDelta >= 0.15) then
			local thisEff = effect.new("test_blast" .. tostring(math.random()), mouse.pos, point(0,0), hitBlast, -1, {name = "", fCount = point(5,2), fps = 80, loop = false})
			mouseTimer = gameTime
		end
		
		updateTimer = love.timer.getTime()		
		
	elseif gameStates.curState == gameStates.PLAY then
		
		moveRate = moveRate  * 0.999
		
		if (mouse["l"] and mouse["l"].down) and (mouseDelta >= 0.5) then
			local thisEff = effect.new("test_blast" .. tostring(math.random()), mouse.pos, point(0,0), hitBlast, -1, {name = "", fCount = point(5,2), fps = 16, loop = false})
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

	love.graphics.setCanvas(screen)
		love.graphics.clear()
	
		
		if gameStates.curState == gameStates.MENU then

			love.graphics.setFont(titleFont)
			love.graphics.setColor(255,255,255,255)
			love.graphics.print(gameTitle, (screenSize.x * 0.5) - (titleFont:getWidth(gameTitle) * 0.5), (screenSize.y * 0.5) - (titleFont:getHeight(gameTitle)))
			love.graphics.print("Press [Enter] to play", (screenSize.x * 0.5) - (titleFont:getWidth("Press [Enter] to play") * 0.5), (screenSize.y * 0.5) + (titleFont:getHeight(gameTitle)))
	
		elseif gameStates.curState == gameStates.PLAY then
			love.graphics.setColor(255,255,255,255)	
			
			ents.draw(physAlpha)
			Flash.drawFlashes()

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

function imgWipeFunc(x,y,r,g,b,a)
	
	return 0,0,0,0
		
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


