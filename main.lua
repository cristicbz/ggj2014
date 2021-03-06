-------------------------------------------------------------------------------
-- Imports
-------------------------------------------------------------------------------
dofile("src/ParticleHelper.lua" )
dofile("src/Settings.lua")
dofile("src/Game.lua")
dofile("src/Assets.lua")
dofile("src/GameState.lua")
dofile("src/Util.lua")
dofile("src/EventSource.lua")
dofile("src/Entity.lua")
dofile("src/ActiveSet.lua")
dofile("src/PhysicalEntity.lua")
dofile("src/DynamicEntity.lua")
dofile("src/Effect.lua")
dofile("src/Level.lua")
dofile("src/Player.lua")
dofile("src/ControlManager.lua")
dofile("src/LeadingEffect.lua")
dofile("src/Masker.lua")
dofile("src/SoundFamily.lua")
dofile("src/ScoreBar.lua")
dofile("src/Speeder.lua")

-------------------------------------------------------------------------------
-- Entry point
-------------------------------------------------------------------------------
game = Game.new()
game:run()

