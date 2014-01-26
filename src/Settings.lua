settings = {
  world = {
    small_step_size = 1 / 120.0,
    screen_width = 100,
    screen_pixel_width = 1280,
    screen_pixel_height = 720,
    global_drag = 0.145 
  },

  debug = {
    show_lines = false,
    no_sound = true,
    skip_intro = true,
    render_walls = false,
  },

  priorities = {
    splotches = 5,
    players = 10,
    hud = 15,
    fader = 100,
    text = 105,
  },

  collision_masks = {},

  effects = {
    new_game_fade_color = {0, 0, 0, 1},
    new_game_fade_time = 1,
  },

  music_tracks = {
    {path = 'assets/sfx/Music/BattleTrack01.ogg', volume = 0.4},
    {path = 'assets/sfx/Music/TranceTrack01.ogg', volume = 0.4},
    --{path = 'assets/sfx/Music/TaikoTrack01.ogg', volume = 0.8},
  },

  intro = {
    sound = { path ='assets/sfx/Transitions/ThreeTwoOneGo01.ogg', volume = 1.0 },
    phases = {
      { image = 'assets/gfx/3.png',  at = 0.20, width = 238, height = 259},
      { image = 'assets/gfx/2.png',  at = 1.16, width = 229, height = 259},
      { image = 'assets/gfx/1.png',  at = 2.23, width = 143, height = 259},
      { image = 'assets/gfx/go.png', at = 3.13, width = 514, height = 259},
      { image = nil,                 at = 4.13, width = 0, height = 0},
    },
  },

  endofround = {
    sound = { path = 'assets/sfx/Transitions/WeHaveAWinner02.ogg', volume = 1.0},
  },

  entities = {
    speeder = {
      texture_path = 'assets/gfx/speed.png',
      strength = 20,
    },
    players = {
      {
        name = 'kiki',
        texture_path = 'assets/gfx/kiki.png',
        splotch_texture_path = 'assets/gfx/CRYSTAL.png',
        win_screen = {
          path = 'assets/gfx/kiki_wins.png', width = 979, height = 242},
        color = {1.0, 0.5, 0.0, 1.0},
        size = 2.85,
        collision_scale = 1.0,
        mass = 1.2,
        restitution = 3,
        friction = 0.05,
        move_strength = 300.0,
        mask_opacity = .8,
        bindings = {
          up = string.byte('w'),
          down = string.byte('s'),
          left = string.byte('a'),
          right = string.byte('d'),
        },
        masks = {
          {
            texture_path = 'assets/gfx/Masks/crystal 100.png',
            radius = 1.37 * 3,
          }
        },
        hit_sounds = {
          {path = 'assets/sfx/Foley/Kiki/Hits/KikiHit01.ogg', volume = 1},
          {path = 'assets/sfx/Foley/Kiki/Hits/KikiHit02.ogg', volume = 1},
          {path = 'assets/sfx/Foley/Kiki/Hits/KikiHit03.ogg', volume = 1},
          {path = 'assets/sfx/Foley/Kiki/Hits/KikiHit04.ogg', volume = 1},
          {path = 'assets/sfx/Foley/Kiki/Hits/KikiHit05.ogg', volume = 1},
        },
        pulse_sounds = {
          {path = 'assets/sfx/Foley/Kiki/Wall/KikiWall01.ogg', volume = 1},
          {path = 'assets/sfx/Foley/Kiki/Wall/KikiWall02.ogg', volume = 1},
          {path = 'assets/sfx/Foley/Kiki/Wall/KikiWall03.ogg', volume = 1},
          {path = 'assets/sfx/Foley/Kiki/Wall/KikiWall04.ogg', volume = 1},
        }
      },
      {
        name = 'bouba',
        texture_path = 'assets/gfx/bouba.png',
        splotch_texture_path = 'assets/gfx/GOOP.png',
        win_screen = {
          path = 'assets/gfx/bouba_wins.png', width = 996, height = 241},
        color = {0.2, 0.8, 0.2, 1.0},
        size = 2.85,
        collision_scale = 1.0,
        mass = 1.2,
        restitution = 3,
        friction = 0.05,
        move_strength = 300.0,
        mask_opacity = .8,
        bindings = {
          up = string.byte('i'),
          down = string.byte('k'),
          left = string.byte('j'),
          right = string.byte('l'),
        },
        masks = {
          {
            texture_path = 'assets/gfx/Masks/goop 100.png',
            radius = 1.67 * 3
          }
        },
        hit_sounds = {
          {path = 'assets/sfx/Foley/Boboa/Hits/BoboaHits01.ogg', volume = 1},
          {path = 'assets/sfx/Foley/Boboa/Hits/BoboaHits02.ogg', volume = 1},
          {path = 'assets/sfx/Foley/Boboa/Hits/BoboaHits03.ogg', volume = 1},
        },
        pulse_sounds = {
          {path = 'assets/sfx/Foley/Boboa/Wall/BoboaWall01.ogg', volume = 1},
        },
      },
    },
    score_bar = {
      width = 452, height = 31,
      x = 410, y = 110,  -- top left
      images = {
        'assets/gfx/progress_orange.png', 'assets/gfx/progress_teal.png',
      },
    },
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

  levels = {
    {
      definition_path = "assets/levels/level1.lua",
      background_path = "assets/gfx/level1.png",
    },
    {
      definition_path = "assets/levels/level2.lua",
      background_path = "assets/gfx/level2.png",
    },
    {
      definition_path = "assets/levels/level3.lua",
      background_path = "assets/gfx/level3.png",
    },
  },
}
