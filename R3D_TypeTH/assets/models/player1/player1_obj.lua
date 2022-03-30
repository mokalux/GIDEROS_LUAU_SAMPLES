Player1 = Core.class(Sprite)

function Player1:init(xworld, xfolderpath, xobjname, xparams)
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
	params.name = xparams.name or "player1"
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
	self.body:setType(r3d.Body.DYNAMIC_BODY)
	self.body:setLinearLockAxisFactor(1, 1, 0) -- 0=locked on axis
	self.body:setAngularLockAxisFactor(0, 0, 0) -- 0=locked on axis
	self.body:setIsAllowedToSleep(false)
	self.body:setLinearDamping(3)
	self.body:setAngularDamping(1)
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
	mat.bounciness = 1
	mat.frictionCoefficient = 0
--	mat.rollingResistance = 0 -- 0 = no resistance, 1 = max resistance
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
--	self:addChild(obj)
	self:addChild(self.view)
--	-- add it to world bodies list
--	if params.r3dtype == r3d.Body.STATIC_BODY then xworld.staticbodies[self.view] = self.body
--	elseif params.r3dtype == r3d.Body.KINEMATIC_BODY then xworld.kinematicbodies[self.view] = self.body
--	elseif params.r3dtype == r3d.Body.DYNAMIC_BODY then xworld.dynamicbodies[self.view] = self.body
--	else xworld.otherbodies[self.view] = self.body
--	end
end

-- GAME LOOP
function Player1:onEnterFrame(e)
end

-- EVENT LISTENERS
function Player1:onKeyDown(e)
	-- controls
	if e.keyCode == KeyCode.I or e.keyCode == KeyCode.UP then self.isup = true end
	if e.keyCode == KeyCode.K or e.keyCode == KeyCode.DOWN then self.isdown = true end
	if e.keyCode == KeyCode.J or e.keyCode == KeyCode.LEFT then self.isleft = true end
	if e.keyCode == KeyCode.L or e.keyCode == KeyCode.RIGHT then self.isright = true end
	if e.keyCode == KeyCode.W or e.keyCode == KeyCode.SPACE then self.isaction1 = true end
	if e.keyCode == KeyCode.X then self.isaction2 = true end
	if e.keyCode == KeyCode.D then self.isdebug = true end -- for gideros debugging
	-- animations
--	if self.isup or self.isdown then -- walk
--		D3Anim.setAnimation(self.mesh, self.animWalk.animations[2], "main", true, 0.5)
--	end
--	if self.isaction2 then -- walk
--		D3Anim.setAnimation(self.mesh, self.animWalk.animations[2], "main", true, 0.5)
--	end
end

function Player1:onKeyUp(e)
	-- controls
	if e.keyCode == KeyCode.I or e.keyCode == KeyCode.UP then self.isup = false end
	if e.keyCode == KeyCode.K or e.keyCode == KeyCode.DOWN then self.isdown = false end
	if e.keyCode == KeyCode.J or e.keyCode == KeyCode.LEFT then self.isleft = false end
	if e.keyCode == KeyCode.L or e.keyCode == KeyCode.RIGHT then self.isright = false end
	if e.keyCode == KeyCode.W or e.keyCode == KeyCode.SPACE then self.isaction1 = false end
	if e.keyCode == KeyCode.X then self.isaction2 = false end
	if e.keyCode == KeyCode.D then self.isdebug = false end -- for gideros debugging
	-- animations -- IDLE
--	if not self.isup and not self.isdown and not self.isleft and not self.isright and not self.isaction2 then
--		D3Anim.setAnimation(self.mesh, self.animIdle.animations[2], "main", true, 0.5)
--	end
end
