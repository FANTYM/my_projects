require "point"

block = {}
block.__index = block
block.pieceImage = love.graphics.newImage("block_single.png"):getData()

function block.new(design, clr) 
	
	local nBlock = {}
	setmetatable(nBlock, block)
	nBlock.design = design
	nBlock.color = clr
	nBlock.pos = point(0,0)
	nBlock.img = nil
	nBlock.angle = 0
	nBlock:createImage()
	nBlock.shouldDelete = false
	
	return nBlock

end

function block:getWidth()
	
	return #self.design[#self.design] * block.pieceImage:getWidth() 

end

function block:getHeight()
	
	return #self.design * block.pieceImage:getHeight() 

end

function block:clone()
	
	local bCopy = {}
	setmetatable(bCopy, block)
	bCopy.design = {}
	for y = 1, #self.design do
		bCopy.design[y] = {}
		for x = 1, #self.design[#self.design] do
			bCopy.design[y][x] = self.design[y][x]
		end
	end
	bCopy.color = self.color:copy()
	bCopy.pos = point(0,0)
	bCopy:createImage()
	bCopy.angle = tonumber(self.angle)
	bCopy.shouldDelete = false
	
	return bCopy
	
end

function block:createImage()

	imgWidth = block.pieceImage:getWidth() 
	imgHeight = block.pieceImage:getHeight() 
	
	imgData = love.image.newImageData( imgWidth , imgHeight)
	imgData:paste(block.pieceImage,0,0,0,0,imgWidth, imgHeight)
	
	function pixelFunction(x, y, r, g, b, a)
		
		pixelLen = math.sqrt( (r * r) + (g * g) + (g * g) )
		
		luminanceR = r / pixelLen
		luminanceG = g / pixelLen
		luminanceB = b / pixelLen
	
		luminance = pixelLen / 255
		
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

function block:place(onImage) 
	
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

			end
			
		end
	end
	
	onImage:refresh()
						
end

function block:draw(offset) 
	
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

function block:deletePart(part)
	
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

function block:__tostring()
	
	return "( block )"
	
end

