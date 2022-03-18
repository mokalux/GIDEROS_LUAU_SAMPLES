Player1 = Core.class(Sprite)

function Player1:init(xworld, xcamera, xfolderpath, xobjname, xparams)
	-- params
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
	params.ROLE = xparams.ROLE or nil
	params.name = xparams.name or "player1"
	-- some vars
	self.camera = xcamera
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
	self.body:setType(r3d.Body.DYNAMIC_BODY)
	self.body:setIsAllowedToSleep(false)
	self.body:setAngularLockAxisFactor(0, 0, 0) -- 0 = no rotation on axis xxx
	self.body:setLinearDamping(0.9) -- 0 = no damping, can be greater than 1
	self.body:setAngularDamping(1) -- 0 = no damping, can be greater than 1
	-- the shape
	local shape = r3d.BoxShape.new(width/4, height/2, depth/4)
	-- position the collision shape inside the body
	local m1 = Matrix.new()
	m1:setPosition(0, height/2, 0) -- shape position
	-- the fixture
	local fixture = self.body:createFixture(shape, m1, params.mass) -- shape, transform, mass
	-- materials
	local mat = fixture:getMaterial() -- default: bounciness = 0.5, frictionCoefficient = 0.3, rollingResistance = 0
	mat.bounciness = 1
	mat.frictionCoefficient = 0
--	mat.massDensity = 0.1 -- CAUTIOUS MUST NO BE ZERO OR GIDEROS PLAYER WILL CRASH!
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
	-- add mesh to self
	self:addChild(obj)
end

-- CONTROLS
function Player1:onKeyDown(e)
	if e.keyCode == KeyCode.I then self.isup = true end
	if e.keyCode == KeyCode.K then self.isdown = true end
	if e.keyCode == KeyCode.L then self.isleft = true end
	if e.keyCode == KeyCode.J then self.isright = true end
	if e.keyCode == KeyCode.W then self.isaction1 = true end
	if e.keyCode == KeyCode.X then self.isaction2 = true end
end

function Player1:onKeyUp(e)
	if e.keyCode == KeyCode.I then self.isup = false end
	if e.keyCode == KeyCode.K then self.isdown = false end
	if e.keyCode == KeyCode.L then self.isleft = false end
	if e.keyCode == KeyCode.J then self.isright = false end
	if e.keyCode == KeyCode.W then self.isaction1 = false end
	if e.keyCode == KeyCode.X then self.isaction2 = false end
end
