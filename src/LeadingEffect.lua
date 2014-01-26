LeadingEffect = setmetatable({}, {__index = Effect})

function LeadingEffect.attach(entity)
  return Effect.attach(LeadingEffect, entity)
end

function LeadingEffect:onAttach()
  self.removing_ = true
  self:onRefresh()
end

function LeadingEffect:onRefresh()
  if self.removing_ then
    if self.action_ then self.action_:stop() end
    self.action_ = self:getEntity().prop_:seekScl(1.5, 1.5, 0.6)
    self.removing_ = false
  end
end

function LeadingEffect:remove()
  if not self.removing_ then
    if self.action_ then self.action_:stop() end
    self.action_ = self:getEntity().prop_:seekScl(1, 1, 0.6)
    self.removing_ = true
  end
end

function LeadingEffect:onDetach()
  self.action_ = nil
end

