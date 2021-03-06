require "Color"
require "point"

ImageScanner = {}
ImageScanner.__index = ImageScanner

function ImageScanner.new(imgToScan, numRuns, checkFunc, resultFunc)
	
	nIs = {}
	setmetatable(nIs, ImageScanner)
	nIs.imgData = imgToScan:getData()
	nIs.width = nIs.imgData:getWidth()
	nIs.height = nIs.imgData:getHeight()
	nIs.x = 0
	nIs.y = 0
	nIs.checkFunc = checkFunc
	nIs.resultFunc = resultFunc
	nIs.running = true
	nIs.lastR = 0
	nIs.lastG = 0
	nIs.lastB = 0
	nIs.lastA = 0
	nIs.curRuns = 0
	nIs.totalRuns = numRuns
	nIs.lBounds = point(0,0)
	nIs.uBounds = point(nIs.width - 1, nIs.height - 1)
	
	
	return nIs
	

end

function ImageScanner:doRuns()

	self.curRuns = 0
	self.running = true
	
end


function ImageScanner:setRuns(numRuns)
	
	self.totalRuns = numRuns

end

function ImageScanner:setLBounds(newBounds)
	
	self.lBounds = newBounds

	
end

function ImageScanner:setUBounds(newBounds)
	
	self.uBounds = newBounds

	
end


function ImageScanner:doBounds()

	self.x = self.x + 1
	if self.x < self.lBounds.x then
		self.x = self.lBounds.x
	end
	if self.y < self.lBounds.y then
		self.y = self.lBounds.y
	end
	if self.x >= self.uBounds.x then
		self.x = self.lBounds.x
		self.y = self.y + 1
		if self.y >= self.uBounds.y then
			self.y = self.lBounds.y
			self.curRuns = self.curRuns + 1
			if self.curRuns > self.totalRuns then
				self.running = false
				print("finished runs")
			end
		end
	end


end

function ImageScanner:run()
	
	if not self.running then return end
	--print("run")
	self:doBounds()
	
	self.lastR, self.lastG, self.lastB, self.lastA = self.imgData:getPixel(self.x,self.y)
	pxlColor = Color( self.lastR, self.lastG, self.lastB, self.lastA )
	
	if self.checkFunc(self.x,self.y, pxlColor) then
		self.resultFunc(self.x,self.y,pxlColor, { width = self.width, height = self.height, imgData = self.imgData })
	end
	

end

