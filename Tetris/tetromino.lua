require "point"

tetromino = {}
tetromino.__index = tetromino
tetromino.pieceImage = love.graphics.newImage("tetromino_single.png"):getData()

function tetromino.new(design, clr) 
	
	local tetri = {}
	setmetatable(tetri, tetromino)
	tetri.design = design
	tetri.color = clr
	tetri.pos = point(0,0)
	tetri.img = nil
	tetri.angle = 0
	tetri:createImage()
	tetri.shouldDelete = false
	
	return tetri

end

function tetromino:getWidth()
	
	return #self.design[#self.design] * tetromino.pieceImage:getWidth() 

end

function tetromino:getHeight()
	
	return #self.design * tetromino.pieceImage:getHeight() 

end

function tetromino:clone()
	
	local tCopy = {}
	setmetatable(tCopy, tetromino)
	tCopy.design = {}
	for y = 1, #self.design do
		tCopy.design[y] = {}
		for x = 1, #self.design[#self.design] do
			tCopy.design[y][x] = self.design[y][x]
		end
	end
	tCopy.color = self.color:copy()
	tCopy.pos = point(0,0)
	--tCopy.img = self.img
	tCopy:createImage()
	tCopy.angle = tonumber(self.angle)
	tCopy.shouldDelete = false
	
	return tCopy
	
end

function tetromino:createImage()

	imgWidth = tetromino.pieceImage:getWidth() 
	imgHeight = tetromino.pieceImage:getHeight() 
	
	imgData = love.image.newImageData( imgWidth , imgHeight)
	imgData:paste(tetromino.pieceImage,0,0,0,0,imgWidth, imgHeight)
	
	function pixelFunction(x, y, r, g, b, a)
		
		pixelLen = math.sqrt( (r * r) + (g * g) + (g * g) )
		--print(pixelLen)
		--luminance = 1 - (0.299 * r + 0.587 * g + 0.114 * b)
		
		luminanceR = r / pixelLen
		luminanceG = g / pixelLen
		luminanceB = b / pixelLen
	
		luminance = pixelLen / 255 --(luminanceR + luminanceG + luminanceB) / 3
		
		if luminance < 0 then luminance = 0 end
		if luminance > 1 then luminance = 1 end
		
		r = self.color.r * luminance
		g = self.color.g * luminance
		b = self.color.b * luminance
		
		return r, g, b, a
		
	end
	
	imgData:mapPixel( pixelFunction )
		
	self.img = love.graphics.newImage(imgData)
	
end

function tetromino:place(onImage) 
	
	curPoint = point(1,1)
	onImageData = onImage:getData()
	thisImage = self.img:getData()
	
	for y = 1, #self.design do
		for x = 1, #self.design[y] do
			
			if self.design[y][x] == 1 then
				
				curPoint = point(x, y)
				curPoint:rotate(self.angle, point(math.ceil(#self.design[y] * 0.5), math.ceil(#self.design * 0.5)))
				curPoint = curPoint + self.pos
				
				onImageData:paste(thisImage, (curPoint.x * 32), (curPoint.y * 32), 0,0,thisImage:getWidth(), thisImage:getHeight())
				--love.graphics.draw( self.img, 
					--				(curPoint.x * 32), 
						--			(curPoint.y * 32), 
							--		0, 1, 1, 0, 0, 0, 0 )
			end
			
		end
	end
	
	onImage:refresh()
						
end

function tetromino:draw(offset) 
	
	curPoint = point(1,1)
	
	for y = 1, #self.design do
		for x = 1, #self.design[y] do
			
			if self.design[y][x] == 1 then
				
				curPoint = point(x, y)
				curPoint:rotate(self.angle, point(math.ceil(#self.design[y] * 0.5), math.ceil(#self.design * 0.5)))
				curPoint = curPoint + self.pos
				love.graphics.draw( self.img, 
									offset.x + (curPoint.x * 32), 
									offset.y + (curPoint.y * 32), 
									0, 1, 1, 0, 0, 0, 0 )
			end
		end
	end
	
						
end

function tetromino:deletePart(part)
	
	partCount = 0
	for y = 1, #self.design do
		for x = 1, #self.design[y] do
			
			if self.design[y][x] == 1 then
				
				curPoint = point(x, y)
				curPoint:rotate(self.angle, point(math.ceil(#self.design[y] * 0.5), math.ceil(#self.design * 0.5)))
				curPoint = curPoint + self.pos
				
				if curPoint == part then
					
					self.design[y][x] = 0
					
				end

			end
		end
	end
	
	if partCount == 0 then self.shouldDelete = true end
	

end

function tetromino:__tostring()
	
	return "( tetromino )"
	
end

