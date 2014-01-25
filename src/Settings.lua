settings = {
  world = {
    small_step_size = 1 / 120.0,
    screen_width = 100,
    screen_pixel_width = 1280,
    screen_pixel_height = 720,
    gravity = -0.02,
    global_drag = 0.195,
  },

  debug = {
    show_lines = false,
    disable_lightmap = false,
    no_sound = true,
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
        texture_path = 'assets/telephone.png',
        size = 1.67 * 2,
        collision_scale = 1.0,
        mass = 0.5,
        restitution = 1.0,
        friction = 0.05,
        move_force = 5.0,
        recoil_strength = 0.16,
        rotate_by = 58.25 / 180.0 * math.pi,
        speed = 40.0,
        bindings = {
          left = string.byte('q'),
          right = string.byte('w'),
        }
      },
      {
        texture_path = 'assets/telephone.png',
        size = 1.67 * 2,
        collision_scale = 1.0,
        mass = 0.5,
        restitution = 1.0,
        friction = 0.05,
        move_force = 5.0,
        recoil_strength = 0.16,
        rotate_by = 58.25 / 180.0 * math.pi,
        speed = 40.0,
        bindings = {
          left = string.byte('o'),
          right = string.byte('p'),
        }
      },
    }
  },

  misc = {
    pixel_texture_path = 'assets/pixel.png',
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

  levels = { },
}
