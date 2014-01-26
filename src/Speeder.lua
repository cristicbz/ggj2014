Speeder = setmetatable({}, {__index = PhysicalEntity})

function Speeder.new(cell, def, asset)
  local self = setmetatable(PhysicalEntity.new(cell), {__index = Speeder})

  local deck = MOAIGfxQuadDeck2D.new()
  deck:reserve(1)
  deck:setTexture(asset)
  deck:setQuad(1, unpack(def.poly))
  deck:setUVRect(1, 0, 1, 1, 0)

  local body = self:createBody_(MOAIBox2DBody.STATIC)
  local fixture = body:addChain(def.poly, true)
  fixture:setSensor(true)
  fixture:setCollisionHandler(
    function(phase, a, b)
      local playerBody = b:getBody()
      local player = cell:lookupBody(b:getBody())
      if player == nil or player.score_ == nil then return end
      playerBody:applyLinearImpulse(
          self.dx_, self.dy_, playerBody:getWorldCenter())
      SpeederEffect.attach(player)
    end, MOAIBox2DArbiter.BEGIN)

  local prop = MOAIProp2D.new()
  prop:setDeck(deck)
  prop:setIndex(1)

  local layer = cell.fgLayer_
  layer:insertProp(prop)

  local v = def.poly
  local dx, dy = v[3] - v[1], v[4] - v[2]
  local norm = settings.entities.speeder.strength / math.sqrt(dx * dx + dy * dy)
  dx, dy = dx * norm, dy * norm

  self.dx_, self.dy_ = dx, dy
  self.layer_, self.prop_ = layer, prop
end

function Speeder:destroy()
  self.layer_:removeProp(self.prop_)
  PhysicalEntity.destroy(self)
end

SpeederEffect = setmetatable({}, {__index = Effect})

function SpeederEffect.attach(entity)
  return Effect.attach(SpeederEffect, entity)
end

function SpeederEffect:onAttach()
  self.savedDrag = self:getEntity().dragCoefficient
  self:getEntity().dragCoefficient = 0
  self:onRefresh()
end

function SpeederEffect:onRefresh()
  self:setTimeLimit(.2)
end

function SpeederEffect:onDetach()
  self:getEntity().dragCoefficient = self.savedDrag
end

