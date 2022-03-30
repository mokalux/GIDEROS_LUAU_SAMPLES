Missile = Core.class(Sprite)

function Missile:init(xworld, xscene, xfolderpath, xobjname, xparams)
	local params = xparams or {}
	params.posx = xparams.posx or 0
	params.posy = xparams.posy or 0
	params.posz = xparams.posz or 0
	params.rotx = xparams.rotx or 0
	params.roty = xparams.roty or 0
	params.rotz = xparams.rotz or 0
	params.scalex = xparams.scalex or 1
	params.scaley = xparams.scaley or params.scalex
	params.scalez = xparams.scalez or params.scalex
	params.mass = xparams.mass or 1
	params.BIT = xparams.BIT or nil
	params.colBIT = xparams.colBIT or nil
	params.name = xparams.name or "missile"
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
--	print("*", params.name, width, height, depth)
	-- scaling
	obj:setScale(params.scalex, params.scaley, params.scalez)
	-- we put the mesh in a viewport so we can matrix it
	self.view = Viewport.new()
	self.view:setContent(obj)
	-- the body
	self.body = xworld:createBody(self.view:getMatrix())
	self.body:setType(r3d.Body.DYNAMIC_BODY)
	self.body:setIsAllowedToSleep(false)
	self.body:setAngularLockAxisFactor(0, 0, 0) -- 0=no rotation on axis
	self.body:setLinearDamping(0) -- no damping
	self.body:setAngularDamping(0.5)
	-- the shape
	local shape = r3d.BoxShape.new(width/4, height/2, depth/4)
--	local shape = r3d.SphereShape.new(height/2) -- radius
--	local shape = r3d.CapsuleShape.new(width/2, height/2) -- radius, height
	-- position the collision shape inside the body
	local m1 = Matrix.new()
	m1:setPosition(0, height/2, 0) -- shape position
	-- the fixture
	local fixture = self.body:createFixture(shape, m1, params.mass) -- shape, transform, mass
	-- materials
	local mat = fixture:getMaterial() -- default: bounciness = 0.5, frictionCoefficient = 0.3, rollingResistance = 0
	mat.bounciness = 0 -- 0 = no xxx, 1 = max xxx
	mat.frictionCoefficient = 0 -- 0 = no xxx, 1 = max xxx
--	mat.massDensity = 0.1 -- 0 = no xxx, 1 = max xxx
	fixture:setMaterial(mat)
	-- collision bit
	if params.BIT then fixture:setCollisionCategoryBits(params.BIT) end
	if params.colBIT then fixture:setCollideWithMaskBits(params.colBIT) end
	-- transform (for Tiled)
	local matrix = self.body:getTransform()
	matrix:setPosition(params.posx + width/2, params.posy + height/2, params.posz + depth/2)
	matrix:setRotationX(params.rotx)
	matrix:setRotationY(params.roty)
	matrix:setRotationZ(params.rotz)
	self.body:setTransform(matrix)
	self.view:setMatrix(matrix)
	-- add it to the camera
	xscene:addChild(self.view)
	-- add it to world bodies list
	xworld.missiles[self.view] = { body=self.body, isdirty=false }
end
