--!NEEDS:3DMESH.lua

-- Concave Shapes Builder
local Concaves3Db=Core.class(Mesh3Db)

function Concaves3Db:init(xva,xia,xna) -- vertex array, index array, normal array
	if not Concaves3Db.ia then
		Concaves3Db.ia=xia
		Concaves3Db.na=xna
	end
	Concaves3Db.va=xva

--	self:setGenericArray(3,Shader.DFLOAT,3,24,Concaves3Db.na) -- I need a normal array!
--	self:setGenericArray(3,Shader.DFLOAT,3,#Concaves3Db.na,Concaves3Db.na) -- I need a normal array!
	self:setVertexArray(Concaves3Db.va)
	self:setIndexArray(Concaves3Db.ia)
	self._va=Concaves3Db.va self._ia=Concaves3Db.ia
end

function Concaves3Db:mapTexture(texture,xta,sw,sh) -- texture path, texture array, tex scale x, tex scale y
	self:setTexture(texture)
	if texture then
		local tw,th=texture:getWidth()*(sw or 1),texture:getHeight()*(sh or 1)
		self:setTextureCoordinateArray(xta)
		self:updateMode(Mesh3Db.MODE_TEXTURE,0)
	else
		self:updateMode(0,Mesh3Db.MODE_TEXTURE)
	end
end

--function Concaves3Db:getCollisionShape()
--end


-- *****************************
Concaves3D = Core.class(Sprite)

function Concaves3D:init(xworld, xparams)
	-- the params
	local params = xparams or {}
	params.posx = xparams.posx or 0
	params.posy = xparams.posy or 0
	params.posz = xparams.posz or 0
	params.sizex = xparams.sizex/2 or 1
	params.sizey = xparams.sizey/2 or 1
	params.sizez = xparams.sizez/2 or params.sizex
	params.rotx = xparams.rotx or 0
	params.roty = xparams.roty or 0
	params.rotz = xparams.rotz or 0

	params.vertices = xparams.vertices or nil
	params.indices = xparams.indices or nil
	params.colors = xparams.colors or nil

	params.texpath = xparams.texpath or nil
	params.texscalex = xparams.texscalex or 1
	params.texscaley = xparams.texscaley or 1
	params.texarray = xparams.texarray or nil
	params.r3dtype = xparams.r3dtype or nil
	params.mass = xparams.mass or 1
	params.BIT = xparams.BIT or nil
	params.colBIT = xparams.colBIT or nil

	params.bounciness = xparams.bounciness or 1
	params.frictionr = xparams.frictionr or 1
	params.rollingr = xparams.rollingr or 1 -- 0 = no resistance, 1 = max resistance

	-- the mesh
	local mesh = Concaves3Db.new(params.vertices, params.indices, nil)
	if params.texpath then
		mesh:mapTexture(Texture.new(params.texpath, true, {extend=false, wrap=TextureBase.REPEAT}), params.texarray, params.texscalex, params.texscaley)
		mesh:updateMode(Mesh3Db.MODE_LIGHTING + Mesh3Db.MODE_SHADOW + Mesh3Db.MODE_TEXTURE)
		mesh:setColorArray(params.colors)
	else
--		mesh:setColorArray(params.colors)
	end
	-- some text (for debugging)
	local xt = 1
	for i = 1, #params.vertices, 3 do
		local t = TextField.new(nil, xt)
		t:setScale(0.5)
		t:setTextColor(0xffff00)
		local x,y,z = params.vertices[i], params.vertices[i+1], params.vertices[i+2]
--		print(x,y,z)
		t:setPosition(x,y,z)
		t:setRotationX(180)
--		t:setRotationY(180)
		mesh:addChild(t)
		xt+=1
	end
	-- we put the mesh in a viewport so we can matrix it
	local view = Viewport.new()
	view:setContent(mesh)
	-- *** REACT PHYSICS 3D ***
	-- the body
	view.body = xworld:createBody(view:getMatrix())
	if params.r3dtype then view.body:setType(params.r3dtype) end
	-- the shape (collision)
	local shape = r3d.ConcaveMeshShape.new(params.vertices, params.indices)
	-- position the collision shape inside the body
	local m1 = Matrix.new()
	m1:setPosition(0, 0, 0)
	-- the fixture
	local fixture = view.body:createFixture(shape, m1, xparams.mass) -- shape, transform, mass
	-- materials
--	local mat = fixture:getMaterial() -- default: bounciness = 0.5, frictionCoefficient = 0.3, rollingResistance = 0
--	mat.bounciness = params.bounciness
--	mat.frictionCoefficient = params.frictionr
--	mat.rollingResistance = params.rollingr
--	fixture:setMaterial(mat)
	-- collision filtering
	if params.BIT then fixture:setCollisionCategoryBits(params.BIT) end
	if params.colBIT then fixture:setCollideWithMaskBits(params.colBIT) end
	-- transform (for Tiled)
	local matrix = view.body:getTransform()
	matrix:setPosition(params.posx + params.sizex, params.posy + params.sizey, -params.posz - params.sizez)
	matrix:setRotationX(params.rotx)
	matrix:setRotationY(params.roty)
	matrix:setRotationZ(params.rotz)
	view.body:setTransform(matrix)
	view:setMatrix(matrix)
	-- add it to world bodies list
	if params.r3dtype == r3d.Body.STATIC_BODY then xworld.staticbodies[view] = view.body
	elseif params.r3dtype == r3d.Body.KINEMATIC_BODY then xworld.kinematicbodies[view] = view.body
	elseif params.r3dtype == r3d.Body.DYNAMIC_BODY then xworld.dynamicbodies[view] = view.body
	else xworld.otherbodies[view] = view.body
	end
end
