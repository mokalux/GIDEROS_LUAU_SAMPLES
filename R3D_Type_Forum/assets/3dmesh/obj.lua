Obj = Core.class(Sprite)

function Obj:init(xworld, xfolderpath, xobjname, xparams)
	-- params
	local params = xparams or {}
	params.posx = xparams.posx or 0
	params.posy = xparams.posy or 0
	params.posz = xparams.posz or 0
	params.rotx = xparams.rotx or 0
	params.roty = xparams.roty or 0
	params.rotz = xparams.rotz or 0
	params.scalex = xparams.scalex or 1
	params.r3dtype = xparams.r3dtype or nil
	params.r3dshape = xparams.r3dshape or nil
	params.mass = xparams.mass or 1
	params.BIT = xparams.BIT or nil
	params.colBIT = xparams.colBIT or nil
	params.name = xparams.name or ""
	-- some vars
	local minx, miny, minz -- can be negative
	local maxx, maxy, maxz
	local width, height, length -- obj dimensions
	-- the .obj
	local obj = loadObj(xfolderpath, xobjname)
	minx, miny, minz = obj.min[1], obj.min[2], obj.min[3] -- can be negative numbers
	maxx, maxy, maxz = obj.max[1], obj.max[2], obj.max[3]
	width, height, length = maxx - minx, maxy - miny, maxz - minz
	width, height, length = width * params.scalex, height * params.scalex, length * params.scalex
	print("obj", params.name, width, height, length)
	-- we put the mesh in a viewport so we can matrix it
	self.view = Viewport.new()
	self.view:setContent(obj)
	-- the body
	self.view.body = xworld:createBody(self.view:getMatrix())
	if params.r3dtype then self.view.body:setType(params.r3dtype) end
	local matrix = self.view.body:getTransform()
	-- the shape
	local shape
	if params.r3dshape == "box" then
		shape = r3d.BoxShape.new(width / 2, height / 2, length / 2)
	elseif params.r3dshape == "sphere" then
		shape = r3d.SphereShape.new(height / 2)
	else
		print("### YOU NEED TO PASS A SHAPE AS ARGUMENT TO THE TABLE (r3dshape = 'box', 'sphere') ###")
		shape = nil
	end
	-- position the collision shape inside the body
	local m1 = Matrix.new()
	m1:setPosition(0, height/2, 0) -- shape position
	if shape then
		-- the fixture
		local fixture = self.view.body:createFixture(shape, m1, params.mass) -- shape, transform, mass
		-- materials
		local mat = fixture:getMaterial() -- default: bounciness = 0.5, frictionCoefficient = 0.3, rollingResistance = 0
		mat.bounciness = 1
		mat.frictionCoefficient = 1
		mat.rollingResistance = 0 -- 0 = no resistance, 1 = max resistance
		fixture:setMaterial(mat)
		-- collision bit
		if params.BIT then fixture1:setCollisionCategoryBits(params.BIT) end
		if params.colBIT then fixture1:setCollideWithMaskBits(params.colBIT) end
	end
	-- transform (for Tiled)
	if params.roty == 180 then
		matrix:setPosition(params.posx - width/2, params.posy, -params.posz + length/2)
		matrix:setRotationX(params.rotx)
		matrix:setRotationY(params.roty)
		matrix:setRotationZ(params.rotz)
	else
		matrix:setPosition(params.posx + width/2, params.posy, -params.posz - length/2)
	end
	self.view.body:setTransform(matrix)
	self.view:setMatrix(matrix)
	-- scaling
	local meshscale = params.scalex
	local scalex, scaley, scalez = meshscale, meshscale, meshscale
	self.view:setScale(scalex, scaley, scalez)
	-- add it to world bodies list
	if params.r3dtype == r3d.Body.STATIC_BODY then xworld.staticbodies[self.view] = self.view.body
	elseif params.r3dtype == r3d.Body.KINEMATIC_BODY then xworld.kinematicbodies[self.view] = self.view.body
	elseif params.r3dtype == r3d.Body.DYNAMIC_BODY then xworld.dynamicbodies[self.view] = self.view.body
	else xworld.otherbodies[self.view] = self.view.body
	end
end
