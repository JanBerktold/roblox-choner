-- Jan Berktold, 2013

local choner = _G.chonerData

local CurrentTerrain
local Generating = false

local Instance_new = Instance.new
local Vector3_new = Vector3.new
local CFrame_new = CFrame.new
local math_random = math.random
local Vector2_new = Vector2.new
local math_min = math.min
local math_max = math.max

local Settings = {
	Smoothness = 2.5,
	
	MinHeight = 1,
	MaxHeight = 40,
	
	CellSize = 1,
	NodeAmount = 100,
	
	WorldStartHeight = 2
		
}

local lastWait = tick()

local function doWait()
	if tick() - lastWait >= 1 / 30 then
		wait(0)
		lastWait = tick()
	end	
end

function choner.setTerrainSetting(Key, Value)
	if Settings[Key] ~= nil then
		Settings[Key] = Value
	end
end

function choner.generateTerrain()
	math.randomseed((tick() * time()) % 2)
	
	-- make sure we don't run several times
	if not Generating then
		Generating = true
		
		-- used to keep track of all cells
			local Cells = {}
		
		-- starting height
			local StartHeight = math_random(Settings.MinHeight, Settings.MaxHeight)
		
		-- terrain model
			local Model = Instance.new('Model', workspace)
			Model.Archivable = false
			Model.Name = 'Terrain'
			
		-- some lil' helpful stuff
			local function getProximateCell(Point, Offset)
				local newPoint = Vector2_new(Point.X + Offset.X, Point.Y + Offset.Y)
				if Cells[newPoint.X] then
					return Cells[newPoint.X][newPoint.Y]
				end
			end
			
		-- runtime variables
			local currentDirection = 1
			local formerHeight = 1
			
			for x = 1, Settings.NodeAmount do
				Cells[x] = {}
				for z = 1, Settings.NodeAmount do
					
					-- who doesn't like nice declarations
						local cellPoint = Vector2_new(x, z)
						local proximateX = getProximateCell(cellPoint, Vector2_new(-1, 0))
						local proximateZ = getProximateCell(cellPoint, Vector2_new(0, -1))
					
					-- adjust direction
						if formerHeight == Settings.MinHeight then
							currentDirection = 1
						elseif formerHeight >= Settings.MaxHeight then
							currentDirection = -1
						elseif math_random(20) == 1 then
							currentDirection = math_random(2) == 1 and 1 or -1
						end
						
					-- generate some nice height
						local cellHeight
						
						if not proximateX and not proximateZ then
							cellHeight = Settings.MinHeight
						elseif proximateX and not proximateZ then
							local change = math_random(0, Settings.Smoothness) * currentDirection					
							cellHeight = proximateX.Height + change
						elseif not proximateX and proximateZ then
							local change = math_random(0, Settings.Smoothness) * currentDirection					
							cellHeight = proximateZ.Height + change
						elseif proximateX and proximateZ then
							local change = math_random(0, Settings.Smoothness) * currentDirection	 
							cellHeight = (proximateX.Height + proximateZ.Height) / 2 + change
						end
						
						cellHeight = math_min(cellHeight, Settings.MaxHeight)
						cellHeight = math_max(cellHeight, Settings.MinHeight)
						
					-- generate parts!
						local Part = Instance_new('Part', Model)
						Part.FormFactor = Enum.FormFactor.Custom
						Part.Anchored = true
						Part.Size = Vector3_new(Settings.CellSize, cellHeight, Settings.CellSize)
						Part.CFrame = CFrame_new(Settings.CellSize * (x - 1) - (Settings.CellSize * Settings.NodeAmount * 0.5), Settings.WorldStartHeight + (cellHeight / 2), Settings.CellSize * (z - 1) - (Settings.CellSize * Settings.NodeAmount * 0.5))
						
					-- color
						Part.BrickColor =
							   (cellHeight >= (Settings.MaxHeight - Settings.MinHeight) * .75) and BrickColor.new('Dark stone grey')
							or (cellHeight >= (Settings.MaxHeight - Settings.MinHeight) * .3) and BrickColor.new('Bright green')
							or (cellHeight >= (Settings.MaxHeight - Settings.MinHeight) * .2) and BrickColor.new('Bright yellow')
							or BrickColor.new('Bright blue')
							
					-- material
						Part.Material =
							   (cellHeight >= (Settings.MaxHeight - Settings.MinHeight) * .75) and Enum.Material.Slate
							or (cellHeight >= (Settings.MaxHeight - Settings.MinHeight) * .3) and Enum.Material.Grass
							or (cellHeight >= (Settings.MaxHeight - Settings.MinHeight) * .2) and Enum.Material.Sand
							or Enum.Material.Ice	
							
					-- keep track of cell
						Cells[x][z] = {
							Height = cellHeight,
							Part = Part	
						}
						
					-- save height
						formerHeight = cellHeight
				
					doWait()		
				end
			end
			
		Generating = false	
	end
end