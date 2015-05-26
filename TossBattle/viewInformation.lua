require "tweenVal"

viewInformation = {}

viewInformation.__index = viewInformation

function viewInformation.new(pos, gameSize, screenSize, zoom)
	
	vi = {}
	setmetatable(vi, viewInformation)
	vi.zoom = zoom
	vi.pos = {}
	vi.gameSize = gameSize
	vi.screenSize = screenSize
	vi.viewSize = vi.screenSize * vi.zoom
	
	vi.pos.x = tweenVal(pos.x, pos.x, 0, 0, gameSize.x - vi.viewSize.x)
	vi.pos.y = tweenVal(pos.y, pos.y, 0, 0, gameSize.y - vi.viewSize.y)
	
	return vi

end

function viewInformation:setPos(nPos)

	self.pos.x(self.pos.x(), nPos.x, 1, 0, gameSize.x - vi.viewSize.x)
	self.pos.y(self.pos.y(), nPos.y, 1, 0, gameSize.y - vi.viewSize.y)

end

function viewInformation:setZoom(nZoom)

	self.zoom = nZoom
	self.viewSize = self.screenSize * vi.zoom

end
