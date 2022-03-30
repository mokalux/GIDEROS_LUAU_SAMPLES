--[[ *** Monster Button ***
	A Button Class with Text, Pixel, Images 9patch (Up, Down, Disabled), Tooltip, Sfx and Keyboard navigation!
	github: mokalux, this code is CC0

	v 0.1.0: 2021-06-01 total recall, this class has become a Monster! best used in menus but who knows?
	v 0.0.1: 2020-03-28 init (based on the initial gideros generic button class)
]]
--[[
-- SAMPLE
]]

ButtonMonster = Core.class(Sprite)

function ButtonMonster:init(xparams, xselector)
	-- the params
	self.selector = xselector or nil -- for keyboard navigation
	self.btns = nil -- assign this value directly from your class, you assign it a list of navigatable buttons
	-- button global
	-- add btn color up and down? sprite:setColorTransform(255/255, ...)
	self.btnalphaup = xparams.btnalphaup or 1 -- number between 0 and 1
	self.btnalphadown = xparams.btnalphadown or self.btnalphaup -- number between 0 and 1
	self.btnscalexup = xparams.btnscalexup or nil -- number
	self.btnscaleyup = xparams.btnscaleyup or self.btnscalexup -- number
	self.btnscalexdown = xparams.btnscalexdown or self.btnscalexup -- number
	self.btnscaleydown = xparams.btnscaleydown or self.btnscalexdown -- number
	-- pixel?
	self.pixelcolorup = xparams.pixelcolorup or nil -- color
	self.pixelcolordown = xparams.pixelcolordown or self.pixelcolorup -- color
	self.pixelcolordisabled = xparams.pixelcolordisabled or 0x555555 -- color
	self.pixelalphaup = xparams.pixelalphaup or 1 -- number between 0 and 1
	self.pixelalphadown = xparams.pixelalphadown or self.pixelalphaup -- number between 0 and 1
	self.pixelscalexup = xparams.pixelscalexup or 1 -- number
	self.pixelscaleyup = xparams.pixelscaleyup or self.pixelscalexup -- number
	self.pixelscalexdown = xparams.pixelscalexdown or self.pixelscalexup -- number
	self.pixelscaleydown = xparams.pixelscaleydown or self.pixelscalexdown -- number
	self.pixelpaddingx = xparams.pixelpaddingx or 32 -- number
	self.pixelpaddingy = xparams.pixelpaddingy or self.pixelpaddingx -- number
	-- textures?
	self.imguppath = xparams.imguppath or nil -- img tex up path
	self.imgdownpath = xparams.imgdownpath or self.imguppath -- img tex down path
	self.imgdisabledpath = xparams.imgdisabledpath or nil -- img tex disabled path
	self.imgalphaup = xparams.imgalphaup or 1 -- number between 0 and 1
	self.imgalphadown = xparams.imgalphadown or self.imgalphaup -- number between 0 and 1
	self.imgpaddingx = xparams.imgpaddingx or 32 -- number
	self.imgpaddingy = xparams.imgpaddingy or self.imgpaddingx -- number
	-- text?
	self.text = xparams.text or nil -- string
	self.ttf = xparams.ttf or nil -- ttf
	self.textcolorup = xparams.textcolorup or 0x0 -- color
	self.textcolordown = xparams.textcolordown or self.textcolorup -- color
	self.textcolordisabled = xparams.textcolordisabled or 0x777777 -- color
	self.textalphaup = xparams.textalphaup or 1 -- number between 0 and 1
	self.textalphadown = xparams.textalphaup or self.textalphaup -- number between 0 and 1
	self.textscalexup = xparams.textscalexup or 1 -- number
	self.textscaleyup = xparams.textscaleyup or self.textscalexup -- number
	self.textscalexdown = xparams.textscalexdown or self.textscalexup -- number
	self.textscaleydown = xparams.textscaleydown or self.textscalexdown -- number
	-- tool tip?
	self.tooltiptext = xparams.tooltiptext or nil -- string
	self.tooltipttf = xparams.tooltipttf or nil -- ttf
	self.tooltiptextcolor = xparams.tooltiptextcolor or 0xff00ff -- color
	self.tooltiptextscale = xparams.tooltiptextscale or 3 -- number
	self.tooltipoffsetx = xparams.tooltipoffsetx or 0 -- number
	self.tooltipoffsety = xparams.tooltipoffsety or 0 -- number
	-- audio?
	self.channel = xparams.channel or nil -- sound channel
	self.sound = xparams.sound or nil -- sound fx
	self.volume = xparams.volume or 1 -- sound volume
	-- EXTRAS
	self.hover = xparams.hover or (xparams.hover == nil) -- boolean (default = true)
	self.isautoscale = xparams.isautoscale or (xparams.isautoscale == nil) -- boolean (default = true)
	self.fun = xparams.fun or nil -- function (please check function name if not working!)
	-- set warnings, errors
	local errors = false
	if not self.imguppath and not self.imgdownpath and not self.imgdisabledpath
		and not self.pixelcolorup and not self.text and not self.tooltiptext then
		print("*** ERROR ***", "YOUR BUTTON IS EMPTY!", "ON BUTTON: "..self.selector)
		errors = true
	end
	if self.sound and not self.channel then
		print("*** ERROR ***", "YOU HAVE A SOUND BUT NO CHANNEL!", "ON BUTTON: "..self.selector)
		errors = true
	end
	if self.fun ~= nil and type(self.fun) ~= "function" then
		print("*** ERROR ***", "YOU ARE NOT PASSING A FUNCTION", "ON BUTTON: "..self.selector)
		errors = true
	end
	if errors then
		if self.text then self.text = self.text.." (error)"
		else self.text = "error"
		end
		self.ttf = nil self.textscalexup = 4 self.textscaleyup = 4
		self.textcolorup = 0xff0000
	end
	-- button sprite holder
	self.sprite = Sprite.new()
	self:addChild(self.sprite)
	-- let's go!
	self:setButton()
	self:updateVisualState()
	-- update visual state
	self.isclicked = nil
	self.ishovered = nil
	self.isdisabled = nil
	self.onenter = nil -- flag to execute a function only once *
	self.ismoving = nil -- * flag to execute a function only once
	self.iskeyboard = nil -- to set a different tooltip position for the keyboard
	-- event listeners
	self:addEventListener(Event.MOUSE_DOWN, self.onMouseDown, self)
	self:addEventListener(Event.MOUSE_MOVE, self.onMouseMove, self)
	self:addEventListener(Event.MOUSE_UP, self.onMouseUp, self)
	self:addEventListener(Event.MOUSE_HOVER, self.onMouseHover, self)
	if not self.hover and not self.tooltiptext then
		self:removeEventListener(Event.MOUSE_HOVER, self.onMouseHover, self)
	end
end

-- FUNCTIONS
function ButtonMonster:setButton()
	local textwidth, textheight
	local bmps = {}
	-- text
	if self.text then
		if self.tf then self.sprite:removeChild(self.tf) self.tf = nil end
		self.tf = TextField.new(self.ttf, self.text, self.text)
		self.tf:setText(self.text)
		self.tf:setAnchorPoint(0.5, 0.5)
		self.tf:setScale(self.textscalexup, self.textscaleyup)
		self.tf:setTextColor(self.textcolorup)
		self.tf:setAlpha(self.textalphaup)
		textwidth, textheight = self.tf:getWidth(), self.tf:getHeight()
	end
	-- first add pixel
	if self.pixelcolorup then
		if self.isautoscale and self.text then
			self.pixel = Pixel.new(
				self.pixelcolorup, self.pixelalphaup,
				textwidth + self.pixelpaddingx,
				textheight + self.pixelpaddingy)
		else
			self.pixel = Pixel.new(
				self.pixelcolorup, self.pixelalphaup,
				self.pixelpaddingx,
				self.pixelpaddingy)
		end
		self.pixel:setAnchorPoint(0.5, 0.5)
		self.pixel:setScale(self.pixelscalexup, self.pixelscaleyup)
		self.sprite:addChild(self.pixel)
	end
	-- then images
	if self.imguppath then
		local texup = Texture.new(self.imguppath)
		if self.isautoscale and self.text then
			self.bmpup = Pixel.new(texup,
				textwidth + (self.imgpaddingx),
				textheight + (self.imgpaddingy))
		else
			self.bmpup = Pixel.new(texup, self.imgpaddingx, self.imgpaddingy)
		end
		bmps[self.bmpup] = 1
	end
	if self.imgdownpath then
		local texdown = Texture.new(self.imgdownpath)
		if self.isautoscale and self.text then
			self.bmpdown = Pixel.new(texdown,
				textwidth + (self.imgpaddingx),
				textheight + (self.imgpaddingy))
		else
			self.bmpdown = Pixel.new(texdown, self.imgpaddingx, self.imgpaddingy)
		end
		bmps[self.bmpdown] = 2
	end
	if self.imgdisabledpath then
		local texdisabled = Texture.new(self.imgdisabledpath)
		if self.isautoscale and self.text then
			self.bmpdisabled = Pixel.new(texdisabled,
				textwidth + (self.imgpaddingx),
				textheight + (self.imgpaddingy))
		else
			self.bmpdisabled = Pixel.new(texdisabled, self.imgpaddingx, self.imgpaddingy)
		end
		bmps[self.bmpdisabled] = 3
	end
	-- image batch
	for k, _ in pairs(bmps) do
		k:setAnchorPoint(0.5, 0.5)
		k:setAlpha(self.imgalphaup)
		local split = 9 -- magik number
		k:setNinePatch(math.floor(k:getWidth()/split), math.floor(k:getWidth()/split),
			math.floor(k:getHeight()/split), math.floor(k:getHeight()/split))
		self.sprite:addChild(k)
	end
	-- finally add tf on top of all
	if self.tf then self.sprite:addChild(self.tf) end
	-- and the tooltip text
	if self.tooltiptext then
		self.tooltiptf = TextField.new(self.tooltipttf, self.tooltiptext, self.tooltiptext)
		self.tooltiptf:setScale(self.tooltiptextscale)
		self.tooltiptf:setTextColor(self.tooltiptextcolor)
		self.tooltiptf:setVisible(false)
		self:addChild(self.tooltiptf)
	end
end

function ButtonMonster:setText(xtext) self.text = xtext self:setButton() end

-- isdisabled
function ButtonMonster:setDisabled(xdisabled)
	if self.isdisabled == xdisabled then return end
	self.isdisabled = xdisabled
	self:updateVisualState()
end
function ButtonMonster:isDisabled() return self.isdisabled end

-- VISUAL STATE
function ButtonMonster:updateVisualState()
	if self.btns then -- navigatable buttons
		for k, v in ipairs(self.btns) do
			if v.isdisabled then -- button is isdisabled
				if v.imguppath ~= nil then v.bmpup:setVisible(false) end
				if v.imgdownpath ~= nil then v.bmpdown:setVisible(false) end
				if v.imgdisabledpath ~= nil then v.bmpdisabled:setVisible(true) end
				if v.pixelcolordisabled ~= nil then v.pixel:setColor(v.pixelcolordisabled) end
				if v.text ~= nil then v.tf:setTextColor(v.textcolordisabled) end
			elseif v.selector == v:getParent().selector then -- button is focused (down state)
				if v.hover then -- can hover option
					if v.btnscalexdown ~= nil then v:setScale(v.btnscalexdown, v.btnscaleydown) end
					if v.imguppath ~= nil then v.bmpup:setVisible(false) end
					if v.imgdownpath ~= nil then v.bmpdown:setVisible(true) end
					if v.imgdisabledpath ~= nil then v.bmpdisabled:setVisible(false) end
					if v.pixelcolordown ~= nil then v.pixel:setColor(v.pixelcolordown, v.pixelalphadown) v.pixel:setScale(v.pixelscalexdown, v.pixelscaleydown) end
					if v.text ~= nil then v.tf:setTextColor(v.textcolordown) v.tf:setScale(v.textscalexdown, v.textscaleydown) end
				end
			else -- button is not focused (up state)
				if v.btnscalexup ~= nil then v:setScale(v.btnscalexup, v.btnscaleyup) end
				if v.imguppath ~= nil then v.bmpup:setVisible(true) end
				if v.imgdownpath ~= nil then v.bmpdown:setVisible(false) end
				if v.imgdisabledpath ~= nil then v.bmpdisabled:setVisible(false) end
				if v.pixelcolorup ~= nil then v.pixel:setColor(v.pixelcolorup, v.pixelalphaup) v.pixel:setScale(v.pixelscalexup, v.pixelscaleyup) end
				if v.text ~= nil then v.tf:setTextColor(v.textcolorup) v.tf:setScale(v.textscalexup, v.textscaleyup) end
			end
			-- tool tip
--			if v.tooltiptext and not v.isdisabled then -- OPTION 1: hides tooltip when button is disabled
			if v.tooltiptext then -- OPTION 2: shows tooltip even if button is disabled
				if v.selector == v:getParent().selector then -- button is focused
					if v.isdisabled then v.tooltiptf:setText("("..v.tooltiptext..")")
					else v.tooltiptf:setText(v.tooltiptext)
					end v.tooltiptf:setVisible(true)
				else -- button is not focused
					v.tooltiptf:setVisible(false)
				end
				if v.iskeyboard then -- reposition the tooltip when keyboard navigating
					v.tooltiptf:setPosition(
						v:getParent():getX() + v.tooltipoffsetx,
						v:getParent():getY() + v.tooltipoffsety
					)
				end
			end
		end
	else -- non navigatable buttons
		if self.isdisabled then -- button is disabled
			if self.imguppath ~= nil then self.bmpup:setVisible(false) end
			if self.imgdownpath ~= nil then self.bmpdown:setVisible(false) end
			if self.imgdisabledpath ~= nil then self.bmpdisabled:setVisible(true) end
			if self.pixelcolordisabled ~= nil then self.pixel:setColor(self.pixelcolordisabled) end
			if self.text ~= nil then self.tf:setTextColor(self.textcolordisabled) end
		elseif self.ishovered then -- button is focused (down state)
			if self.btnscalexdown ~= nil then self:setScale(self.btnscalexdown, self.btnscaleydown) end
			if self.imguppath ~= nil then self.bmpup:setVisible(false) end
			if self.imgdownpath ~= nil then self.bmpdown:setVisible(true) end
			if self.imgdisabledpath ~= nil then self.bmpdisabled:setVisible(false) end
			if self.pixelcolordown ~= nil then self.pixel:setColor(self.pixelcolordown, self.pixelalphadown) self.pixel:setScale(self.pixelscalexdown, self.pixelscaleydown) end
			if self.text ~= nil then self.tf:setTextColor(self.textcolordown) self.tf:setScale(self.textscalexdown, self.textscaleydown) end
		else -- button is not focused (up state)
			if self.btnscalexup ~= nil then self:setScale(self.btnscalexup, self.btnscaleyup) end
			if self.imguppath ~= nil then self.bmpup:setVisible(true) end
			if self.imgdownpath ~= nil then self.bmpdown:setVisible(false) end
			if self.imgdisabledpath ~= nil then self.bmpdisabled:setVisible(false) end
			if self.pixelcolorup ~= nil then self.pixel:setColor(self.pixelcolorup, self.pixelalphaup) self.pixel:setScale(self.pixelscalexup, self.pixelscaleyup) end
			if self.text ~= nil then self.tf:setTextColor(self.textcolorup) self.tf:setScale(self.textscalexup, self.textscaleyup) end
		end

--		if self.tooltiptext and not self.isdisabled then -- OPTION 1: hides tooltip when button is disabled
		if self.tooltiptext then -- OPTION 2: shows tooltip even if button is disabled
			if self.ishovered then -- button is focused
				if self.isdisabled then self.tooltiptf:setText("("..self.tooltiptext..")")
				else self.tooltiptf:setText(self.tooltiptext)
				end self.tooltiptf:setVisible(true)
			else -- button is not focused
				self.tooltiptf:setVisible(false)
			end
			if self.iskeyboard then -- reposition the tooltip when keyboard navigating
				self.tooltiptf:setPosition(
					self:getParent():getX() + self.tooltipoffsetx,
					self:getParent():getY() + self.tooltipoffsety
				)
			end
		end
	end
end

-- MOUSE LISTENERS
function ButtonMonster:onMouseDown(e)
	if self.sprite:hitTestPoint(e.x, e.y, true) then -- XXX use this code when hitTestPoint bug is fixed!
--	if self.sprite:hitTestPoint(e.x, e.y) and self:getParent():isVisible() then -- XXX
		self.isclicked = true
		if self.selector then self:getParent().selector = self.selector end -- update the parent id selector
--		if self.fun then self.fun(self:getParent()) end -- YOU CAN ADD THIS HERE
		e:stopPropagation()
	end
	self:updateVisualState()
end
function ButtonMonster:onMouseMove(e)
	if self.sprite:hitTestPoint(e.x, e.y, true) then -- XXX use this code when hitTestPoint bug is fixed!
--	if self.sprite:hitTestPoint(e.x, e.y) and self:getParent():isVisible() then -- XXX
		self.isclicked = true
		if self.selector then self:getParent().selector = self.selector end -- update the parent id selector
		-- this bit prevents sound or function to repeat itself
		self.onenter = not self.onenter
		if not self.onenter then self.ismoving = true end
		if not self.ismoving then
			if self.channel ~= nil and self.sound ~= nil then self:selectionSfx() end
--			if self.fun then self.fun(self:getParent()) end -- OR HERE?
		end
		e:stopPropagation()
	else
		self.isclicked = false
		self.onenter = false
		self.ismoving = false
	end
	self:updateVisualState()
end
function ButtonMonster:onMouseUp(e)
	if self.isclicked then
		self.isclicked = false
		if not self.isdisabled then self:dispatchEvent(Event.new("clicked")) end
		if self.fun then self.fun(self:getParent()) end -- OR EVEN HERE?
		e:stopPropagation()
	end
end
function ButtonMonster:onMouseHover(e)
--	if self.sprite:hitTestPoint(e.x, e.y, true) then -- XXX use this code when hitTestPoint bug is fixed!
	if self.sprite:hitTestPoint(e.x, e.y) and self.sprite:isVisible() then -- XXX
		if self.tooltiptext then
			self.tooltiptf:setPosition(
				self.sprite:globalToLocal(e.x + self.tooltipoffsetx, e.y + self.tooltipoffsety)
			)
		end
		self.ishovered = true
		if self.selector then self:getParent().selector = self.selector end -- update parent id selector
		-- this bit prevents sound or function to repeat itself
		self.onenter = not self.onenter
		if not self.onenter then self.ismoving = true end
		if not self.ismoving then
			if self.channel ~= nil and self.sound ~= nil then self:selectionSfx() end
--			if self.fun then self.fun(self:getParent()) end -- HERE COULD ALSO BE USEFUL?
		end
--		self:updateVisualState() -- here will save some frames but won't update everything!
		e:stopPropagation()
	else
		self.ishovered = false
		self.iskeyboard = false
		self.onenter = false
		self.ismoving = false
	end
	self:updateVisualState() -- here will use more frames but will update everything! you decide :-)
end

-- audio
function ButtonMonster:selectionSfx()
	-- mouse ui buttons sound fx
	if not self.channel:isPlaying() then self.channel = self.sound:play() self.channel:setVolume(self.volume) end
end
function ButtonMonster:setVolume(xvolume) self.volume = xvolume end
