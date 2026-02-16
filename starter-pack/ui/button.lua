local MOUSE_BTN_LEFT = hash("mouse_btn_left")
local TOUCH_MULTI = hash("touch_multi")
local ACTIVE = hash("active")
local HOVER = hash("hover")
local NORMAL = hash("normal")
local PRESSED = hash("pressed")
local RELEASED = hash("released")

local M = {}

function M.static_input(id, action_id, action, handler)
	local node = gui.get_node(id .. "/button")
	if gui.pick_node(node, action.x, action.y) then
		if action_id == hash("mouse_btn_left") then
			if action.pressed then
				handler(PRESSED, ACTIVE)
			elseif action.released then
				handler(RELEASED, NORMAL)
			end
		end
	end
end

function M:_set_texture(button, checked, unchecked)
	local node = gui.get_node(self.id .. "/button")
	if self.is_checkbox then
		if self.is_checked then
			if checked then
				gui.play_flipbook(node, checked)
			end
		else
			if unchecked then
				gui.play_flipbook(node, unchecked)
			end
		end
	else
		if button then
			gui.play_flipbook(node, button)
		end
	end
end

function M:input(action_id, action, handler)
	if not self.is_enabled or not action.touch and (not action.x or not action.y) then return end
	if action_id == TOUCH_MULTI then
		self:_multi_touch_input(action_id, action, handler)
	else
		if not self.touch_id then
			self:_single_touch_input(action_id, action, handler)
		end
	end
end

function M:_handle_press(handler, pressed, released)
	if pressed and not self.active then
		self:_set_texture(self.textures.active, self.textures.checked_active, self.textures.unchecked_active)
		self.active = true
		handler(PRESSED, ACTIVE)
	elseif released then
		if self.active then
			self.active = false
			self.pressed = false
			self:_set_texture(self.textures.hover, self.textures.checked_hover, self.textures.unchecked_hover)
			handler(RELEASED, HOVER)
		end
	end
end

function M:_handle_unpick(handler)
	if not self.hover then return end
	self.hover = false
	self:_set_texture(self.textures.normal, self.textures.checked, self.textures.unchecked)
	if self.active then
	    self.active = false
		handler(RELEASED, NORMAL)
	else
		handler(nil, NORMAL)
	end
end

function M:_multi_touch_input(action_id, action, handler)
	local node = gui.get_node(self.id .. "/button")
	for touch_id, touch in ipairs(action.touch) do
		if gui.pick_node(node, touch.x, touch.y) then
			self.hover = true
			if touch.pressed then
				self.touch_id = touch_id
			elseif touch.released then
				self.touch_id = nil
			end
			self:_handle_press(handler, touch.pressed, touch.released)
		else
			if self.touch_id == touch_id then
				self.touch_id = nil
				self:_handle_unpick(handler)
			end
		end
	end
end

function M:_single_touch_input(action_id, action, handler)
	local node = gui.get_node(self.id .. "/button")
	if gui.pick_node(node, action.x, action.y) then
		if action_id == MOUSE_BTN_LEFT then
			self.hover = true
			self:_handle_press(handler, action.pressed, action.released)
		else
			if not self.hover then
				self.hover = true
				self:_set_texture(self.textures.hover, self.textures.checked_hover, self.textures.unchecked_hover)
				handler(nil, HOVER)
			end
		end
	else
		self:_handle_unpick(handler)
	end
end

function M:set_textures(
	normal,
	hover,
	active,
	checked,
	checked_hover,
	checked_active,
	unchecked,
	unchecked_hover,
	unchecked_active,
	disabled,
	checked_disabled,
	unchecked_disabled
)
	self.textures.normal = normal
	self.textures.hover = hover
	self.textures.active = active
	self.textures.checked = checked
	self.textures.checked_hover = checked_hover
	self.textures.checked_active = checked_active
	self.textures.unchecked = unchecked
	self.textures.unchecked_hover = unchecked_hover
	self.textures.unchecked_active = unchecked_active
	self.textures.disabled = disabled
	self.textures.checked_disabled = checked_disabled
	self.textures.unchecked_disabled = unchecked_disabled
end

function M:toggle()
	if not self.is_checkbox then return end
	self.is_checked = not self.is_checked
	self:update()
end

function M:set_is_checked(is_checked)
	self.is_checked = is_checked
	self:update()
end

function M:set_enabled(is_enabled)
	self.is_enabled = is_enabled
	self.hover = false
	self.active = false
	self.touch_id = nil
	self:update()
end

function M:update()
	if self.is_enabled then
		self:_set_texture(self.textures.normal, self.textures.checked, self.textures.unchecked)
	else
		self:_set_texture(self.textures.disabled, self.textures.checked_disabled, self.textures.unchecked_disabled)
	end
end

function M.new(id, is_enabled)
	local instance = {}
	instance.is_enabled = is_enabled
	instance.is_checkbox = false
	instance.is_checked = false
	instance.id = id
	instance.textures = {}
	instance.active = false
	instance.hover = false
	instance.touch_id = nil
	return setmetatable(instance, { __index = M })
end

return M
