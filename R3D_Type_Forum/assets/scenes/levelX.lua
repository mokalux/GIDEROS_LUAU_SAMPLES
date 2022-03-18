LevelX = Core.class(Sprite)

function LevelX:init()
	-- create r3d physics world
	self.world=r3d.World.new(0, 0, 0) -- -9.8*0.2 gravity
	-- some lists to store coming objects (deco, bodies, ...)
	self.world.deco = {}
	self.world.staticbodies = {}
	self.world.kinematicbodies = {}
	self.world.dynamicbodies = {}
	self.world.missiles = {}
	self.world.otherbodies = {}
	-- set up a fullscreen 3D camera
	self.camera=D3.View.new(myappwidth, myappheight, 90, 1, 256*16) -- fov, near plane, far plane
	-- setup our scene
	self.scene=self.camera:getScene()
	-- build the levels out of Tiled
	self.tiled_level = Tiled_Levels.new(self.world, self.camera, "tiled/levels/level01A.lua")
	self.isonfloor = false
	-- order
	self.scene:addChild(self.tiled_level.player1)
	for k, v in pairs(self.world.deco) do self.scene:addChild(v) end -- view, body
	for k, v in pairs(self.world.staticbodies) do self.scene:addChild(k) end -- view, body
	for k, v in pairs(self.world.kinematicbodies) do self.scene:addChild(k) end -- view, body
	for k, v in pairs(self.world.dynamicbodies) do self.scene:addChild(k) end -- view, body
	for k, v in pairs(self.world.otherbodies) do self.scene:addChild(k) end -- view, body
	-- debug draw
--	local debugDraw = r3d.DebugDraw.new(self.world)
--	self.scene:addChild(debugDraw)
	-- finally
	self:addChild(self.camera)
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
local speed, jumpforce = 16, 32*18
local lowerlimit, upperlimit = 2, 20
local matrix2
function LevelX:onEnterFrame(e)
	-- destroy bodies before r3d physics simulation?
	for k, v in pairs(self.world.missiles) do
		if k and k.isdirty then 
			print("xxxxxxxxxxxxx")
			-- remove from list
			self.world.missiles[k] = nil
			-- remove from the collision world
			self.world:destroyBody(v) -- CRASHES GIDEROS PLAYER
			-- remove the missile from the scene
			self.scene:removeChild(k)
		end
	end
	-- r3d physics simulation
	self.world:step(e.deltaTime)
	-- some vars
	local matrix = self.tiled_level.player1.body:getTransform()
	local playerx, playery, playerz = self.tiled_level.player1.body:getTransform():getPosition()
	-- move player
	if self.tiled_level.player1.isleft and not self.tiled_level.player1.isright then
		self.tiled_level.player1.body:applyLocalForceAtCenterOfMass(0, 0, speed)
	elseif self.tiled_level.player1.isright and not self.tiled_level.player1.isleft then
		self.tiled_level.player1.body:applyLocalForceAtCenterOfMass(0, 0, -speed)
	end
	if self.tiled_level.player1.isup and not self.tiled_level.player1.isdown then
		self.tiled_level.player1.body:applyLocalForceAtCenterOfMass(speed, 0, 0)
	elseif self.tiled_level.player1.isdown and not self.tiled_level.player1.isup then
		self.tiled_level.player1.body:applyLocalForceAtCenterOfMass(-speed, 0, 0)
	end
	if self.tiled_level.player1.isaction1 then
		Missile.new(self.world, self.scene, "models/missiles", "missile03.obj", {
			posx=playerx, posy=playery-0.05, posz=playerz-1,
			scalex=0.5,
			rotx=180,
			mass=0,
			BIT=G_BITPLAYERBULLET, colBIT=playerbulletcollisions, ROLE=G_PLAYER_BULLET,
		})
		self.tiled_level.player1.isaction1 = false
	end
	if self.tiled_level.player1.isaction2 then
		self.isonfloor = not self.isonfloor
		if self.isonfloor and playery < upperlimit then
			self.tiled_level.player1.body:applyLocalForceAtCenterOfMass(0, jumpforce, 0)
		else
			if playery > lowerlimit then
				self.tiled_level.player1.body:applyLocalForceAtCenterOfMass(0, -jumpforce, 0)
			end
		end
		self.tiled_level.player1.isaction2 = false
	end
	-- limit player position between ground and sky
	if playery > upperlimit then
		print("playery > upperlimit, player is on floor?", self.isonfloor, playery)
		self.tiled_level.player1.body:applyLocalForceAtCenterOfMass(0, -jumpforce*0.4, 0)
	elseif playery < lowerlimit then
		print("playery < lowerlimit, player is on floor?", self.isonfloor, playery)
		self.tiled_level.player1.body:applyLocalForceAtCenterOfMass(0, jumpforce*0.4, 0)
	end
	-- position the player model along its body
	self.tiled_level.player1:setMatrix(matrix)
	-- the player missiles
	for k, v in pairs(self.world.missiles) do
		local matrix2 = v:getTransform()
		local mpx, mpy, mpz = matrix2:getPosition()
--		v:applyWorldForceAtCenterOfMass(0, 0, -16*4)
		matrix2:setPosition(mpx, mpy, mpz-speed*0.025)
		v:setTransform(matrix2)
		k:setMatrix(matrix2)
	end
	for k, v in pairs(self.world.missiles) do
		if math.distance(playerx, playery, playerz, v:getTransform():getPosition()) > 16*2 then
			k.isdirty=true
		end
	end
	-- other bodies
	for k, v in pairs(self.world.dynamicbodies) do
		matrix2 = v:getTransform()
		k:setMatrix(matrix2)
	end
	-- Animation engine tick
--	D3Anim.tick()
	-- the camera
	self.camera:lookAt(playerx+16, playery+8, playerz-8,
		playerx, playery, playerz-9,
		-1,0,0
	)
	-- lighting
	local px, py, pz = matrix:transformPoint(0, 0, 0) -- hgy29
	Lighting.setLight(px+0.01, py+8, pz-2, 0.5) -- x,y,z,ambient
	Lighting.setLightTarget(px, py, pz, 32*1, 32*4) -- x,y,z, DIST, FOV
	-- compute shadows
	Lighting.computeShadows(self.scene)
end

-- EVENT LISTENERS
function LevelX:onTransitionInBegin() self:addEventListener(Event.ENTER_FRAME, self.onEnterFrame, self) end
function LevelX:onTransitionInEnd() self:myKeysPressed() end
function LevelX:onTransitionOutBegin() self:removeEventListener(Event.ENTER_FRAME, self.onEnterFrame, self) end
function LevelX:onTransitionOutEnd() end

-- KEYS HANDLER
function LevelX:myKeysPressed()
	self:addEventListener(Event.KEY_DOWN, function(e)
		if e.keyCode == KeyCode.BACK or e.keyCode == KeyCode.ESC then self:gotoScene("menu") end
	end)
end

-- go to scene X
function LevelX:gotoScene(xscene)
	scenemanager:changeScene( xscene, 1,
		transitions[math.random(1, #transitions)], easings[math.random(1, #easings)] )
end
