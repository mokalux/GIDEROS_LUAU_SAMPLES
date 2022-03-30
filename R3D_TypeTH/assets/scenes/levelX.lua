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
	self.camera=D3.View.new(myappwidth, myappheight, 45, 8, 256*5) -- fov, near plane, far plane
	-- setup our scene
	self.scene=self.camera:getScene()
	-- build the levels out of Tiled
	self.tiled_level = Tiled_Levels.new(self.world, self.camera, "tiled/levels/levelH01A.lua")
	-- order
	self.scene:addChild(self.tiled_level.skybox.view)
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
	-- fixed camera
	self.playerxinit, self.playeryinit, self.playerzinit = self.tiled_level.player1.body:getTransform():getPosition()
	self.camera:lookAt(self.playerxinit+12, self.playeryinit-0, self.playerzinit+8*32, -- eye
		self.playerxinit+12, self.playeryinit, self.playerzinit, -- target
		0,1,0 -- axis
	)
	-- world listener
--	self.world:setEventListener(function() print("xxx") end) -- BUG!?
	-- player listeners
	self:addEventListener(Event.KEY_DOWN, self.tiled_level.player1.onKeyDown, self.tiled_level.player1)
	self:addEventListener(Event.KEY_UP, self.tiled_level.player1.onKeyUp, self.tiled_level.player1)
	-- scene listeners
	self:addEventListener("enterBegin", self.onTransitionInBegin, self)
	self:addEventListener("enterEnd", self.onTransitionInEnd, self)
	self:addEventListener("exitBegin", self.onTransitionOutBegin, self)
	self:addEventListener("exitEnd", self.onTransitionOutEnd, self)
end

-- collision callback
function LevelX:player1CollisionCallBack()
	print("player1 down!")
--	print(self.tiled_level.player1.view) -- BUG!?
end

-- game loop
local speed = 8*6
local matrix2
local landspeed = 0.05
local skyboxRotation = 0
function LevelX:onEnterFrame(e)
	-- rotate skybox
	skyboxRotation+=landspeed*0.1
	self.tiled_level.skybox.view:setRotationY(skyboxRotation)
	-- destroy body before physics step
	for k, v in pairs(self.world.missiles) do
		if v.isdirty then 
			self.world.missiles[k] = nil -- remove from list
			self.world:destroyBody(v.body) -- remove from the collision world
			self.scene:removeChild(k) -- remove the missile from the game
		end
	end
	-- r3d physics simulation
	self.world:step(e.deltaTime)
	-- for the camera follow
	local matrix = self.tiled_level.player1.body:getTransform()
	local playerx, playery, playerz = self.tiled_level.player1.body:getTransform():getPosition()
	-- move player
	if self.tiled_level.player1.isleft and not self.tiled_level.player1.isright then
		if playerx > -9 then
			self.tiled_level.player1.body:applyLocalForceAtCenterOfMass(0, 0, -speed)
		end
	elseif self.tiled_level.player1.isright and not self.tiled_level.player1.isleft then
		if playerx < 50 then
			self.tiled_level.player1.body:applyLocalForceAtCenterOfMass(0, 0, speed)
		end
	end
	if self.tiled_level.player1.isup and not self.tiled_level.player1.isdown then
		self.tiled_level.player1.body:applyLocalForceAtCenterOfMass(0, speed*1.3, 0)
	elseif self.tiled_level.player1.isdown and not self.tiled_level.player1.isup then
		self.tiled_level.player1.body:applyLocalForceAtCenterOfMass(0, -speed*1.3, 0)
	end
	if self.tiled_level.player1.isaction1 then
		Missile.new(self.world, self.scene, "models/missiles", "mk_missile01.obj", {
			posx=playerx, posy=playery-0.05, posz=playerz-1,
			scalex=8,
			mass=0,
			BIT=G_BITPLAYERBULLET, colBIT=playerbulletcollisions, ROLE=G_PLAYER_BULLET,
		})
		self.tiled_level.player1.isaction1 = false
	end
	if self.tiled_level.player1.isaction2 then end
	-- position the player model along its body
	self.tiled_level.player1.view:setMatrix(matrix)
	-- camera follow only on Y axis
	self.camera:lookAt(self.playerxinit+12, playery-0, self.playerzinit+8*12, -- eye
		self.playerxinit+12, playery, self.playerzinit, -- target
		0,1,0 -- axis
	)
	-- move missiles
	for k, v in pairs(self.world.missiles) do
		matrix2 = v.body:getTransform()
		local mpx, mpy, mpz = matrix2:getPosition()
		matrix2:setPosition(mpx+speed*0.04, mpy, mpz)
		v.body:setTransform(matrix2)
		k:setMatrix(matrix2)
	end
	for k, v in pairs(self.world.missiles) do
		if math.distance(playerx, playery, playerz, v.body:getTransform():getPosition()) > 16*4 then
			v.isdirty=true
		end
	end
	-- move other bodies
	for _, v in pairs(self.world.deco) do -- k=index, v=view
		v:setX(v:getX()-landspeed)
	end
	for k, v in pairs(self.world.staticbodies) do -- k=view, v=body (walls, ...)
		matrix2 = v:getTransform()
		local px, py, pz = matrix2:getPosition()
		matrix2:setPosition(px-landspeed, py, pz)
		v:setTransform(matrix2)
		k:setMatrix(matrix2)
		-- test collisions
		self.world:testCollision(v, self.tiled_level.player1.body, self.player1CollisionCallBack) -- BUG!?
	end
	for k, v in pairs(self.world.dynamicbodies) do -- k=view, v=body (nmes, ...)
		matrix2 = v:getTransform()
		local px, py, pz = matrix2:getPosition()
		matrix2:setPosition(px-landspeed*3, py, pz) -- magik
		v:setTransform(matrix2)
		k:setMatrix(matrix2)
	end
	--Animation engine tick
--	D3Anim.tick()
	-- lighting + shadows
	local px, py, pz = matrix:transformPoint(0, 0, 0) -- hgy29
	Lighting.setLight(px-0.01, py-8*1, pz-0.01, 0.5) -- x,y,z,ambient
	Lighting.setLightTarget(px, py, pz, 8*4, 8*3) -- x,y,z, DIST, FOV
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

-- change scene
function LevelX:gotoScene(xscene)
	scenemanager:changeScene( xscene, 1,
		transitions[math.random(1, #transitions)], easings[math.random(1, #easings)] )
end
