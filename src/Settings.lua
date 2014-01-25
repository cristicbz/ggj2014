settings = {
  world = {
    small_step_size = 1 / 120.0,
    screen_width = 100,
    screen_pixel_width = 1280,
    screen_pixel_height = 720,
    gravity = -0.02,
    global_drag = 0.195 
  },

  debug = {
    show_lines = false,
    disable_lightmap = false,
    no_sound = true,
    render_walls = true,
  },

  priorities = {
    players = 10,
    fader = 100,
  },

  collision_masks = {},

  effects = {
    new_game_fade_color = {0, 0, 0, 1},
    new_game_fade_time = 1,
  },

  entities = {
    players = {
      {
        name = 'kiki',
        texture_path = 'assets/gfx/kiki.png',
        color = {1.0, 0.5, 0.0, 1.0},
        size = 2.85,
        collision_scale = 1.0,
        mass = 1.2,
        restitution = 0.8,
        friction = 0.05,
        move_strength = 300.0,
        speed = 40.0,
        bindings = {
          up = string.byte('w'),
          down = string.byte('s'),
          left = string.byte('a'),
          right = string.byte('d'),
        },
        masks = {
          {
            texture_path = 'assets/gfx/Masks/crystal 100.png',
            radius = 1.67 * 3
          }
        },
      },
      {
        name = 'bouba',
        texture_path = 'assets/gfx/bouba.png',
        color = {0.2, 0.8, 0.2, 1.0},
        size = 2.85,
        collision_scale = 1.0,
        mass = 1.2,
        restitution = 0.8,
        friction = 0.05,
        move_strength = 300.0,
        speed = 40.0,
        bindings = {
          up = string.byte('i'),
          down = string.byte('k'),
          left = string.byte('j'),
          right = string.byte('l'),
        },
        masks = {
          {
            texture_path = 'assets/gfx/Masks/goop 100.png',
            radius = 1.67 * 3,
          }
        },
      },
    }
  },

  misc = {
    pixel_texture_path = 'assets/gfx/pixel.png',
  },

  sounds = {
    music_path = "assets/track1.ogg",
    music_volume = 1.0,

    throw_path  = "assets/throw.ogg",
    throw_volume = 0.5,

    kill_path  = "assets/death.ogg",
    kill_volume = 0.9,

    breathe_path  = "assets/breathe.ogg",
    breathe_volume = 0.17,
  },

  effects = {
  },

  levels = {
    {
      definition_path = "assets/levels/level1.lua",
      background_path = "assets/gfx/ARENA.png",
    },
  },
}
