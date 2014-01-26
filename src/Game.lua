-- Game rig
-------------------------------------------------------------------------------
Game = {
  kPixelToWorld =
      settings.world.screen_width / settings.world.screen_pixel_width,
  kAspectRatio =
      settings.world.screen_pixel_height / settings.world.screen_pixel_width,
  kScreenPixelWidth = settings.world.screen_pixel_width,
  kScreenPixelHeight = settings.world.screen_pixel_height,
  kScreenWidth = settings.world.screen_width,
}

Game.kScreenHeight = settings.world.screen_pixel_height * Game.kPixelToWorld

if settings.debug.no_sound then
  MOAIUntzSystem = {
    initialize = function() end,
    setVolume = function() end,
  }

  MOAIUntzSound = {
    new = function()
      return {
        setVolume = function() end,
        seekVolume = function() end,
        load = function() end,
        play = function() end,
        stop = function() end,
      }
    end
  }
else
  MOAIUntzSystem.initialize()
  MOAIUntzSystem.setVolume(1.0)
end

function Game.new()
  local self = setmetatable({}, { __index = Game })

  MOAISim.setStep(Game.SMALL_STEP_SIZE)
  MOAISim.clearLoopFlags()
  MOAISim.setLoopFlags(MOAISim.LOOP_FLAGS_FIXED)
  MOAISim.setLoopFlags(MOAISim.SIM_LOOP_ALLOW_SPIN)

  MOAISim.openWindow(
      "Global Game Jam 2014",
      Game.kScreenPixelWidth, Game.kScreenPixelHeight)

  -- Create viewport
  self.viewport_ = MOAIViewport.new()
  self.viewport_:setScale(Game.kScreenWidth, 0)
  self.viewport_:setSize(Game.kScreenPixelWidth, Game.kScreenPixelHeight)

  -- Create assets
  self.assets_ = Assets.new()

  -- Create game state.
  self.state_ = GameState.new(self.assets_, self.viewport_)
 
  return self
end

function Game:run()
  self.state_:run()
end

