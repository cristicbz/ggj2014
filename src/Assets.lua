--------------------------------------------------------------------------------
-- Assets Rig
--------------------------------------------------------------------------------

Assets = {}

function Assets.new()
  local self = setmetatable({}, { __index = Assets })

  self.players = {}

  for iPlayer = 1, 2 do
    local player_opts = settings.entities.players[iPlayer]
    local character_texture = MOAITexture.new()
    character_texture:load(player_opts.texture_path)

    local mask_quads = {}
    for _, mask in pairs(player_opts.masks) do
      local mask_quad = MOAIGfxQuad2D.new()
      mask_quad:setTexture(mask.texture_path)
      mask_quad:setRect(-mask.radius, -mask.radius, mask.radius, mask.radius)
      table.insert(mask_quads, mask_quad)
    end

    self.players[iPlayer] = {
      character_texture = character_texture,
      mask_quads = mask_quads,
    }
  end

  self.fader = MOAIGfxQuad2D.new()
  self.fader:setTexture(settings.misc.pixel_texture_path)
  self.fader:setRect(-Game.kScreenWidth / 2, -Game.kScreenHeight / 2,
                     Game.kScreenWidth / 2, Game.kScreenHeight / 2)

  return self
end
