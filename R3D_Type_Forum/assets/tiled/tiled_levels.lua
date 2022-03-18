Tiled_Levels = Core.class(Sprite)

function Tiled_Levels:init(xworld, xcamera, xtiledlevelpath)
	self.world = xworld
	-- load the tiled level
	local tiledlevel = loadfile(xtiledlevelpath)()
	-- the tiled map size
	local tilewidth, tileheight = tiledlevel.tilewidth, tiledlevel.tileheight
	self.mapwidth, self.mapheight = tiledlevel.width * tilewidth, tiledlevel.height * tileheight
	print("tile size "..tilewidth..", "..tileheight, "all in pixels.")
	print("map size "..self.mapwidth..", "..self.mapheight, "app size "..myappwidth..", "..myappheight, "all in pixels.")
	-- parse the tiled level
	local layers = tiledlevel.layers
	for i = 1, #layers do
		local layer = layers[i]
		-- GROUNDS
		-- *******
		if layer.name == "GROUNDS" then -- your Tiled layer name here!
			local levelsetup = {}
			local objects = layer.objects
			for i = 1, #objects do
				local object = objects[i]
				local mytable = nil -- mytable = intermediate table for shapes params
				-- *************
				if object.name == "skybox" then
					mytable = {
						texpath="textures/envbox.jpg", hasshadow=false,
						steps=32,
					}
				elseif object.name == "groundA" then
					mytable = {
						texpath="textures/grass.png", texscalex=8*16, texscaley=8*32,
						posy=-2,
						sizey=1,
						r3dtype=r3d.Body.STATIC_BODY,
					}
				else
					print("### GROUNDS not found ###", object.name, object.shape)
				end
				if mytable then
					levelsetup = {}
					for k, v in pairs(mytable) do levelsetup[k] = v end
					self:buildShapes(layer.name, object, levelsetup)
				end
			end
		-- PLAYABLES
		-- *********
		elseif layer.name == "PLAYABLE" then -- your Tiled layer name here!
			local objects = layer.objects
			for i = 1, #objects do
				local object = objects[i]
				-- *************
				if object.name == "player1" then
					self.player1 = Player1.new(self.world, xcamera, "models/player1", "starSparrow4.obj", {
						scalex=0.5,
						posx=object.x, posy=3, posz=object.y,
						roty=object.rotation,
						mass=1,
						BIT=G_BITPLAYER, colBIT=playercollisions, ROLE=G_PLAYER,
					})
				elseif object.name == "the_boss" then
					TheBoss.new(self.world, xcamera, {
						posx=object.x, posy=4, posz=-object.y,
						roty=math.random(-360, 360),
						mass=2,
					})
				else
					print("### PLAYABLE not found ###", object.name, object.shape)
				end
			end
		-- SHAPES
		-- *********
		elseif layer.name == "SHAPES" then -- your Tiled layer name here!
			local levelsetup = {}
			local objects = layer.objects
			for i = 1, #objects do
				local object = objects[i]
				local mytable = nil -- intermediate table for shapes params
				-- *************
				if object.name == "wall01" then
					mytable = {
						texpath="textures/Brick-0588_x3.png", texscalex=3,-- texscaley=8*3,
						sizey=8,
						r3dtype=r3d.Body.STATIC_BODY,
					}
				-- ************************************************************************
				elseif object.shape == "polygon" then
					mytable = {
						texpath="textures/Brick-0588_x3.png", texscalex=4*1024, texh=4*1024,
--						posy=0.001,
						r3dtype=r3d.Body.STATIC_BODY,
					}
				-- ************************************************************************
				else
					print("### SHAPES not found ###", object.name, object.shape)
				end
				if mytable then
					levelsetup = {}
					for k, v in pairs(mytable) do levelsetup[k] = v end
					self:buildShapes(layer.name, object, levelsetup)
				end
			end
		-- OBJECTS
		-- *********
		elseif layer.name == "OBJECTS" then -- your Tiled layer name here!
			local objects = layer.objects
			for i = 1, #objects do
				local object = objects[i]
				-- *************
				if object.name == "obj1x" then
					Obj.new(self.world, "models/objs/camel", "camel_caravan2.obj",
						{
							scalex=0.25,
							posx=object.x, posy=0, posz=-object.y,
							r3dshape="box", r3dtype=r3d.Body.STATIC_BODY,
						}
					)
				else
					print("### OBJECTS not found ###", object.name, object.shape)
				end
			end
		-- WHAT?!
		-- *************
		else
			print("WHAT?!", layer.name)
		end
	end
end

function Tiled_Levels:buildShapes(xlayer, xobject, xlevelsetup)
	local tablebase = {}
	-- ********************************
	if xobject.shape == "ellipse" then
		tablebase = {
			posx=xobject.x, posz=xobject.y,
			radius=xobject.width, rotation=xobject.rotation,
		}
		for k, v in pairs(xlevelsetup) do tablebase[k] = v end
		Sphere3D.new(self.world, tablebase)
	-- ********************************
	elseif xobject.shape == "polygon" then
		tablebase = {
			x=xobject.x, y=xobject.y,
			coords=xobject.polygon, rotation=xobject.rotation,
		}
		for k, v in pairs(xlevelsetup) do tablebase[k] = v end
--		myshape = Tiled_Shape_Polygon.new(self.world, tablebase)
--		Concaves3D.new(self.world, tablebase)
	-- ********************************
	elseif xobject.shape == "rectangle" then
		tablebase = {
			posx=xobject.x, posz=xobject.y,
			sizex=xobject.width, sizez=xobject.height,
			roty=xobject.rotation,
		}
		for k, v in pairs(xlevelsetup) do tablebase[k] = v end
		Box3D.new(self.world, tablebase)
	else
		print("*** CANNOT PROCESS THIS SHAPE! ***", xobject.shape, xobject.name)
	end
end
