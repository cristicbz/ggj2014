Masker = {}

function Masker.new(baseTexture, destLayer)
  local self = setmetatable({}, {__index = Masker})

  local viewport = MOAIViewport.new()
  viewport:setSize(Game.kScreenPixelWidth, Game.kScreenPixelHeight)
  viewport:setScale(Game.kScreenWidth, -Game.kScreenHeight)

  local maskLayer = MOAILayer2D.new()
  maskLayer:setViewport(viewport)

  local baseDeck = MOAIGfxQuad2D.new()
  baseDeck:setTexture(baseTexture)
  baseDeck:setRect(-Game.kScreenWidth / 2, -Game.kScreenHeight / 2,
                   Game.kScreenWidth / 2, Game.kScreenHeight / 2)

  local baseProp = MOAIProp2D.new()
  baseProp:setDeck(baseDeck)
  baseProp:setColor(1, 1, 1, 0)
  baseProp:setBlendMode(MOAIProp.GL_ONE, MOAIProp.GL_ONE)
  baseProp:setPriority(1)

  maskLayer:insertProp(baseProp)

  local framebuffer = MOAIFrameBufferTexture.new()
  framebuffer:init(Game.kScreenPixelWidth, Game.kScreenPixelHeight)
  framebuffer:setRenderTable({ maskLayer })
  framebuffer:setClearColor(0, 0, 0, 0)

  local destDeck = MOAIGfxQuad2D.new()
  destDeck:setTexture(framebuffer)
  destDeck:setRect(-Game.kScreenWidth / 2, -Game.kScreenHeight / 2,
                   Game.kScreenWidth / 2, Game.kScreenHeight / 2)

  local destProp = MOAIProp2D.new()
  destProp:setDeck(destDeck)
  destProp:setBlendMode(MOAIProp.GL_SRC_ALPHA, MOAIProp.GL_ONE)
  destProp:setPriority(settings.priorities.splotches)
  destLayer:insertProp(destProp)

  self.maskLayer_ = maskLayer
  self.framebuffer_ = framebuffer

  return self
end

function Masker:getFrameBuffer()
  return self.framebuffer_
end

function Masker:addMask(maskDeck, opacity, x, y, a)
  local maskProp = MOAIProp2D.new()
  maskProp:setDeck(maskDeck)
  maskProp:setBlendMode(MOAIProp.GL_ONE, MOAIProp.GL_ONE)
  maskProp:setColor(0, 0, 0, opacity)
  maskProp:setLoc(x, y)
  maskProp:setRot(a)
  maskProp:setPriority(2)

  self.maskLayer_:insertProp(maskProp)

  return maskProp
end

function Masker:removeMask(mask)
  self.maskLayer_:removeProp(mask)
end
