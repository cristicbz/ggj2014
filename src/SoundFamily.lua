SoundFamily = {}

function SoundFamily.new(opts)
  local self = setmetatable({}, {__index = SoundFamily}) 
  
  self.index_ = 1
  self.sounds_ = {}
  for _, variation in pairs(opts) do
    print (variation.path)
    local sound = MOAIUntzSound.new()
    sound:load(variation.path)
    sound:setVolume(variation.volume)
    table.insert(self.sounds_, sound)
  end

  return self
end

function SoundFamily:playOne()
  self.sounds_[self.index_]:play()
  self.index_ = self.index_ % (#self.sounds_) + 1
end
