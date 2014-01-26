-------------------------------------------------------------------------------
-- Rig:     GameState
-- Extends: nothing
-------------------------------------------------------------------------------
GameState = {}

function GameState.new(assets, viewport)
  local self = setmetatable({}, { __index = GameState })

  self.assets_ = assets
  self.started_ = false

  -- Create Box2D world
  self.world_ = MOAIBox2DWorld.new()
  self.world_:setUnitsToMeters(1.0)

  -- Create foreground layer
  self.fgLayer_ = MOAILayer2D.new()
  self.fgLayer_:setViewport(viewport)
  self.fgLayer_:setBox2DWorld(self.world_)
  self.fgLayer_:showDebugLines(settings.debug.show_lines)

  -- Create background layer
  self.bgLayer_ = MOAILayer2D.new()
  self.bgLayer_:setViewport(viewport)

  -- Create Level
  self.level_ = Level.new(self.world_, self.bgLayer_, self.fgLayer_, assets)

  -- Push layers in correct order
  MOAISim.pushRenderPass(self.bgLayer_)
  MOAISim.pushRenderPass(self.fgLayer_)

  -- Initial update
  self.level_:loadByIndex(1)

  return self
end

function GameState:unpause()
  self.started_ = true
  self.level_:unpause()
end

function GameState:die()
  self.swimmer:destroy()
end

function GameState:run()
  self:unpause()
end

