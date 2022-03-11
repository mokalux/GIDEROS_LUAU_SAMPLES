LevelX = Core.class(Sprite)

function LevelX:init()
	-- create r3d physics world
	self.world=r3d.World.new(0,-9.8,0)
	-- some lists to store coming objects (static bodies, ...)
	self.world.staticbodies = {}
	self.world.kinematicbodies = {}
	self.world.dynamicbodies = {}
	self.world.otherbodies = {}
	-- set up a fullscreen 3D camera
	self.camera=D3.View.new(myappwidth, myappheight, 45, 0.1, 1000) -- fov, near plane, far plane
	-- setup our scene
	self.scene=self.camera:getScene()
	-- build the levels out of Tiled
	self.tiled_level = Tiled_Levels.new(self.world, self.camera, "tiled/levels/level02A.lua")
	-- the skybox (still wip/to do)
	local skybox
	if g_current_level == 1 then
		skybox=D3.Sphere.new(32,512) -- steps, radius
		skybox:mapTexture(Texture.new("gfx/envbox.jpg"))
--		skybox:setY(2)
	elseif g_current_level == 2 then
	end
	-- a glb dungeon
--	local roomf=Glb.new(nil,"models/env/dungeon.glb")
--	local rooms=G3DFormat.buildG3D(roomf:getScene())
--	rooms:updateMode(D3.Mesh.MODE_LIGHTING)
--	rooms:setScale(1,1,1)
	-- order
	self.scene:addChild(skybox)
--	self.scene:addChild(rooms)
	self.scene:addChild(self.tiled_level.player1)
	for k, v in pairs(self.world.staticbodies) do self.scene:addChild(k) end
	for k, v in pairs(self.world.kinematicbodies) do self.scene:addChild(k) end
	for k, v in pairs(self.world.dynamicbodies) do self.scene:addChild(k) end
	for k, v in pairs(self.world.otherbodies) do self.scene:addChild(k) end
	-- debug draw
--	local debugDraw = r3d.DebugDraw.new(self.world)
--	self.scene:addChild(debugDraw)
	-- finally
	self:addChild(self.camera)
	-- light
	Lighting.setLight(5,10,10,0.3) -- (15,30,0,0.3)
	Lighting.setLightTarget(0,2,0,30,45) -- (0,0,0,40,120)
	-- camera setup
--	self.camera:lookAt(0,10,-20,0,5,0)
	-- player listeners
	self:addEventListener(Event.KEY_DOWN, self.tiled_level.player1.onKeyDown, self.tiled_level.player1)
	self:addEventListener(Event.KEY_UP, self.tiled_level.player1.onKeyUp, self.tiled_level.player1)
	-- scene listeners
	self:addEventListener("enterBegin", self.onTransitionInBegin, self)
	self:addEventListener("enterEnd", self.onTransitionInEnd, self)
	self:addEventListener("exitBegin", self.onTransitionOutBegin, self)
	self:addEventListener("exitEnd", self.onTransitionOutEnd, self)
end

-- game loop
function LevelX:onEnterFrame(e)
	-- for the camera follow
	local matrix = self.tiled_level.player1.body:getTransform()
	local ax, ay, az = matrix:transformPoint(0, 0, 0)
	local bx, by, bz = matrix:transformPoint(0, 0, 1) -- 1 because by default the player is facing the camera
	local dx, dy, dz = bx - ax, by - ay, bz - az
--	dx, dy, dz = math.normalize(dx), math.normalize(dy), math.normalize(dz)
--	dx, dy, dz = math.normalize(dx, dy, dz)
	-- r3d physics simulation
	self.world:step(e.deltaTime)
	-- move player
	local force = 5 * self.tiled_level.player1.body:getMass()
	-- position the player model along its body
	self.tiled_level.player1:setMatrix(matrix)
	-- controls
	if self.tiled_level.player1.isup and not self.tiled_level.player1.isdown then
--		D3Anim.setAnimation(self.tiled_level.player1.mesh, self.tiled_level.player1.animWalk.animations[2], "main", true, 0.5)
		self.tiled_level.player1.body:applyLocalForceAtCenterOfMass(0, 0, force)
	elseif self.tiled_level.player1.isdown and not self.tiled_level.player1.isup then
		self.tiled_level.player1.body:applyLocalForceAtCenterOfMass(0,0,-force)
	end
	if self.tiled_level.player1.isleft and not self.tiled_level.player1.isright then
		self.tiled_level.player1.body:applyLocalTorque(0, -6, 0)
	elseif self.tiled_level.player1.isright and not self.tiled_level.player1.isleft then
		self.tiled_level.player1.body:applyLocalTorque(0, 6, 0)
	end
	if self.tiled_level.player1.isjump then
		self.tiled_level.player1.isjump = false
		self.tiled_level.player1.body:applyLocalForceAtCenterOfMass(0, 64*8, 0)
	end
	-- the camera FPS style
	local camx, camy, camz = matrix:getPosition()
	camx += -dx * 7 -- 2 8 16
	camy += 0.5 -- 4
	camz += -dz * 6 -- 2 8 16
	self.camera:lookAt(
		camx + 0, camy + 2, camz - 0,
		self.tiled_level.player1:getX() + 0, self.tiled_level.player1:getY() + 1.5, self.tiled_level.player1:getZ() + 0,
		0, 1, 0
	)
	-- lighting
	local px, py, pz = matrix:transformPoint(0, 0, 0) -- hgy29
	Lighting.setLight(px, py+8, pz+1, 0.2) -- (px-4, py+6, pz-6, 0.01) hgy29
	Lighting.setLightTarget(px, py, pz, 32, 20) -- (px, py, pz, 12, 20) hgy29 12, 20
	--Compute shadows
	Lighting.computeShadows(self.scene)
	-- other dynamics
	local matrix2
	for k, v in pairs(self.world.dynamicbodies) do
--		v:applyForce(math.random(-4, 4), math.random(6, 12), math.random(-4, 4))
--		v:applyForce(0, 12, math.random(-4, 4))
		matrix2 = v:getTransform()
		k:setMatrix(matrix2)
	end
	--Animation engine tick
	D3Anim.tick()
end

-- EVENT LISTENERS
function LevelX:onTransitionInBegin() self:addEventListener(Event.ENTER_FRAME, self.onEnterFrame, self) end
function LevelX:onTransitionInEnd() self:myKeysPressed() end
function LevelX:onTransitionOutBegin() self:removeEventListener(Event.ENTER_FRAME, self.onEnterFrame, self) end
function LevelX:onTransitionOutEnd() end

-- KEYS HANDLER
function LevelX:myKeysPressed()
	self:addEventListener(Event.KEY_DOWN, function(e)
		-- for mobiles and desktops
		if e.keyCode == KeyCode.BACK or e.keyCode == KeyCode.ESC then
			scenemanager:changeScene("menu", 1, transitions[2], easing.outBack)
		end
		-- fullscreen
		local modifier = application:getKeyboardModifiers()
		local alt = (modifier & KeyCode.MODIFIER_ALT) > 0
		if alt and e.keyCode == KeyCode.ENTER then
			isfullscreen = not isfullscreen
			fullScreen(isfullscreen)
		end
	end)
end

-- change scene
function LevelX:gotoScene(xscene)
	scenemanager:changeScene( xscene, 1,
		transitions[math.random(1, #transitions)], easings[math.random(1, #easings)] )
end
