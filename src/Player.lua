Player = setmetatable({}, {__index = DynamicEntity})

function Player.new(cell, assets, opts)
  local self = setmetatable(
      DynamicEntity.new(cell), {__index = Player})

  local radius = opts.size
  local body, fixture = self:addCircleFixture_(
      radius * opts.collision_scale, 
      opts.mass, opts.restitution, opts.friction)

  local angle = math.random() * math.pi * 2.0
  body:setLinearVelocity(math.cos(angle) * opts.speed, math.sin(angle) * opts.speed)

  local deck = MOAIGfxQuad2D.new()
  deck:setTexture(assets.character_texture)
  deck:setRect(-radius, -radius, radius, radius)

  local prop = MOAIProp2D.new()
  prop:setDeck(deck)
  prop:setPriority(settings.priorities.players)
  prop:setParent(body)

  local layer = cell.fgLayer_
  layer:insertProp(prop)

  self.ctrl_ = Controller.new(self, opts.bindings)
  self.prop_ = prop
  self.layer_ = layer
  self.body_ = body
  self.speed_ = opts.speed
  self.rotateBy_ = opts.rotate_by

  return self
end

function Player:destroy()
  self.ctrl_:stop()
  self.layer_:removeProp(self.prop_)
  DynamicEntity.destroy(self)
end

function Player:goLeft()
  self:rotateBy(-self.rotateBy_)
end

function Player:goRight()
  self:rotateBy(self.rotateBy_)
end

function Player:rotateBy(angle)
  local vx, vy = self.body_:getLinearVelocity()
  local angle = math.atan2(vy, vx) + angle
  vx, vy = math.cos(angle) * self.speed_, math.sin(angle) * self.speed_
  self.body_:setLinearVelocity(vx, vy)
end

--------------------------------------------------------------------------------
-- Controller                                                                 --
--------------------------------------------------------------------------------
Controller = {}

function Controller.new(player, opts)
  local self = setmetatable({}, {__index = Controller})

  self.player_ = player
  self.leftKey_ = opts.left
  self.rightKey_ = opts.right

  self.callback_ = function(key, down)
    local keyboard = MOAIInputMgr.device.keyboard
    local left, right = self.leftKey_, self.rightKey_
    local player = self.player_
    if down then
      if key == left then player:goLeft() end
      if key == right then player:goRight() end
    end
  end

  Keyboard:addListener(self.callback_)
end
