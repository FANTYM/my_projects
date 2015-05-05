require "tweenVal"

viewInformation = {}

viewInformation.__index = viewInformation

function viewInformation.new(pos, gameSize, screenSize, zoom)
	
	vi = {}
	setmetatable(vi, viewInformation)
	vi.gameSize = gameSize
	vi.screenSize = screenSize
	vi.pos = {}
	vi.pos.x = tweenVal(pos.x, pos.x, 1, 0, gameSize.x - vi.screenSize.x)
	vi.pos.y = tweenVal(pos.y, pos.y, 1, 0, gameSize.y - vi.screenSize.y)
	
	vi.zoom = zoom
	
	return vi

end

function viewInformation:setPos(nPos)

	self.pos.x(self.pos.x(), nPos.x, 1, 0, self.gameSize.x - self.screenSize.x)
	self.pos.y(self.pos.y(), nPos.y, 1, 0, self.gameSize.y - self.screenSize.y)

end

function viewInformation:setZoom(nZoom)

	self.zoom = nZoom

end
