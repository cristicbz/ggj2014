LeadingEffect = setmetatable({}, {__index = Effect})

function LeadingEffect.attach(entity)
  return Effect.attach(LeadingEffect, entity)
end

function LeadingEffect:onAttach()
  self:getEntity().prop_:seekScl(1.5, 1.5, 0.6)
end

function LeadingEffect:onDetach()
  self:getEntity().prop_:setScl(1, 1)
end

