Tiled_Levels = Core.class(Sprite)

function Tiled_Levels:init(xworld, xcamera, xtiledlevelpath)
	self.world = xworld
	-- load the tiled level
	local tiledlevel = loadfile(xtiledlevelpath)()
	-- the tiled map size
	local tilewidth, tileheight = tiledlevel.tilewidth, tiledlevel.tileheight
	local mapwidth, mapheight = tiledlevel.width * tilewidth, tiledlevel.height * tileheight
	print("tile size "..tilewidth..", "..tileheight, "all in pixels.")
	print("map size "..mapwidth..", "..mapheight, "app size "..myappwidth..", "..myappheight, "all in pixels.")
	-- parse the tiled level
	local layers = tiledlevel.layers
	for i = 1, #layers do
		local layer = layers[i]
		-- GROUNDS
		-- *******
		if layer.name == "bg" then -- your Tiled layer name here!
			local levelsetup = {}
			local objects = layer.objects
			for i = 1, #objects do
				local object = objects[i]
				local mytable = nil -- mytable = intermediate table for shapes params
				-- ************* 32 * 4
				if object.name == "groundA" then
					mytable = { texpath="textures/black_sand.jpg", sizey=0.01, texscalex=12, r3dtype=r3d.Body.STATIC_BODY, }
				elseif object.name == "groundB" then
					mytable = { texpath="textures/Muddy_Pavement512.jpg", sizey=0.01, texscalex=16, r3dtype=r3d.Body.STATIC_BODY, }
				else
					mytable = { texpath="textures/Aurichalcite Deposit.jpg", sizey=0.01, texscalex=32*4, r3dtype=r3d.Body.STATIC_BODY, }
				end
				if mytable then
					levelsetup = {}
					for k, v in pairs(mytable) do levelsetup[k] = v end
					self:buildShapes(layer.name, object, levelsetup, "ground")
				end
			end
		-- WALLS
		-- *********
		elseif layer.name == "mg" then -- your Tiled layer name here!
			local levelsetup = {}
			local objects = layer.objects
			for i = 1, #objects do
				local object = objects[i]
				local mytable = nil -- intermediate table for shapes params
				-- *************
				if object.name == "wall01" then
					mytable = {
						texpath="textures/Chainmail512.png", sizey=16,
						texscalex=2, texscaley=2,
						r3dtype=r3d.Body.STATIC_BODY,
					}
				elseif object.name == "building01" then
					mytable = {
						texpath="textures/skyscraper_at_night.jpg", sizey=math.random(8,32),
						texscalex=2, texscaley=1.5,
						r3dtype=r3d.Body.STATIC_BODY,
					}
				elseif object.name == "building02" then
					mytable = {
						texpath="textures/yellow_segmented_window.jpg", sizey=math.random(8,32),
						texscalex=4, texscaley=4,
						r3dtype=r3d.Body.STATIC_BODY,
					}
				elseif object.name == "wall02" then
					mytable = {
						texpath="textures/Brick-0588_x3.png", sizey=6,
						texscalex=2, texscaley=1,
						r3dtype=r3d.Body.STATIC_BODY,
					}
				elseif object.name == "obj1" then
					mytable = nil
					local myshape = Obj.new(self.world, "models/objs/camel", "camel_caravan2.obj",
						{
							scalex=0.25,
							posx=object.x, posy=0, posz=object.y,
							r3dshape="box", r3dtype=r3d.Body.STATIC_BODY,
						}
					)
				else
					print("### model not found ###", object.name)
				end
				if mytable then
					levelsetup = {}
					for k, v in pairs(mytable) do levelsetup[k] = v end
					self:buildShapes(layer.name, object, levelsetup)
				end
			end
--[[
			for i = 1, #objects do
				local object = objects[i]
				local mytable = nil -- intermediate table for shapes params
				-- SHAPES
				if object.shape == "ellipse" then
					mytable = {
						steps=32,
						texpath="textures/Purple Crystal512.jpg", texscalex=4,
						r3dtype=r3d.Body.STATIC_BODY,
					}
				-- *************
				elseif object.shape == "polygon" then
					mytable = {
						texpath="textures/Grassy Way.jpg", texscalex=4*1024, texh=4*1024,
						r3dtype=r3d.Body.STATIC_BODY,
					}
				end
				if mytable then
					levelsetup = {}
					for k, v in pairs(mytable) do levelsetup[k] = v end
					self:buildShapes(layer.name, object, levelsetup)
				end
			end
]]

		-- PLAYABLES
		-- *********
		elseif layer.name == "fg" then -- your Tiled layer name here!
			local levelsetup = {}
			local objects = layer.objects
			for i = 1, #objects do
				local object = objects[i]
				local mytable = nil -- mytable = intermediate table for shapes params
				-- *************
				if object.name == "player1" then
					self.player1 = Player1.new(self.world, xcamera, {
						posx=object.x, posy=16, posz=object.y,
						mass=8,
					})
				elseif object.name == "prisonner" then
					Prisonners.new(self.world, xcamera, {
						posx=object.x, posy=16, posz=object.y,
						roty=math.random(-360, 360),
						mass=8,
					})
				elseif object.name == "mutant" then
					Monsters.new(self.world, xcamera, {
						posx=object.x, posy=16, posz=object.y, mass=8,
					})
				elseif object.name == "the_boss" then
					TheBoss.new(self.world, xcamera, {
						posx=object.x, posy=16, posz=object.y,
						roty=object.rotation,
						mass=8,
					})
				end
			end
		-- WHAT?!
		-- *************
		else
			print("WHAT?!", layer.name)
		end
	end
end

function Tiled_Levels:buildShapes(xlayer, xobject, xlevelsetup, xextras)
	local myshape = nil
	local tablebase = {}
	-- ********************************
	if xobject.shape == "ellipse" then
		tablebase = {
			posx=xobject.x, posz=xobject.y,
			radius=xobject.width, rotation=xobject.rotation,
		}
		for k, v in pairs(xlevelsetup) do tablebase[k] = v end
		myshape = Sphere3D.new(self.world, tablebase)
	-- ********************************
	elseif xobject.shape == "polygon" then
		tablebase = {
			x=xobject.x, y=xobject.y,
			coords=xobject.polygon, rotation=xobject.rotation,
		}
		for k, v in pairs(xlevelsetup) do tablebase[k] = v end
--		myshape = Tiled_Shape_Polygon.new(self.world, tablebase)
	-- ********************************
	elseif xobject.shape == "rectangle" then
		tablebase = {
			posx=xobject.x, posz=xobject.y,
			sizex=xobject.width, sizez=xobject.height,
			roty=xobject.rotation,
		}
		for k, v in pairs(xlevelsetup) do tablebase[k] = v end
		if xextras == "ground" then
			myshape = Plane3D.new(self.world, tablebase)
--			myshape = Box3D.new(self.world, tablebase)
		else
			myshape = Box3D.new(self.world, tablebase)
		end
	else
		print("*** CANNOT PROCESS THIS SHAPE! ***", xobject.shape, xobject.name)
	end
	myshape = nil
end
