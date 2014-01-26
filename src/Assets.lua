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

    local splotch_texture = MOAITexture.new()
    splotch_texture:load(player_opts.splotch_texture_path)

    local win_screen = MOAIGfxQuad2D.new()
    local w2 = player_opts.win_screen.width / 2 * Game.kPixelToWorld
    local h2 = player_opts.win_screen.height / 2 * Game.kPixelToWorld
    win_screen:setTexture(player_opts.win_screen.path)
    win_screen:setRect(-w2, -h2, w2, h2)

    local hit_sounds = SoundFamily.new(player_opts.hit_sounds)
    local pulse_sounds = SoundFamily.new(player_opts.pulse_sounds)

    self.players[iPlayer] = {
      character_texture = character_texture,
      mask_quads = mask_quads,
      splotch_texture = splotch_texture,
      hit_sounds = hit_sounds,
      pulse_sounds = pulse_sounds,
      win_screen = win_screen,
    }
  end

  self.fader = MOAIGfxQuad2D.new()
  self.fader:setTexture(settings.misc.pixel_texture_path)
  self.fader:setRect(-Game.kScreenWidth / 2, -Game.kScreenHeight / 2,
                     Game.kScreenWidth / 2, Game.kScreenHeight / 2)

  self.intro_sound = MOAIUntzSound.new()
  self.intro_sound:load(settings.intro.sound.path)
  self.intro_sound:setVolume(settings.intro.sound.volume)

  self.endofround_sound = MOAIUntzSound.new()
  self.endofround_sound:load(settings.endofround.sound.path)
  self.endofround_sound:setVolume(settings.endofround.sound.volume)

  self.speeder = MOAITexture.new()
  self.speeder:load(settings.entities.speeder.texture_path)

  return self
end
