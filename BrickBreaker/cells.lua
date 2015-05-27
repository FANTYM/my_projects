require "point"
cellSystem = {}
cellSystem.mt = {}
cellSystem.__index = cellSystem
cellSystem.size = point(32,32)
cellSystem.cells = {}

function cellSystem.putInCell(what)
	
	local thisCell = cellSystem.posToCell(what.pos)
		
	if cellSystem.cells[thisCell.y] == nil then
		cellSystem.cells[thisCell.y] = {}
	end
	
	if cellSystem.cells[thisCell.y][thisCell.x] == nil then
		cellSystem.cells[thisCell.y][thisCell.x] = {}
	end

	what.cellIndex = #cellSystem.cells[thisCell.y][thisCell.x] + 1
	cellSystem.cells[thisCell.y][thisCell.x][what.cellIndex] = what
	--print("put in cell complete for "  .. what.name)
	--print("in cell  " .. tostring(thisCell))
	--print("new index is " .. what.cellIndex)
	
end


function cellSystem.removeFromCell(what)

	local thisCell = cellSystem.posToCell(what.pos)
	
	table.remove(cellSystem.cells[thisCell.y][thisCell.x], what.cellIndex)
	
	--what.cellIndex = nil
	
	--print("remove from cell complete")
	--print("was in cell  " .. tostring(thisCell))
	--print("old index was " .. what.cellIndex)
	
end

function cellSystem.getCellContents(where, radius)
	
	--print("doing cell contents")
	radius = radius or 0
	returnSet = {}
	thisCell = cellSystem.posToCell(where)
	
	for y = -radius, radius do
		for x = -radius, radius do
			if not (cellSystem.cells[thisCell.y + y] == nil) then
				if not (cellSystem.cells[thisCell.y + y][thisCell.x + x] == nil) then
					for meh, ent in pairs(cellSystem.cells[thisCell.y + y][thisCell.x + x]) do
						
						returnSet[#returnSet + 1] = ent
						--print(ent.name .. " added to list")
						
					end
				end
			end
		end
	end
	--print(" ")
	return returnSet

end

function cellSystem.posToCell( where )

	return point(math.floor(where.x / cellSystem.size.x), math.floor(where.y / cellSystem.size.y))
	
end

