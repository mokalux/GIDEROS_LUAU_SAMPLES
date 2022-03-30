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
	local width, height, depth -- obj dimensions
	-- the .obj
	local obj = loadObj(xfolderpath, xobjname)
	minx, miny, minz = obj.min[1], obj.min[2], obj.min[3] -- can be negative numbers
	maxx, maxy, maxz = obj.max[1], obj.max[2], obj.max[3]
	width, height, depth = maxx - minx, maxy - miny, maxz - minz
	width, height, depth = width * params.scalex, height * params.scalex, depth * params.scalex
	print("*", params.name, width, height, depth)
	-- scaling
	obj:setScale(params.scalex, params.scaley, params.scalez)
	-- we put the mesh in a viewport so we can matrix it
	self.view = Viewport.new()
	self.view:setContent(obj)
	-- the body
	self.body = xworld:createBody(self.view:getMatrix())
	if params.r3dtype then self.body:setType(params.r3dtype) end
	self.body:setLinearLockAxisFactor(1, 1, 0) -- 0=locked on axis
	self.body:setAngularLockAxisFactor(0, 0, 0) -- 0=locked on axis
	self.body:setIsAllowedToSleep(false)
	self.body:setLinearDamping(3)
	self.body:setAngularDamping(1)
	-- the shape
	local shape
	if params.r3dshape == "box" then
		shape = r3d.BoxShape.new(width / 2, height / 2, depth / 2)
	elseif params.r3dshape == "sphere" then
		shape = r3d.SphereShape.new(height / 2)
	else
		print("### YOU NEED TO PASS A SHAPE AS ARGUMENT TO THE TABLE (r3dshape = 'box', 'sphere') ###")
		shape = nil
	end
	if shape then
		-- position the collision shape inside the body
		local m1 = Matrix.new()
		m1:setPosition(0, height/2, 0) -- shape position
		-- the fixture
		local fixture = self.body:createFixture(shape, m1, params.mass) -- shape, transform, mass
		-- materials
--		local mat = fixture:getMaterial() -- default: bounciness = 0.5, frictionCoefficient = 0.3, rollingResistance = 0
--		mat.bounciness = 1 -- 0 = no bounciness, 1 = max bounciness
--		mat.frictionCoefficient = 0 -- 0 = no friction, 1 = max friction
--		fixture:setMaterial(mat)
		-- collision bit
		if params.BIT then fixture:setCollisionCategoryBits(params.BIT) end
		if params.colBIT then fixture:setCollideWithMaskBits(params.colBIT) end
	end
	-- transform (for Tiled)
	local matrix = self.body:getTransform()
	matrix:setPosition(params.posx + width/2, params.posy + height/2, params.posz + depth/2)
	matrix:setRotationX(params.rotx)
	matrix:setRotationY(params.roty)
	matrix:setRotationZ(params.rotz)
	self.body:setTransform(matrix)
	self.view:setMatrix(matrix)
	-- add it to world bodies list
	if params.r3dtype == r3d.Body.STATIC_BODY then xworld.staticbodies[self.view] = self.body
	elseif params.r3dtype == r3d.Body.KINEMATIC_BODY then xworld.kinematicbodies[self.view] = self.body
	elseif params.r3dtype == r3d.Body.DYNAMIC_BODY then xworld.dynamicbodies[self.view] = self.body
	else xworld.otherbodies[self.view] = self.body
	end
end
