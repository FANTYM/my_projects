require "point"
require "Color"
require "tetromino"
require "Cycler"
require "Flash"

math.randomseed(os.time())

soundVolume = 0.50
musicVolume = 0.45
flashes = {}
placePieceSound = love.audio.newSource("place_piece.wav", "static")
clearLineSound = love.audio.newSource("clear_line.wav", "static")
clearLinesSound = love.audio.newSource("clear_lines.wav", "static")
loseSound = love.audio.newSource("lose.wav", "static")
flipPieceSound = love.audio.newSource("flip_piece.wav", "static")
levelUpSound = love.audio.newSource("level_up.wav", "static")
normalMusic = love.audio.newSource("normal_music.wav")
normalMusic:setLooping(true)
dangerMusic = love.audio.newSource("danger_music.wav")
dangerMusic:setLooping(true)

curKey = "";
keyRate = 0.02
keyTimer = love.timer.getTime()
board = {}
for y = -2, 19 do
	board[y] = {}
	for x = 0,9 do
		board[y][x] = 0
	end
end
textCycler = Cycler.new(1, 0.5, 0.5, 1, true, true)
nextPieceCycler = Cycler.new( 1, 0.0, 0.5, 1, true, true)
boardPos = point(0,0)
boardSize = point(10,22)
boardZero = point(31,0)
gameStates = { MENU = 0 , PLAY = 1, SCORES = 2, curState = 0, nextPiece = math.ceil(math.random() * 7)}
gameBoard = love.graphics.newImage("game_board.png")
placedPieces = love.graphics.newImage(love.image.newImageData( (#board[#board] + 1) * 32 , (#board + 1) * 32))		  
score = 0
curLevel = 0
maxLevel = 10
linesCleared = 0
drawTimer = love.timer.getTime()
avgDrawTime = 0
fpsTimer = love.timer.getTime()
fpsCount = 0
curFPS = 0
avgFPS = 0
updateTimer = love.timer.getTime()
screenSize = point(love.graphics.getWidth(), love.graphics.getHeight())


keys = {}
tetrominoDesigns = { 
					  {{0,1,0},
                       {1,1,1}}, 
					  
					  {{1,0,0},
                       {1,1,1}}, 
					  
					  {{0,0,1},
                       {1,1,1}}, 
					   
					  {{1,1,1,1}}, 
					  
					  {{1,1},
                       {1,1}}, 
					   
					  {{1,1,0},
                       {0,1,1}}, 
					  
					  {{0,1,1},
                       {1,1,0}} 
				   }

pieceColorPool = { Color(255,255,255,255),
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
				   
baseTetrominos = {tetromino.new(tetrominoDesigns[1], pieceColorPool[1]),
                  tetromino.new(tetrominoDesigns[2], pieceColorPool[2]),
				  tetromino.new(tetrominoDesigns[3], pieceColorPool[3]),
				  tetromino.new(tetrominoDesigns[4], pieceColorPool[4]),
				  tetromino.new(tetrominoDesigns[5], pieceColorPool[5]),
				  tetromino.new(tetrominoDesigns[6], pieceColorPool[6]),
				  tetromino.new(tetrominoDesigns[7], pieceColorPool[7]) }


function love.load()
	setVolumes()
end

function love.draw()
	
	drawTimer = love.timer.getTime()
	fpsCount = fpsCount + 1
	if love.timer.getTime() - fpsTimer >= 1 then
		curFPS = fpsCount - 1
		avgFPS = (avgFPS + curFPS) * 0.5
		fpsCount = 1
		fpsTimer = love.timer.getTime()
	end

	curDT = love.timer.getTime() - drawTimer
	avgDrawTime = (avgDrawTime + curDT) * 0.5
	
	if gameStates.curState == gameStates.MENU then
		
		font = love.graphics.getFont()
		
		love.graphics.setColor(255,255,255,255)
		love.graphics.print("Tetris", (screenSize.x * 0.5) - (font:getWidth("Tetris") * 0.5), (screenSize.y * 0.5) - (font:getHeight("Tetris")))
		love.graphics.print("Press [Enter] to play", (screenSize.x * 0.5) - (font:getWidth("Press [Enter] to play") * 0.5), (screenSize.y * 0.5) + (font:getHeight("Tetris")))
		
	elseif gameStates.curState == gameStates.PLAY then

		love.graphics.setColor(baseTetrominos[gameStates.nextPiece].color.r,
							   baseTetrominos[gameStates.nextPiece].color.g,
							   baseTetrominos[gameStates.nextPiece].color.b,
							   196)
		love.graphics.rectangle( "line", 390, 64, baseTetrominos[gameStates.nextPiece]:getWidth() + 32, baseTetrominos[gameStates.nextPiece]:getHeight() + 32)
		
		love.graphics.setColor(255,255,255,128 + (nextPieceCycler:getValue() * 127))
		baseTetrominos[gameStates.nextPiece]:draw(point(374,48))
		
		love.graphics.setColor(255,255,255,255)		
		
		love.graphics.draw( gameBoard, boardPos.x, boardPos.y,0,1,1,0,0,0,0)
		love.graphics.draw( placedPieces, boardPos.x + boardZero.x, boardPos.y + boardZero.y,0,1,1,0,0,0,0)
		curTet:draw(boardPos + boardZero)
		
		love.graphics.setColor(0,255,255,255)
		love.graphics.print("Score: " .. tostring(score), 390, 0)
		love.graphics.print("Level: " .. tostring(curLevel), 390, 16)
		love.graphics.print("Lines: " .. tostring(linesCleared + (curLevel * 10)), 390, 32)
		love.graphics.print("Next Piece: ", 390, 48)
		love.graphics.print("Sound Volume:", 390, 176)
		love.graphics.print("( Use [+] or [-] to adjust)", 390, 210)
		
		love.graphics.setColor(0,255,0,196)
		
		love.graphics.rectangle( "fill", 390, 192,  128 * soundVolume , 16)
		
		Flash.drawFlashes()
	
		
	elseif gameStates.curState == gameStates.SCORES then
		
		font = love.graphics.getFont()
		
		love.graphics.setColor(255 * textCycler:getValue() ,255 * (1 - textCycler:getValue()), 128 + (127 * textCycler:getValue()),255)
		love.graphics.print("Game Over", (screenSize.x * 0.5) - (font:getWidth("Game Over") * 0.5), 200)
		love.graphics.print("Score: " .. tostring(score), (screenSize.x * 0.5) , 230)
		love.graphics.print("Level: " .. tostring(curLevel), (screenSize.x * 0.5) , 260)
		love.graphics.print("Lines: " .. tostring(linesCleared + (curLevel * 10)), (screenSize.x * 0.5), 290)
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
	
		if keys["return"] and utDelta > 1 then
			gameStates.curState = gameStates.PLAY
			placedPieces = love.graphics.newImage(love.image.newImageData( (#board[#board] + 1) * 32 , (#board + 1) * 32))		  
			for y = -2, 19 do
				board[y] = {}
				for x = 0,9 do
					board[y][x] = 0
				end
			end
			
			score = 0
			curLevel = 0
			linesCleared = 0
			spawnNextPiece()
			normalMusic:play()
		end
		

	
	elseif gameStates.curState == gameStates.PLAY then
	
		
		
		if utDelta > 1 - (curLevel / maxLevel) then
			
			curTet.pos.y = curTet.pos.y + 1
			
			if not canPlace(curTet) then
				curTet.pos.y = curTet.pos.y - 1
				placePiece(curTet)
				
			end
			updateTimer = curTime
			
		end
		
		if (keys["kp+"] or (keys["="] and (keys["lshift"] or keys["rshift"]) ) ) and (keyDelta >= keyRate) then
			
			soundVolume = soundVolume + 0.05
			soundVolume = clamp(soundVolume, 0, 1)
			musicVolume = soundVolume - (soundVolume * 0.5)
			setVolumes()
			keyTimer = love.timer.getTime()
			
		end
		
		if (keys["kp-"] or keys["-"]) and (keyDelta >= keyRate) then
			
			soundVolume = soundVolume - 0.05
			soundVolume = clamp(soundVolume, 0, 1)
			musicVolume = soundVolume - (soundVolume * 0.5)
			setVolumes()
			keyTimer = love.timer.getTime()
			
		end
		
		if keys[" "] and (keyDelta >= keyRate) then
			curTet.pos.y = curTet.pos.y + 1
			if not canPlace(curTet) then
				curTet.pos.y = curTet.pos.y - 1
				placePiece(curTet)
				
			end
			keyTimer = love.timer.getTime()		
		end

		if keys["left"] and (keyDelta >= (keyRate * 3)) then
			curTet.pos.x = curTet.pos.x - 1
			if not canPlace(curTet) then
				curTet.pos.x = curTet.pos.x + 1
			end
			keyTimer = love.timer.getTime()		
		end
		
		if keys["right"] and (keyDelta >= (keyRate * 3))  then
			curTet.pos.x = curTet.pos.x + 1
			if not canPlace(curTet) then
				curTet.pos.x = curTet.pos.x - 1
			end
			keyTimer = love.timer.getTime()		
		end
		
		if keys["up"] and (keyDelta >= (keyRate * 4)) then
			curTet.angle = curTet.angle - 90
			if curTet.angle < 0 then
				curTet.angle = curTet.angle + 360 
			end
			if not canPlace(curTet) then
				curTet.angle = curTet.angle + 90
				if curTet.angle > 360 then
					curTet.angle = curTet.angle - 360 
				end
			else
				flipPieceSound:clone():play()
			end
			keyTimer = love.timer.getTime()		
		end
		
		if keys["down"] and (keyDelta >= (keyRate * 4))  then
			curTet.angle = curTet.angle + 90
			if curTet.angle > 360 then
				curTet.angle = curTet.angle - 360 
			end
			if not canPlace(curTet) then
				curTet.angle = curTet.angle - 90
				if curTet.angle < 0 then
					curTet.angle = curTet.angle + 360 
				end
			else
				flipPieceSound:clone():play()
			end
			keyTimer = love.timer.getTime()		
		end
	elseif gameStates.curState == gameStates.SCORES then
		
		normalMusic:stop()
		dangerMusic:stop()
		
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

function valueInTable(tab, val)

	for i = 1, #tab do
		
		if tab[i] == val then
			return true
		end
		
	end
	
	return false
end

function setVolumes()

	flipPieceSound:setVolume(soundVolume * 0.4)
	placePieceSound:setVolume(soundVolume  * 0.5)
	clearLineSound:setVolume(soundVolume  * 0.6)
	clearLinesSound:setVolume(soundVolume  * 0.7)
	levelUpSound:setVolume(soundVolume  * 0.7)
	loseSound:setVolume(soundVolume)
	normalMusic:setVolume(musicVolume)
	dangerMusic:setVolume(musicVolume)

end

function spawnNextPiece()
	
	curTet = baseTetrominos[gameStates.nextPiece]:clone()
	curTet.pos = point(math.ceil(#board[#board] * 0.5) - #curTet.design[#curTet.design], -2)
	if not canPlace(curTet) then
		gameStates.curState = gameStates.SCORES
		loseSound:clone():play()
	end
	gameStates.nextPiece = math.ceil(math.random() * 7)
	
end

function placePiece(piece)
	
	placePieceSound:clone():play()
	
	curPoint = point(0,0)
	for y = 1, #piece.design do
		for x = 1, #piece.design[y] do
			if piece.design[y][x] == 1 then
				curPoint = point(x , y)
				curPoint:rotate(piece.angle, point(math.ceil(#piece.design[y] * 0.5), math.ceil(#piece.design * 0.5))) --point(offX, offY))
				curPoint = curPoint + piece.pos
				curPoint.x = math.ceil(curPoint.x)
				curPoint.y = math.ceil(curPoint.y)
				board[curPoint.y][curPoint.x] = 1
			end
		end
	end
	
	piece:place(placedPieces)
	
	getAllLines()
	
	if linesCleared >= 10 then
		curLevel = curLevel + 1
		levelUpSound:clone():play()
		reColorBaseTets()
		if curLevel > maxLevel then curLevel = maxLevel end
		linesCleared = linesCleared - 10
	end
	
	spawnNextPiece()

end

function reColorBaseTets()
	
	rndTet = 0
	haveNum = true
	colors = {math.ceil(math.random() * #pieceColorPool)}
	
	for n = 1, #baseTetrominos do
		rndNum = math.ceil(math.random() * #pieceColorPool)
		while valueInTable(colors,rndNum) do
			rndNum = math.ceil(math.random() * #pieceColorPool)
		end
		colors[#colors + 1] = rndNum
	end
	
	for i = 1, #baseTetrominos do
		
		rndNum = math.ceil(math.random() * #colors)
		baseTetrominos[i].color = pieceColorPool[colors[rndNum]]--baseTetrominos[rndTet].color
		table.remove(colors, rndNum)
		baseTetrominos[i]:createImage()
		
	end
	
end

function canPlace(piece)

	for y = 1, #piece.design do
		for x = 1, #piece.design[y] do
			if piece.design[y][x] == 1 then

				testPoint = point(x , y)
				testPoint:rotate(piece.angle, point(math.ceil(#piece.design[y] * 0.5), math.ceil(#piece.design * 0.5))) --point(offX, offY))
				testPoint = testPoint + piece.pos 
				testPoint.x = math.ceil(testPoint.x)
				testPoint.y = math.ceil(testPoint.y)
				
				if not (board and board[testPoint.y] and board[testPoint.y][testPoint.x]) then
					return false
				end
				
				if testPoint.x < 0 then
					return false
				end
				
				if testPoint.x > #board[#board] then
					return false
				end

				if testPoint.y > #board  then
					return false
				end

				if (board[testPoint.y][testPoint.x] == 1) then
					return false
				end
				
			end
		end
	end

	return true
	
end

function clearLine(line)
	
	print("clearLine: " .. tostring(line))
	
	--clearingTimer = love.timer.getTime()
	Flash.new(0.25, Color(255,255,255,255), Color(0,0,0,0))
	
	placedData = placedPieces:getData()
	
	clearing = true
	
	tempImg = love.image.newImageData(placedData:getWidth(), (line * 32))
	
	tempImg:paste(placedData, 0,0,0,0,placedData:getWidth(), (line * 32))
	
	for x = 0, placedData:getWidth() - 1 do
		for y = 0, (((line * 32) + 32) - 1) do
			placedData:setPixel(x,y,255,255,255,0)
		end
	end
	
	for x = 0, #board[#board] do
		board[line][x] = 0
	end
		
	for y = line, 0, -1 do
		for x = 0, #board[#board] do
			board[y][x] = board[y - 1][x]
		end
	end
	
	placedData:paste(tempImg, 0, 32,0,0,tempImg:getWidth(),tempImg:getHeight())
	
	placedPieces:refresh()
	
end

function getAllLines()
	
	cleared = 0
	totalCleared = 0
	outOfLines = false
	
	while not outOfLines do
	
		cleared = checkForLines()
		print("cleared: " .. cleared)
		
		if cleared > 0 then
			clearLineSound:clone():play()
			totalCleared = totalCleared + cleared
		else
			outOfLines = true
		end
		
	end
	
	if totalCleared > 0 then
		
		print("totalCleared : " .. tostring(totalCleared) .. " lines")
		linesCleared = linesCleared + totalCleared
		
		if totalCleared >= 4 then
			clearLinesSound:clone():play()
			score = score + (totalCleared * (1000 * (curLevel + 1)))
			Flash.new(0.35, Color(255,255,0,192), Color(0,255,0,64))
		else
			score = score + (totalCleared * (100 * (curLevel + 1)))
			Flash.new(0.15, Color(0,255,0,128), Color(0,0,255,192))
		end
	
	end

end

function checkForLines()
	
	newCleared = 0
	blockCount = 0
	hadLine = false
	hasBlocks = false
	heightCount = 0
	
	for y = #board, 0, -1 do
	
		heightCount = heightCount + 1
		for x = 0, #board[y + newCleared] do
			if board[y + newCleared][x] == 1 then
				blockCount = blockCount + 1
				hasBlocks = true
			end
		end
		
		if blockCount == 10 then
			hadLine = true
			clearLine(y)
			newCleared = newCleared + 1
			heightCount = heightCount - 1
			break
		end
		
		blockCount = 0
		
		if not hasBlocks then 
			break
		end
		
		hasBlocks = false
		
	end
	
	print("heightCount: " .. tostring(heightCount))
	
	if heightCount > 15 then
		normalMusic:stop()
		dangerMusic:play()
	else
		normalMusic:play()
		dangerMusic:stop()
	end
	
	return newCleared;
	
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
reColorBaseTets()