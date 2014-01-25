--------------------------------------------------------------------------------
-- LevelCell Rig
--------------------------------------------------------------------------------
LevelCell = {}

function LevelCell.new( level )
  local self = setmetatable( {}, { __index = LevelCell } )

  self.globalDragCoeff_ = settings.world.global_drag

  -- Initialise size to zero and use reset() to generate the cell
  self.entities_   = ActiveSet.new()
  self.dynamicSet_ = ActiveSet.new()

  -- Save level properties
  self.level_       = level
  self.world_       = level.world_
  self.bgLayer_     = level.bgLayer_
  self.fgLayer_     = level.fgLayer_
  self.assets_      = level.assets_
  self.lightmap_    = level.lightmap_

  self:initDynamicController_()

  return self
end

function LevelCell:initDynamicController_()
  self.dynamicBodyController_ = function(body, entity)
    if not body or not body:isAwake() then
      return
    end
    
    local dragCoeff  = entity.dragCoefficient
    local posX, posY = body:getWorldCenter()
    local velX, velY = body:getLinearVelocity()
      
    dragCoeff = dragCoeff * self.globalDragCoeff_

    local speed     = math.sqrt( velX * velX + velY * velY )
    local dragForce = dragCoeff * speed
    local dragX, dragY

    dragX, dragY = - dragForce * velX, - dragForce * velY

    body:applyForce( dragX, dragY, posX, posY )
  end

  --self.dynamicSet_:addController(
  --    self.dynamicBodyController_, ActiveSet.PASS_OBJECT_AND_DATA)
end


function LevelCell:lookupBody( body )
  return self.level_:lookupBody( body )
end

function LevelCell:addEntity( entity )
  self.entities_:add( entity )
end

function LevelCell:removeEntity( entity )
  self.entities_:remove( entity )
end

function LevelCell:registerDynamicBody( body, entity )
  self.dynamicSet_:add( body, entity )
  self.level_:registerBody( body, entity )
end

function LevelCell:registerStaticBody( body, entity )
  self.level_:registerBody( body, entity )
end

function LevelCell:deregisterDynamicBody( body )
  self.level_:deregisterBody( body )
  self.dynamicSet_:remove( body )
end

function LevelCell:deregisterStaticBody( body )
  self.level_:deregisterBody( body )
end

function LevelCell:destroy()
  if self.entities_:getObjectCount() > 0 then
    self.entities_:callMethod( 'destroy' )
    if self.entities_:getObjectCount() > 0 or
       self.dynamicSet_:getObjectCount() > 0 then
      print(
        ('LevelCell: Dirty destroy(): (ent %d; dyn %d)'):format(
          self.entities_:getObjectCount(),
          self.dynamicSet_:getObjectCount()
        )
      )
    end
  end
end

-------------------------------------------------------------------------------
-- Level rig
-------------------------------------------------------------------------------
Level = {}

function Level.new(world, bgLayer, fgLayer, assets)
  local self = setmetatable({}, { __index = Level })
  
  self.world_ = world
  self.bgLayer_ = bgLayer
  self.fgLayer_ = fgLayer
  self.assets_ = assets

  self.bodyLookup_ = ActiveSet.new()

  return self
end

function Level:nextLevel()
  local nextIndex = self.defIndex_ + 1
  if nextIndex == #settings.levels + 1 then
    self:fadeScreenIn(settings.world.new_level_fade_color,
                      settings.world.new_level_fade_time)
    self:endOfGameHack()
  else
    self:fadeScreenIn(settings.world.new_level_fade_color,
                      settings.world.new_level_fade_time)
    self:loadByIndex(nextIndex)
    self:fadeScreenOut(settings.world.new_level_fade_time)
  end
end

function Level:lose()
  self:showGameOver()
  function callback(key, down)
    if down == false then return end
    local coro = MOAICoroutine.new()
    coro:run(function()
      MOAIInputMgr.device.mouseLeft:setCallback(nil)
      self:restart()
    end)
  end
  MOAIInputMgr.device.mouseLeft:setCallback(callback)
end

function Level:fadeScreenIn(color, time)
  local fader = MOAIProp2D.new()
  fader:setDeck(self.assets.fader)
  fader:setPriority(settings.priorities.lightmap + 20)

  if self.globalCell then 
    fader:setColor(0, 0, 0, 0)
    fader:setProp(settings.priorities.fader)
    self.fgLayer_:insertProp(fader)
    MOAICoroutine.blockOnAction(fader:seekColor(
        color[1], color[2], color[3], 1.0, time, MOAIEaseType.EASE_OUT))
  else
    fader:setColor(color[1], color[2], color[3])
  end

  self.fader_ = fader
end

function Level:fadeScreenOut(time)
  local fader = self.fader_
  MOAICoroutine.blockOnAction(fader:seekColor(0, 0, 0, 0, time,
                                              MOAIEaseType.EASE_OUT))
  self.fgLayer_:removeProp(fader)
  self.fader_ = nil
end

function Level:loadDefinition(index)
  --if not index then index = self.defIndex_
  --else self.defIndex_ = index end

  --local loader, err = loadfile(settings.levels[self.defIndex_].definition_path)
  --if loader == nil then print('Cannot open level ' .. err)
  --else def = loader() end

  local def
  return def
end

function Level:clearTransients_()
  if self.transientCell_ then self.transientCell_:destroy() end
  self.transientCell_ = LevelCell.new(self, assets)
end

function Level:restart()
  local def = self:loadDefinition()
  local fadeColor = settings.effects.new_game_fade_color
  local fadeTime = settings.effects.new_game_fade_time
  self:fadeScreenIn(fadeColor, fadeTime)
  self:removeGameOver()
  self:clearTransients_()
  self:createTransients_(def)
  self:fadeScreenOut(fadeTime)
end

function Level:createTransients_(def)
  self.players_ = {}
  for iPlayer = 1, 2 do
    self.players_[iPlayer] = Player.new(
        self.transientCell_,
        self.assets_.players[iPlayer],
        settings.entities.players[iPlayer])
  end
end

function Level:clearCells_()
  self.fgLayer_:clear()
  self:clearTransients_()
  if self.globalCell_ then self.globalCell_:destroy() end
  self.globalCell_ = LevelCell.new(self, self.assets_)
end

function Level:endOfGameHack()
    MOAICoroutine.blockOnAction(
        self.fader_:seekColor(0, 0, 0, 1, 4.0, MOAIEaseType.SMOOTH))
end

function Level:loadByIndex(newIndex)
  self:clearCells_()
  local def = self:loadDefinition(newIndex)
  self:createTransients_(def)

  self:addOuterWalls_()
end

function Level:addOuterWalls_()
  local body = self.world_:addBody(MOAIBox2DBody.STATIC)
  local w2, h2 = Game.kScreenWidth / 2, Game.kScreenHeight / 2
  body:addChain({-w2, -h2, w2, -h2, w2, h2, -w2, h2}, true)
end

function Level:registerBody( body, entity )
  self.bodyLookup_:add( body, entity )
end

function Level:deregisterBody( body )
  self.bodyLookup_:remove( body )
end

function Level:lookupBody( body )
  return self.bodyLookup_:lookup( body )
end

function Level:setCamera( camera )
  self.camera_ = camera
end

function Level:setPlayer( player )
  self.player_ = player
end

function Level:pause() end
function Level:unpause() end
