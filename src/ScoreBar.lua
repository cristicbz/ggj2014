ScoreBar = {}

function ScoreBar.new(layer, opts)
  local self = setmetatable({}, {__index = ScoreBar})

  self.x_ = opts.x * Game.kPixelToWorld - Game.kScreenWidth / 2
  self.y_ = Game.kScreenHeight / 2 - opts.y * Game.kPixelToWorld
  self.w_ = opts.width * Game.kPixelToWorld
  self.h_ = opts.height * Game.kPixelToWorld

  self.decks_ = {MOAIGfxQuad2D.new(), MOAIGfxQuad2D.new()}
  self.props_ = {MOAIProp2D.new(), MOAIProp2D.new()}

  for iPlayer = 1,2 do
    self.decks_[iPlayer]:setTexture(opts.images[iPlayer])
    self.props_[iPlayer]:setDeck(self.decks_[iPlayer])
    self.props_[iPlayer]:setPriority(settings.priorities.hud)
    layer:insertProp(self.props_[iPlayer])
  end

  self.layer_ = layer
  self.targetRatio_ = 0.5
  self.pid_ = TargetFollower.new(0.5, 0.03, 0.6)
  self.coroutine_ = MOAICoroutine.new()
  self.coroutine_:run(
      function()
        while true do
          self:setRectsAt_(self.pid_:follow(self.targetRatio_, 0.33))
          coroutine.yield()
        end
      end)

  self:setRectsAt_(0.5)

  return self
end

function ScoreBar:setRectsAt_(ratio)
  local x, y, w, h = self.x_, self.y_, self.w_, self.h_ 
  local d1, d2 = self.decks_[1], self.decks_[2]
  d1:setRect(x, y + h, x + w * ratio, y)
  d1:setUVRect(0, 0, ratio, 1)
  d2:setRect(x + w * ratio, y + h, x + w, y)
  d2:setUVRect(ratio, 0, 1, 1)
end

function ScoreBar:update(score1, score2)
  if score1 == 0 and score2 == 0 then score1, score2 = 1, 1 end
  self.targetRatio_ = score1 / (score1 + score2)
end

function ScoreBar:destroy()

end
