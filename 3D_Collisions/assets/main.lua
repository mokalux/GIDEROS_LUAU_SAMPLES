r3d=require "reactphysics3d"

local sw,sh=application:getContentWidth(),application:getContentHeight()

-- Create physics world
local world=r3d.World.new(0,-9.8,0)
local camera=D3.View.new(sw,sh,45,0.1,1000) -- fov, near plane, far plane
world.bodies={}

-- A blue gradient background for the sky
local sky=Pixel.new(0xFFFFFF,1,320*3,480*3)
sky:setColor(0x00FFFF,1,0x0040FF,1,90)
sky:setPosition(-320,-240-480)

-- The Stage
stage:addChild(sky)
stage:addChild(camera)

-- Build a 100x100 floor plane (with normals)
local gplane=D3.Mesh.new()
gplane:setVertexArray{-100,1,-100, 100,1,-100, 100,1,100, -100,1,100}
local tw,th=3200,3200
gplane:setTextureCoordinateArray{0,0,tw,0,tw,th,0,th}
gplane:setGenericArray(3,Shader.DFLOAT,3,4,{ 0,1,0,0,1,0,0,1,0,0,1,0, })
gplane:setIndexArray{1,2,3,1,3,4}
gplane:setTexture(Texture.new("grass.png",true,{wrap=TextureBase.REPEAT}))
gplane:updateMode(D3.Mesh.MODE_LIGHTING|D3.Mesh.MODE_SHADOW|D3.Mesh.MODE_TEXTURE)
gplane.body=world:createBody()
gplane.body:setType(r3d.Body.STATIC_BODY)
gplane.body:createFixture(r3d.BoxShape.new(100,1,100),nil,1000)

-- A cube instance and its function
local GENCUBE=D3.Cube.new() 
GENCUBE:mapTexture(Texture.new("box.png",true))
GENCUBE:updateMode(D3.Mesh.MODE_LIGHTING|D3.Mesh.MODE_SHADOW|D3.Mesh.MODE_TEXTURE)
GENCUBE.shape=r3d.BoxShape.new(1,1,1)

function build_cube(size)
	local v=Viewport.new()
	v:setContent(GENCUBE)
	v:setPosition(math.random()*9-5,math.random()*10+10,math.random()*9-5)
	v:setRotation(math.random()*20-10)
	v:setRotationX(math.random()*20-10)
	v:setRotationY(math.random()*20-10)
	local body=world:createBody(v:getMatrix())
	body:createFixture(GENCUBE.shape,nil,1)
	-- add it to the world.bodies list
	world.bodies[#world.bodies+1]={view=v, body=body}
	return v
end

-- Setup our scene
local scene=camera:getScene()
scene:addChild(gplane)

-- Setup camera
camera:lookAt(0,10,-20,0,5,0)

-- Lighting
Lighting.setLight(15,30,0,0.3)
Lighting.setLightTarget(0,0,0,40,120)

-- Main loop
local gen, gen2=0,0
stage:addEventListener(Event.ENTER_FRAME,function(e)
	gen=gen+1 gen2=gen2+1
	-- add falling cubes every 100 frames
	if gen==100 then scene:addChild(build_cube(1)) gen=0 end
	-- should destroy body before physics engine update?
	for k,v in pairs(world.bodies) do -- key, {view, body}
		if v.body.isdirty then
			world:destroyBody(v.body)
			scene:removeChild(v.view)
			world.bodies[k] = nil
			table.remove(world.bodies, k)
		end
	end
	-- tick the physics engine
	world:step(e.deltaTime)
	-- update sprites with the new bodies transforms
	for _,v in pairs(world.bodies) do v.view:setMatrix(v.body:getTransform()) end
	-- after some time mark the body as dirty
	if gen2==400 then world.bodies[1].body.isdirty = true gen2=0 end
	-- compute shadows
	Lighting.computeShadows(scene)
end)
