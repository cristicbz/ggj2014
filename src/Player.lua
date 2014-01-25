Player = setmetatable({}, {__index = DynamicEntity})

function Player.new(cell, assets, opts)
  local self = setmetatable(
      DynamicEntity.new(cell), {__index = Player})

  local radius = opts.size
  local body, fixture = self:addCircleFixture_(
      radius * opts.collision_scale, 
      opts.mass, opts.restitution, opts.friction)
  body:setAngularDamping(0.8)

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
  self.moveStrength_ = opts.move_strength
  self.maskDeck_ = assets.mask_quads[1]
  self.color_ = opts.color

  return self
end

function Player:getColor()
  return self.color_
end

function Player:destroy()
  self.ctrl_:stop()
  self.layer_:removeProp(self.prop_)
  DynamicEntity.destroy(self)
end

function Player:goDir(toX, toY)
  self.body_:applyForce(toX * self.moveStrength_, toY * self.moveStrength_,
                        self.body_:getWorldCenter())
end

function Player:moveTo(x, y)
  self.body_:setTransform(x, y, self.body_:getAngle())
end

function Player:getMaskDeck()
  return self.maskDeck_
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
  self.upKey_ = opts.up
  self.downKey_ = opts.down
  self.leftKey_ = opts.left
  self.rightKey_ = opts.right
  self.dirX_, self.dirY_ = 0, 0
  self.destroyed_ = false
  self.coroutine_ = MOAICoroutine.new()
  self.coroutine_:run(
    function()
      while not self.destroyed_ do
        local x, y = self.dirX_, self.dirY_
        if x ~= 0 or y ~= 0 then
          player:goDir(x, y)
        end
        coroutine.yield()
      end
    end)

  self.callback_ = function(key, pressed)
    local keyboard = MOAIInputMgr.device.keyboard
    local up, down, left, right = self.upKey_, self.downKey_, self.leftKey_, self.rightKey_
    local player = self.player_
    if pressed then
      if key == up then self.dirY_ = self.dirY_ + 1
      elseif key == down then self.dirY_ = self.dirY_ - 1 end

      if key == left then self.dirX_ = self.dirX_ - 1
      elseif key == right then self.dirX_ = self.dirX_ + 1 end
    else
      if key == up then self.dirY_ = self.dirY_ - 1
      elseif key == down then self.dirY_ = self.dirY_ + 1 end

      if key == left then self.dirX_ = self.dirX_ + 1
      elseif key == right then self.dirX_ = self.dirX_ - 1 end
    end
  end

  Keyboard:addListener(self.callback_)
end
