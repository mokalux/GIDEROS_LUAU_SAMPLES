Menu = Core.class(Sprite)

function Menu:init()
	-- BG
	application:setBackgroundColor(0x1234AA)
	-- a button
	local btn01 = ButtonMonster.new({
		pixelcolorup=0x00ff00, pixelcolordown=0x0000ff,
		text="let's go!", textscalexup=6,
	}, 1)
	-- position
	btn01:setPosition(myappwidth/2, 3*myappheight/10)
	-- order
	self:addChild(btn01)
	-- btns listeners
	btn01:addEventListener("clicked", function() self:gotoScene("levelX") end)
	-- listeners
	self:addEventListener("enterBegin", self.onTransitionInBegin, self)
	self:addEventListener("enterEnd", self.onTransitionInEnd, self)
	self:addEventListener("exitBegin", self.onTransitionOutBegin, self)
	self:addEventListener("exitEnd", self.onTransitionOutEnd, self)
end

-- GAME LOOP
function Menu:onEnterFrame(e)
end

-- EVENT LISTENERS
function Menu:onTransitionInBegin() self:addEventListener(Event.ENTER_FRAME, self.onEnterFrame, self) end
function Menu:onTransitionInEnd() self:myKeysPressed() end
function Menu:onTransitionOutBegin() self:removeEventListener(Event.ENTER_FRAME, self.onEnterFrame, self) end
function Menu:onTransitionOutEnd() end

-- KEYS HANDLER
function Menu:myKeysPressed()
	self:addEventListener(Event.KEY_DOWN, function(e)
		-- for mobiles and desktops
		if e.keyCode == KeyCode.BACK or e.keyCode == KeyCode.ESC then
--			scenemanager:changeScene("menu", 1, transitions[2], easing.outBack)
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
function Menu:gotoScene(xscene)
	scenemanager:changeScene( xscene, 1,
		transitions[math.random(1, #transitions)], easings[math.random(1, #easings)] )
end
