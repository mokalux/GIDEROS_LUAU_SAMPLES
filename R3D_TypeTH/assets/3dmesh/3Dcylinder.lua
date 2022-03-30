--!NEEDS:3DMESH.lua

-- Cylinder Builder
local Cylinder3Db=Core.class(Mesh3Db)

function Cylinder3Db:init(steps,r,h)
	local h=h or 1 local r=r or 1
	local va,ia,na={},{},{}
--	local rs=(2*3.141592654)/steps
	local rs=(2*math.pi)/steps
	local i,ni=7,1
	--Vertices/Normals
--	va[1]=0 va[2]=h va[3]=0 va[4]=0 va[5]=-h va[6]=0
	va[1]=0 va[2]=h/2 va[3]=0 va[4]=0 va[5]=-h/2 va[6]=0
	na[1]=0 na[2]=1 na[3]=0 na[4]=0 na[5]=-1 na[6]=0
	for ix=0,steps do
		local x=math.cos(ix*rs)*r
		local z=-math.sin(ix*rs)*r
		va[i]=x na[i]=0 i+=1
		va[i]=h/2 na[i]=1 i+=1
		va[i]=z na[i]=0 i+=1
		va[i]=x na[i]=x i+=1
		va[i]=h/2 na[i]=0 i+=1
		va[i]=z na[i]=z i+=1
		va[i]=x na[i]=x i+=1
		va[i]=-h/2 na[i]=0 i+=1
		va[i]=z na[i]=z i+=1
		va[i]=x na[i]=0 i+=1
		va[i]=-h/2 na[i]=-1 i+=1
		va[i]=z na[i]=0 i+=1
	end
	--Indices
	for i=3,steps*4-1,4 do
		--For rendering, take care of normals
		ia[ni]=1 ni+=1 ia[ni]=i ni+=1 ia[ni]=i+4 ni+=1
		ia[ni]=2 ni+=1 ia[ni]=i+3 ni+=1 ia[ni]=i+7 ni+=1
		ia[ni]=i+1 ni+=1 ia[ni]=i+2 ni+=1 ia[ni]=i+5 ni+=1
		ia[ni]=i+2 ni+=1 ia[ni]=i+6 ni+=1 ia[ni]=i+5 ni+=1
	end
	self:setGenericArray(3,Shader.DFLOAT,3,#na/3,na)
	self:setVertexArray(va)
	self:setIndexArray(ia)
	self._steps=steps
	self._va=va self._ia=ia
	self.dims={r=r,h=h} -- XXX
end

function Cylinder3Db:mapTexture(texture,sw,sh)
	self:setTexture(texture)
	if texture then
		local tw,th=texture:getWidth()*(sw or 1),texture:getHeight()*(sh or 1)
		local va={}
		local i=5
		--TexCoords
		local twh,thh=tw/2,th/2
		va[1]=twh va[2]=0
		va[3]=twh va[4]=th
		for xi=0,self._steps do
			local x=tw*(xi/self._steps)
			va[i]=x i+=1
			va[i]=0 i+=1
			va[i]=x i+=1
			va[i]=0 i+=1
			va[i]=x i+=1
			va[i]=th i+=1
			va[i]=x i+=1
			va[i]=th i+=1
		end
		self:setTextureCoordinateArray(va)
		self:updateMode(Mesh3Db.MODE_TEXTURE,0)
	else
		self:updateMode(0,Mesh3Db.MODE_TEXTURE)
	end
end

function Cylinder3Db:getCollisionShape()
	if not self._r3dshape then
		--for collisions, ensure a closed CCW shape
		local steps=self._steps
		local ca,fa={},{}
		local nc,nf=1,1
		for i=3,steps*4-1,4 do ca[nc]=i+1 nc+=1 end
		fa[nf]=steps nf+=1
		for i=3,steps*4-1,4 do
			ca[nc]=i+1 nc+=1 ca[nc]=i+2 nc+=1 
			ca[nc]=i+6 nc+=1 ca[nc]=i+5 nc+=1 
			fa[nf]=4 nf+=1
		end
		ca[nc-2]=5 ca[nc-1]=4
		for i=steps*4-1,3,-4 do ca[nc]=i+2 nc+=1 end
		fa[nf]=steps nf+=1
		self._r3dshape=r3d.ConvexMeshShape.new(self._va,ca,fa)
	end
	return self._r3dshape
end


-- ******************************
Cylinder3D = Core.class(Sprite)

function Cylinder3D:init(xworld, xparams)
	-- the params
	local params = xparams or {}
	params.steps = xparams.steps or 6
	params.posx = xparams.posx or 0
	params.posy = xparams.posy or 0
	params.posz = xparams.posz or 0
	params.sizex = xparams.sizex or 0
	params.sizey = xparams.sizey or params.sizex
	params.sizez = xparams.sizez or 0
	params.rotx = xparams.rotx or 0
	params.roty = xparams.roty or 0
	params.rotz = xparams.rotz or 0
	params.texpath = xparams.texpath or nil
	params.texscalex = xparams.texscalex or 1
	params.texscaley = xparams.texscaley or 1
	params.r3dtype = xparams.r3dtype or nil
	params.mass = xparams.mass or 1
	params.BIT = xparams.BIT or nil
	params.colBIT = xparams.colBIT or nil
	-- the mesh
	local mesh = Cylinder3Db.new(params.steps, params.sizex, params.sizey) -- steps, radius, height
	if params.texpath then
		mesh:mapTexture(Texture.new(params.texpath, true, {extend=false, wrap=TextureBase.REPEAT}), params.texscalex, params.texscaley)
		mesh:updateMode(Mesh3Db.MODE_LIGHTING + Mesh3Db.MODE_SHADOW + Mesh3Db.MODE_TEXTURE)
	end
	-- we put the mesh in a viewport so we can matrix it
	local view = Viewport.new()
	view:setContent(mesh)
	-- *** REACT PHYSICS 3D ***
	-- the body
	view.body = xworld:createBody(view:getMatrix())
	if params.r3dtype then view.body:setType(params.r3dtype) end
	-- the shape (collision)
	local shape = mesh:getCollisionShape()
	-- position the collision shape inside the body
	local m1 = Matrix.new()
	m1:setPosition(0, 0, 0) -- center
	-- the fixture
	local fixture = view.body:createFixture(shape, m1, params.mass)
	-- materials
--	local mat = fixture:getMaterial() -- default: bounciness = 0.5, frictionCoefficient = 0.3, rollingResistance = 0
--	mat.bounciness = 0
--	mat.frictionCoefficient = 1
--	mat.rollingResistance = 0.5 -- 0 = no resistance, 1 = max resistance
--	fixture:setMaterial(mat)
	-- collision filtering
	if params.BIT then fixture:setCollisionCategoryBits(params.BIT) end
	if params.colBIT then fixture:setCollideWithMaskBits(params.colBIT) end
	-- transform (for Tiled)
	local matrix = view.body:getTransform()
	matrix:setPosition(params.posx + params.sizex/2, params.posy + params.sizey/2, -params.posz - params.sizez/2)
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
