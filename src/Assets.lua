--------------------------------------------------------------------------------
-- Assets Rig
--------------------------------------------------------------------------------

Assets = {}

function Assets.new()
  local self = setmetatable({}, { __index = Assets })

  self.players = {}

  for iPlayer = 1, 2 do
    local character_texture = MOAITexture.new()
    character_texture:load(settings.entities.players[iPlayer].texture_path)

    self.players[iPlayer] = {
      character_texture = character_texture,
    }
  end

  self.fader = MOAIGfxQuad2D.new()
  self.fader:setTexture(settings.misc.pixel_texture_path)
  self.fader:setRect(-Game.kScreenWidth / 2, -Game.kScreenHeight / 2,
                     Game.kScreenWidth / 2, Game.kScreenHeight / 2)

  return self
end
