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
		if layer.name == "MG" then -- your Tiled layer name here!
			local levelsetup = {}
			local objects = layer.objects
			for i = 1, #objects do
				local object = objects[i]
				local mytable = nil -- mytable = intermediate table for shapes params
				-- *************
				if object.name == "skybox" then
					self.skybox = Sphere3D.new(self.world, {
						posx=object.x, posy=object.y, posz=0,
						radius=object.width, rotation=object.rotation,
						steps=16,
						texpath="textures/Tiger_Eye_Gem_001_basecolor.jpg", texscalex=128,
						hasshadow=false,
						name="skybox",
					})
				elseif object.name == "groundA" then
					mytable = {
						texpath="gfx/grass.png", texscalex=8*12,
						r3dtype=r3d.Body.STATIC_BODY, name="ground",
					}
				elseif object.name == "wall01" then
					mytable = {
						texpath="textures/Sci-fi_Wall_009_basecolor.jpg", texscalex=32,
						sizez=8,
						r3dtype=r3d.Body.STATIC_BODY, name="wall",
					}
				elseif object.name == "player1" then
					self.player1 = Player1.new(self.world, "models/player1", "starSparrow4.obj", {
						posx=object.x, posy=object.y, posz=0,
						rotx=0, roty=90, rotz=170,
						scalex=1,
						mass=1,
						BIT=G_BITPLAYER, colBIT=playercollisions, name="player1",
					})
				elseif object.name == "nme01" then
					Obj.new(self.world, "models/player1", "starSparrow4.obj", {
						posx=object.x, posy=object.y, posz=0,
						rotx=0, roty=-90, rotz=170,
						scalex=1,
						r3dtype=r3d.Body.DYNAMIC_BODY, r3dshape="box",
						mass=1,
						BIT=G_BITENEMY, colBIT=nmecollisions, name="nme",
					})
				else
					print("### GROUNDS not found ###", object.name, object.shape)
				end
				if mytable then
					levelsetup = {}
					for k, v in pairs(mytable) do levelsetup[k] = v end
					self:buildShapes(layer.name, object, levelsetup)
				end
			end
		-- BG DECO
		-- *******
		elseif layer.name == "BG_A" then -- your Tiled layer name here!
			local levelsetup = {}
			local objects = layer.objects
			for i = 1, #objects do
				local object = objects[i]
				local mytable = nil -- mytable = intermediate table for shapes params
				-- *************
				if object.name == "deco01" then
					mytable = {
						texpath="textures/Chip006_1K_Color.jpg", texscalex=128,
						posz=-16,
						sizez=4,
						name="deco",
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
			posx=xobject.x, posy=xobject.y,
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
			posx=xobject.x, posy=xobject.y, posz=0,
			sizex=xobject.width, sizey=xobject.height,-- sizez=1,
--			roty=xobject.rotation,
		}
		for k, v in pairs(xlevelsetup) do tablebase[k] = v end
		Box3D.new(self.world, tablebase)
	else
		print("*** CANNOT PROCESS THIS SHAPE! ***", xobject.shape, xobject.name)
	end
end
