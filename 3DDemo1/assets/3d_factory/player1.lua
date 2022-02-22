Player1 = Core.class(Sprite)

function Player1:init(xworld, xcamera, xparams)
	-- the params
	self.params = xparams or {}
	self.params.posx = xparams.posx or 0
	self.params.posy = xparams.posy or 0
	self.params.posz = xparams.posz or 0
	self.params.rotx = xparams.rotx or 0
	self.params.roty = xparams.roty or 0
	self.params.rotz = xparams.rotz or 0
	self.params.mass = xparams.mass or 1
	self.params.BIT = xparams.BIT or nil
	self.params.colBIT = xparams.colBIT or nil
	-- for camera positioning
	self.camera = xcamera
	-- the mesh
--	local xfilemesh = "models/monsters/YellowDragon_mesh.json"
--	local xfileanims = "models/monsters/YellowDragon_anims.json"
	local xfilemesh = "models/fantasy_female/characterLargeFemale.json"
	self.xfileanimidle = "models/fantasy_female/idle.json"
	self.xfileanimwalk = "models/fantasy_female/walk.json"
	-- load our model in gdx/g3dj format
--	self.m=buildGdx("models/fantasy_female/characterLargeFemale.json", { modelpath = "models/fantasy_female/" } )
	self.mesh = buildGdx(xfilemesh, { modelpath="models/fantasy_female/", } )
	local meshscale = 0.01 -- 0.008 0.02
	local scalex, scaley, scalez = meshscale, meshscale, meshscale
	self.mesh:setScale(scalex, scaley, scalez)
	-- some vars
	local minx, miny, minz -- can be negative
	local maxx, maxy, maxz
	local width, height, depth -- obj dimensions
	-- scale it down
	minx, miny, minz = self.mesh.min[1], self.mesh.min[2], self.mesh.min[3] -- can be negative numbers
	maxx, maxy, maxz = self.mesh.max[1], self.mesh.max[2], self.mesh.max[3]
	width, height, depth = maxx - minx, maxy - miny, maxz + minz
	width, height, depth = width * scalex, height * scaley, depth * scalez
	print("player1", width, height, depth)
	-- load two animations from g3dj files
	self.animIdle = buildGdx(self.xfileanimidle, {})
	self.animWalk = buildGdx(self.xfileanimwalk, {})
	-- sets default animation to idle
	D3Anim.setAnimation(self.mesh, self.animIdle.animations[2], "main", true, 0.5) -- ..., doloop, transition time
	-- we put the mesh in a viewport so we can matrix it
	self.view = Viewport.new()
	self.view:setContent(self.mesh)
	-- *** REACT PHYSICS 3D ***
	-- the body
	self.body = xworld:createBody(self.view:getMatrix())
	self.body:setType(r3d.Body.DYNAMIC_BODY)
--	self.body:setAngularDamping(0.5) -- 0.9 play with it!
	self.body:setAngularDamping(0.99) -- 0.9 play with it!
--	self.body:setAngularVelocity(1,1,1)
--	self.body:setAngularVelocity(0.1, 0.1, 0.1) -- 0.9 play with it!
	self.body:setLinearDamping(0.99) -- 0.9 play with it!
--	self.body:setLinearVelocity(32, 32, 32)
	-- the shape
	self.shape = r3d.BoxShape.new(width/4, height/2, depth/2)
	-- position the collision shape inside the body
	local m1 = Matrix.new()
	m1:setPosition(0, height/2, 0)
	-- the fixture
	local fixture = self.body:createFixture(self.shape, m1, self.params.mass) -- shape, position, mass
	-- materials
	local mat = fixture:getMaterial() -- default: bounciness = 0.5, frictionCoefficient = 0.3, rollingResistance = 0
	mat.bounciness = 0.5
	mat.frictionCoefficient = 0.01
	mat.rollingResistance = 0 -- 0 = no resistance, 1 = max resistance
	fixture:setMaterial(mat)
	-- collision bit
	if self.params.BIT then fixture:setCollisionCategoryBits(self.params.BIT) end
	if self.params.colBIT then fixture:setCollideWithMaskBits(self.params.colBIT) end
	-- transform (for Tiled)
	local matrix = self.body:getTransform()
--	matrix:setPosition(self.params.posx + boxshapewidth, self.params.posy or boxshapeheight + 1, -self.params.posz - boxshapedepth)
	matrix:setPosition(self.params.posx + width/2, self.params.posy + height/2, -self.params.posz - depth/2)
	matrix:setRotationX(self.params.rotx)
	matrix:setRotationY(self.params.roty)
	matrix:setRotationZ(self.params.rotz)
	self.body:setTransform(matrix)
	self.view:setMatrix(matrix)
	-- add mesh to self
	self:addChild(self.mesh)
	-- event listener
	self:addEventListener(Event.ENTER_FRAME, self.onEnterFrame, self)
--	self:addEventListener(Event.KEY_DOWN, self.onKeyDown, self)
--	self:addEventListener(Event.KEY_UP, self.onKeyUp, self)
end

-- GAME LOOP
function Player1:onEnterFrame(e)
--[[
	-- move player
	local matrix = self.body:getTransform()
	local force = 1.2 * self.body:getMass() -- 1
	local ax, ay, az = matrix:transformPoint(0, 0, 0)
	local bx, by, bz = matrix:transformPoint(0, 0, 1) -- 1 because by default the player is facing the camera
	local dx, dy, dz = bx - ax, by - ay, bz - az
	-- position the player model along its body
	self:setMatrix(matrix)
	-- controls
	if self.isup and not self.isdown then self.body:applyForce(^>dx*force, 0, ^>dz*force)
	elseif self.isdown and not self.isup then self.body:applyForce(-^>dx*force, 0, -^>dz*force)
	end
	if self.isleft and not self.isright then self.body:applyTorque(0, -force*12, 0)
	elseif self.isright and not self.isleft then self.body:applyTorque(0, force*12, 0)
	end
]]
end

-- EVENT LISTENERS
function Player1:onKeyDown(e)
	-- controls
	if e.keyCode == KeyCode.I then self.isup = true end
	if e.keyCode == KeyCode.K then self.isdown = true end
	if e.keyCode == KeyCode.J then self.isright = true end
	if e.keyCode == KeyCode.L then self.isleft = true end
	if e.keyCode == KeyCode.W then self.isjump = true end
	-- animations
	if self.isup or self.isdown then
--		D3Anim.setAnimation(self.mesh, self.anims.animations[3], "main", true, 0.5)
		D3Anim.setAnimation(self.mesh, self.animWalk.animations[2], "main", true, 0.5)
	end
	if self.isjump then
--		D3Anim.setAnimation(self.mesh, self.anims.animations[3], "main", true, 0.5)
		D3Anim.setAnimation(self.mesh, self.animIdle.animations[2], "main", true, 0.5)
	end
end

function Player1:onKeyUp(e)
	-- controls
	if e.keyCode == KeyCode.I then self.isup = false end
	if e.keyCode == KeyCode.K then self.isdown = false end
	if e.keyCode == KeyCode.J then self.isright = false end
	if e.keyCode == KeyCode.L then self.isleft = false end
	if e.keyCode == KeyCode.W then self.isjump = false end
	-- animations
	if not self.isup and not self.isdown and not self.isleft and not self.isright then
--		D3Anim.setAnimation(self.mesh, self.anims.animations[3], "main", true, 0.5)
		D3Anim.setAnimation(self.mesh, self.animIdle.animations[2], "main", true, 0.5)
	end
end
