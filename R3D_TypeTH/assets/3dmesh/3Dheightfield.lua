--!NEEDS:3DMESH.lua

-- Height Field Shapes Builder
local HeightField3Db=Core.class(Mesh3Db)

function HeightField3Db:init(nbc, nbr, ht)
	local va,ia,na={},{},{}
	local i, v = 1, 1
--	local c, r = 0, 0
	for y = 1, nbr/2 - 1 do -- index array
		print("*** changed ***")
		for x = 1, nbc/2 - 1 do 
--			ia[i]= v	i+=1
--			ia[i]= v+1	i+=1
--			ia[i]= a	i+=1
--			ia[i]= v	i+=1
--			ia[i]= a	i+=1
--			ia[i]= a-1	i+=1

			ia[i+0]= v
			ia[i+1]= v+1
			ia[i+2]= v+2
			ia[i+3]= v
			ia[i+4]= v+2
			ia[i+5]= v+3

			v += 3

			ia[i+6]= v
			ia[i+7]= v-1
			ia[i+8]= v+2
			ia[i+9]= v
			ia[i+10]= v+2
			ia[i+11]= v+1

			print("xxx", ia[i],ia[i+1],ia[i+2],ia[i+3],ia[i+4],ia[i+5],ia[i+6],ia[i+7],ia[i+8],ia[i+9],ia[i+10],ia[i+11])
			v += 1
			i += 12
--			c += 3
		end
	end
--	for i2 = 1, #ia do print("xxx", ia[i2]) end

	i, v = 1, 1
	for y = 1, nbr do -- vertex and normal array
		for x = 1, nbc do
			va[i]=x		na[i]=0		i+=1
			va[i]=ht[v]	na[i]=1		i+=1
			va[i]=y		na[i]=0		i+=1
			v+=1
		end
	end
--	for i3 = 1, #na, 3 do print("yyy", na[i3], na[i3+1], na[i3+2]) end
--	for i4 = 1, #va, 3 do print("zzz", va[i4], va[i4+1], va[i4+2]) end

	self:setGenericArray(3,Shader.DFLOAT,3,#na/3,na)
	self:setVertexArray(va)
	self:setIndexArray(ia)
	self._va=va self._ia=ia
	self._nbc=nbc self._nbr=nbr
end

function HeightField3Db:mapTexture(texture,sw,sh) -- texture path, texture array, tex scale x, tex scale y
	self:setTexture(texture)
	if texture then
		local tw,th=texture:getWidth()*(sw or 1),texture:getHeight()*(sh or 1)
		local va={}
		local i=1
		--TexCoords
		for xi=0,(self._nbc*self._nbr)/4 do
			va[i]=0 i+=1
			va[i]=0 i+=1
			va[i]=0 i+=1
			va[i]=tw i+=1
			va[i]=tw i+=1
			va[i]=th i+=1
			va[i]=0 i+=1
			va[i]=th i+=1
		end
		self:setTextureCoordinateArray(va)
		self:updateMode(Mesh3Db.MODE_TEXTURE,0)
	else
		self:updateMode(0,Mesh3Db.MODE_TEXTURE)
	end
end

--function HeightField3Db:getCollisionShape()
--end


-- *****************************
HeightField3D = Core.class(Sprite)

function HeightField3D:init(xworld, xparams)
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

	-- the mesh (FOR TESTING PURPOSES)
	local nbc, nbr = 6, 6
	local minh, maxh = 0, 2
	local ht = {
		0,0,0,0,0,2,
		0,0,0,0,0,0,
		0,1,1,0,0,0,
		0,1,1,0,0,0,
		0,0,0,0,0,0,
		0,0,0,0,0,2,
	}
	local mesh = HeightField3Db.new(nbc, nbr, ht)
	if params.texpath then
		mesh:mapTexture(Texture.new(params.texpath, true, {extend=false, wrap=TextureBase.REPEAT}), params.texscalex, params.texscaley)
		mesh:updateMode(Mesh3Db.MODE_LIGHTING + Mesh3Db.MODE_SHADOW + Mesh3Db.MODE_TEXTURE)
	else
		mesh:setColorArray(params.colors)
	end
	mesh:setScale(5,2,5)
	mesh:setPosition(-nbc/2*mesh:getScaleX(), -1*mesh:getScaleY(), -nbr/2*mesh:getScaleZ())
	-- we put the mesh in a viewport so we can matrix it
	local view = Viewport.new()
	view:setContent(mesh)
	-- *** REACT PHYSICS 3D ***
	-- the body
	view.body = xworld:createBody(view:getMatrix())
	if params.r3dtype then view.body:setType(params.r3dtype) end
	-- the shape (collision)
	local shape = r3d.HeightFieldShape.new(nbc, nbr, minh, maxh, ht)
	shape:setScale(5,2,5)
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
