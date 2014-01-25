ControlManager = setmetatable({}, {__index = PhysicalEntity})

function ControlManager.new(cell)
  local self = setmetatable(
    PhysicalEntity.new(cell)
  , {__index = ControlManager})

  self:createBody_(MOAIBox2DBody.STATIC)

  local touchedBy = {}
  local ownedBy = {}
  local groupsOwnedBy = {}
  local fixtureToArea = {}

  self.staticHandler_ = function(phase, a, b)
    local area = fixtureToArea[a]
    local player = cell:lookupBody(b:getBody())
    if player == nil then return end
    if not touchedBy[player] then touchedBy[player] = {} end
    if phase == MOAIBox2DArbiter.BEGIN then
      touchedBy[player][area] = true
    elseif phase == MOAIBox2DArbiter.END then
      touchedBy[player][area] = nil
    end
  end

  self.fixtureToArea_ = fixtureToArea
  self.touchedBy_ = touchedBy
  self.ownedBy_ = ownedBy
  self.groupsOwnedBy_ = groupsOwnedBy
  self.maskLayer_ = cell.fgLayer_

  return self
end

function ControlManager:captureTouching(player)
  if self.touchedBy_[player] == nil then return end
  if self.ownedBy_[player] == nil then self.ownedBy_[player] = {} end

  for area, _ in pairs(self.touchedBy_[player]) do
    area:setOwner(player)
  end
end

function ControlManager:addFromDefinition(def)
  local dualWorld = MOAIBox2DWorld.new()
  local dualFixtureToArea = {}

  for _, object in pairs(def) do
    local area = ControlArea.new(self, self.maskLayer_)
    local dualBody = dualWorld:addBody(MOAIBox2DBody.DYNAMIC)

    if not object.convex then
      error('Non-convexified control area. Did you forget triangulate?')
    end

    for _, ccw_poly in pairs(object.convex) do
      local cw_poly = reversed_poly(ccw_poly)

      local fixture = self.body:addPolygon(cw_poly)
      fixture:setSensor(true)
      fixture:setCollisionHandler(self.staticHandler_, MOAIBox2DArbiter.ALL)
      self.fixtureToArea_[fixture] = area

      local dualFixture = dualBody:addPolygon(cw_poly)
      dualFixture:setSensor(true)
      dualFixture:setCollisionHandler(
          function(phase, a, b)
            local a = dualFixtureToArea[a]
            local b = dualFixtureToArea[b]
            if not a or not b then error('non-fixture collision') end
            if a ~= b then a:connectTo(b) end
          end, MOAIBox2DArbiter.BEGIN)
      dualFixtureToArea[dualFixture] = area

      area:addPoly(cw_poly)
    end
  end

  dualWorld:start()
end

function ControlManager:destroy()
  
end

ControlArea = {}

function ControlArea.new(manager, layer)
  local self = setmetatable({}, {__index = ControlArea})

  self.manager_ = manager
  self.layer_ = layer
  self.polys_ = {}
  self.connections_ = {}
  self.owner_ = nil
  self.centre_ = nil
  self.group_ = nil
  self.pulsing_ = false
  self.pulseDelay_ = 0.1

  return self
end

function ControlArea:addPoly(poly)
  table.insert(self.polys_, poly)
  self:updateCentre_()
end

function ControlArea:updateCentre_()
  local cx, cy = 0, 0
  local totalVerts = 0
  for _, poly in pairs(self.polys_) do
    local nVerts = #poly / 2
    totalVerts = totalVerts + nVerts
    for iVert = 1, nVerts do
      cx, cy = cx + poly[iVert * 2 - 1], cy + poly[iVert * 2]
    end
  end

  self.centreX_, self.centreY_ = cx / totalVerts, cy / totalVerts
end

function ControlArea:pulse(delay)
  if not self.group_ then print('pulse with no group') end
  if self.pulsing_ then return end
  if delay == nil then delay = 0 end

  self.pulsing_ = true
  for area, _ in pairs(self.group_.areas_) do
    area:pulse(math.random() * 0.1)
  end

  MOAICoroutine.new():run(
      function()
        local timer = MOAITimer.new()
        timer:setSpan(delay)
        timer:start()
        MOAICoroutine.blockOnAction(timer)
        MOAICoroutine.blockOnAction(self.prop_:seekScl(1.4, 1.4, 0.1,
                                    MOAIEaseType.LINEAR))
        MOAICoroutine.blockOnAction(self.prop_:seekScl(1, 1, 0.3,
                                    MOAIEaseType.EASE_IN))
        self.pulsing_ = false
      end)
end

function ControlArea:setOwner(new_owner)
  if new_owner == self.owner_ then 
    --if group_ then self:pulse() end
    return
  end

  if self.prop_ == nil then
    self.prop_ = MOAIProp2D.new()
    self.prop_:setLoc(self.centreX_, self.centreY_)
    self.prop_:setBlendMode(MOAIProp.GL_ONE, MOAIProp.GL_ONE)
    self.prop_:setRot(math.random() * 360)
    self.layer_:insertProp(self.prop_)
  elseif self.owner_ == nil then
    self.prop_:setVisible(true)
  else
    self.manager_.ownedBy_[self.owner_][self] = nil
    self.owner_ = new_owner
    self.group_:removeAndSplit(self)
  end

  if self.group_ then error('shouldn\'t have a group') end

  self.owner_ = new_owner
  if new_owner then
    self.prop_:setDeck(new_owner:getMaskDeck())
    self.prop_:setColor(unpack(new_owner:getColor()))
    self.manager_.ownedBy_[new_owner][self] = true

    for other, _ in pairs(self.connections_) do
      if other.owner_ == new_owner then
        if self.group_ then
          if other.group_ ~= self.group_ then
            self.group_:merge(other.group_)
          end
        else
          other.group_:add(self)
        end
      end
    end

    if not self.group_ then
      self.group_ = ControlGroup.new(self.manager_, self)
    end
    self:pulse()
  else
    self.prop_:setVisible(false)
  end
end

function ControlArea:getOwner()
  return self.owner_
end

function ControlArea:connectTo(other)
  self.connections_[other] = true
  other.connections_[self] = true
end

ControlGroup = {}

function ControlGroup.new(manager, seed)
  local self = setmetatable({}, {__index = ControlGroup})
  local owner = seed.owner_

  self.areas_ = {}
  self.areas_[seed] = true

  self.numAreas_ = 1
  self.owner_ = owner
  self.manager_ = manager
  if manager.groupsOwnedBy_[owner] == nil then
    manager.groupsOwnedBy_[owner] = {}
  end
  manager.groupsOwnedBy_[owner][self] = true

  return self
end

function crawlFromArea(seed, into)
  if into[seed] then return 0 end
  local nCrawled = 1

  into[seed] = true
  for other, _ in pairs(seed.connections_) do
    if other.group_ == seed.group_ then
      if other.owner_ ~= seed.owner_ then 
        error('adjacent, same owner, diff groups')
      end
      nCrawled = nCrawled + crawlFromArea(other, into)
    end
  end

  return nCrawled
end

function ControlGroup:removeAndSplit(area)
  local areas = self.areas_

  if not areas[area] then error('area not owned by group!') end
  if area.group_ ~= self then error('area doesn\'t know about us') end

  areas[area] = nil
  area.group_ = nil
  self.numAreas_ = self.numAreas_ - 1

  if self.numAreas_ == 0 then
    -- This was a singleton group, we should just remove ourselves from the
    -- manager.
    self.manager_.groupsOwnedBy_[self.owner_][self] = nil
    return
  end


  -- Otherwise we may need to split the group. Remove the area and start
  -- crawling from one spot
  local seed, _ = next(areas)
  local crawled = {}
  local nCrawled = crawlFromArea(seed, crawled)

  if nCrawled ~= self.numAreas_ then
    -- We lost connectivity; move the crawled areas into a new group.
    local new_group = ControlGroup.new(self.manager_, seed)
    -- Force group assignment since we've already crawled everything.
    new_group.numAreas_ = nCrawled
    new_group.areas_ = crawled
    self.numAreas_ = self.numAreas_ - nCrawled
    for area, _ in pairs(crawled) do
      areas[area] = nil
      area.group_ = new_group
    end
  end
end

function ControlGroup:merge(other)
  if other == self then error('merge with self') end 

  if other.owner_ ~= self.owner_ then 
    error('attempted to merge groups with different owners')
  end

  self.numAreas_ = self.numAreas_ + other.numAreas_
  for area, _ in pairs(other.areas_) do
    area.group_ = self
    if self.areas_[area] then error('double group') end
    self.areas_[area] = true
  end
  self.manager_.groupsOwnedBy_[self.owner_][other] = nil
end

function ControlGroup:add(area)
  if area.owner_ ~= self.owner_ then
    error('attempted to add area from different owner')
  end
  if area.group_ ~= nil then
    error('attempted to add area from different group')
  end
  self.areas_[area] = true
  area.group_ = self
end