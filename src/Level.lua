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

  self.dynamicSet_:addController(
      self.dynamicBodyController_, ActiveSet.PASS_OBJECT_AND_DATA)
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

  math.randomseed(os.time())
  math.random() math.random() math.random()
  local trackIndex = math.ceil(math.random() * (#settings.music_tracks))
  print(trackIndex, settings.music_tracks[trackIndex].path, os.time() )
  self.trackVolume_ = settings.music_tracks[trackIndex].volume
  self.track_ = MOAIUntzSound.new()
  self.track_:load(settings.music_tracks[trackIndex].path)
  self.track_:setVolume(self.trackVolume_)

  self.scoreBar_ = ScoreBar.new(fgLayer, settings.entities.score_bar)

  return self
end

function Level:showIntro()
  if settings.debug.skip_intro then
    self.world_:start()
    self.track_:play(true)
  else
    local opts = settings.intro
    local phases = {}
    local prevTime = 0.0
    for _, phaseDef in pairs(opts.phases) do
      local phase = {
        delay = (phaseDef.at - prevTime) * 0.5,
      }

      if phaseDef.image then
        local deck = MOAIGfxQuad2D.new()
        local w2 = phaseDef.width * Game.kPixelToWorld / 2
        local h2 = phaseDef.height * Game.kPixelToWorld / 2
        deck:setTexture(phaseDef.image)
        deck:setRect(-w2, -h2, w2, h2)
        phase.deck = deck
      end

      prevTime = phaseDef.at

      table.insert(phases, phase)
    end

    local prop = MOAIProp2D.new()
    self.fgLayer_:insertProp(prop)
    prop:setScl(0, 0)
    prop:setPriority(settings.priorities.text)
    
    MOAICoroutine.new():run(
      function()
        --local timer = MOAITimer.new()
        --local _, first = next(phases)
        --timer:start()
        --MOAICoroutine.blockOnAction(timer)
        --timer:setSpan(0.1)
        self.assets_.intro_sound:play()
        for _, phase in pairs(phases) do
          MOAICoroutine.blockOnAction(
              prop:seekScl(0, 0, phase.delay, MOAIEaseType.EASE_OUT))
          if phase.deck then
            prop:setDeck(phase.deck)
            MOAICoroutine.blockOnAction(
                prop:seekScl(1, 1, phase.delay, MOAIEaseType.EASE_OUT))
          end
        end

        self.fgLayer_:removeProp(prop)
        self.world_:start()
        if not self.track_:isPlaying() then 
          self.track_:setVolume(self.trackVolume_)
          self.track_:play(true)
        else
          self.track_:seekVolume(self.trackVolume_, .8, MOAIEaseType.LINEAR)
        end
      end)
  end
end

function Level:nextLevel()
  local fadeColor = settings.effects.new_game_fade_color
  local fadeTime = settings.effects.new_game_fade_time
  local nextIndex = self.defIndex_ % (#settings.levels) + 1
  self:fadeScreenIn(fadeColor, fadeTime)
  self:loadByIndex(nextIndex)
  self:fadeScreenOut(fadeTime)
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

function Level:win(player)
  if not self.ended_ then
    self.ended_ = true
    self.controlManager_:disable()
    for _, p in pairs(self.players_) do
      p:disableControl()
    end
    MOAICoroutine.new():run(
      function()
        self.assets_.endofround_sound:play()
        self:fadeScreenIn({0, 0, 0, .8}, 0.5)
        local prop = MOAIProp2D.new()
        prop:setDeck(player:getWinDeck())
        prop:setScl(0, 0)
        prop:seekScl(1, 1, .3, MOAIEaseType.EASE_IN)
        prop:setPriority(settings.priorities.text)
        self.fgLayer_:insertProp(prop)
        Keyboard:addListener(
            function(key, pressed)
              MOAICoroutine.new():run(
                function()
                  if key == string.byte(' ') and pressed then 
                    local act = prop:seekScl(0, 0, .2, MOAIEaseType.EASE_IN)
                    self.track_:seekVolume(0, .8, MOAIEaseType.LINEAR)
                    MOAICoroutine.blockOnAction(act)
                    self.world_:stop()
                    self:nextLevel()
                    self.ended_ = false
                    self:showIntro()
                    return RemoveListenerReturnValue
                  end
                end)
            end)
      end)
  end
end

function Level:fadeScreenIn(color, time)
  local fader = self.fader_
  if not fader then
    fader = MOAIProp2D.new()
    fader:setDeck(self.assets_.fader)
    fader:setPriority(settings.priorities.fader)
    fader:setColor(0, 0, 0, 0)
  end

  if self.globalCell_ then 
    self.fgLayer_:insertProp(fader)
    MOAICoroutine.blockOnAction(fader:seekColor(
        color[1], color[2], color[3], color[4], time, MOAIEaseType.EASE_OUT))
  else
    fader:setColor(color[1], color[2], color[3], color[4])
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
  if not index then index = self.defIndex_
  else self.defIndex_ = index end

  local loader, err = loadfile(settings.levels[self.defIndex_].definition_path)
  local def
  if loader == nil then print('Cannot open level; reason: ' .. err)
  else def = loader() end

  return def
end

function Level:clearTransients_()
  MOAIRenderMgr.setBufferTable({})
  self.scoreBar_:update(0, 0)
  if self.controlManager_ then
    self.controlManager_:destroy()
    self.controlManager_ = nil
  end
  if self.transientCell_ then self.transientCell_:destroy() end
  self.transientCell_ = LevelCell.new(self, assets)
end

function Level:restart()
  local def = self:loadDefinition()
  local fadeColor = settings.effects.new_game_fade_color
  local fadeTime = settings.effects.new_game_fade_time
  self:fadeScreenIn(fadeColor, fadeTime)
  self:clearTransients_()
  self:createTransients_(def)
  self:fadeScreenOut(fadeTime)
end

function Level:createTransients_(def)
  local playerDefs = {def.player1[1].circle, def.player2[1].circle}
  self.players_ = {}
  for iPlayer = 1, 2 do
    local player = Player.new(
        self.transientCell_,
        self.assets_.players[iPlayer],
        settings.entities.players[iPlayer])

    player:moveTo(unpack(playerDefs[iPlayer]))
    self.players_[iPlayer] = player
  end

  MOAIRenderMgr.setBufferTable(
      {self.players_[1].masker_:getFrameBuffer(),
       self.players_[2].masker_:getFrameBuffer()})

  self:createControlManager_(def)
end

function Level:createControlManager_(def)
  self.controlManager_ = ControlManager.new(self.transientCell_)
  self.controlManager_:addFromDefinition(def.controlareas)
  self.controlManager_:scoresChangedSource():addListener(
      function()
        self.scoreBar_:update(self.players_[1].score_, self.players_[2].score_)
      end)
end

function Level:createSpecials_(def)
  if def.specials then
    for _, object in pairs(def.specials) do
      if object.subclass == 'speed' then
        Speeder.new(self.globalCell_, object, self.assets_.speeder)
      end
    end
  end
end

function Level:createWalls_(def)
  self.wallsHandler_ = function(phase, a, b)
    local player = self:lookupBody(b:getBody())
    if player == nil then return end

    self.controlManager_:captureTouching(player)
  end

  if self.walls_ then
    self.walls_.body:destroy()
    for _, prop in pairs(self.walls_.props) do
      self.fgLayer_:removeProp(prop)
    end
    self.walls_ = nil
  end

  local body = self.world_:addBody(MOAIBox2DBody.STATIC)
  local props = {}

  local vertexfmt = MOAIVertexFormat.new()
  vertexfmt:declareCoord(1, MOAIVertexFormat.GL_FLOAT, 2)
  vertexfmt:declareUV(2, MOAIVertexFormat.GL_FLOAT, 2)
  vertexfmt:declareColor(3, MOAIVertexFormat.GL_UNSIGNED_BYTE)

  local pixelTex = MOAITexture.new()
  pixelTex:load(settings.misc.pixel_texture_path)

  for _, object in pairs(def.walls) do
    local fixture = body:addChain(object.poly, true)
    fixture:setCollisionHandler(self.wallsHandler_, MOAIBox2DArbiter.PRE_SOLVE)

    if settings.debug.render_walls and object.convex then
      for _, poly in pairs(object.convex) do
        local vertexbuf = MOAIVertexBuffer.new()
        vertexbuf:setFormat(vertexfmt)
        vertexbuf:reserveVerts(#poly / 2)
        for i = 1, #poly / 2 do
          vertexbuf:writeFloat(poly[i * 2 - 1], poly[i * 2], 0, 0)
          vertexbuf:writeColor32(1, 1, 1, 1)
        end
        vertexbuf:bless()

        local mesh = MOAIMesh.new()
        mesh:setVertexBuffer(vertexbuf)
        mesh:setPrimType(MOAIMesh.GL_TRIANGLE_FAN)
        mesh:setTexture(pixelTex)

        local prop = MOAIProp2D.new()
        prop:setDeck(mesh)
        prop:setColor(0.5, 0.5, 0.5, 0.5)
        self.fgLayer_:insertProp(prop)
        table.insert(props, prop)
      end
    end
  end

  self.walls_ = {body = body, props = props}
end

function Level:destroyWalls()
  if self.walls_ then
    self.walls_.body:destroy()
    for _, prop in pairs(self.walls_.props) do
      self.fgLayer_:removeProp(prop)
    end
  end
end

function Level:clearCells_()
  self:clearTransients_()
  if self.globalCell_ then self.globalCell_:destroy() end
  self.globalCell_ = LevelCell.new(self, self.assets_)
end

function Level:endOfGameHack()
    MOAICoroutine.blockOnAction(
        self.fader_:seekColor(0, 0, 0, 1, 4.0, MOAIEaseType.SMOOTH))
end

function Level:loadBackground(index)
  if not self.background_ then
    self.background_ = MOAIGfxQuad2D.new()
    self.background_:setRect(
        -Game.kScreenWidth / 2, -Game.kScreenHeight / 2,
        Game.kScreenWidth / 2, Game.kScreenHeight / 2)

    self.backgroundProp_ = MOAIProp2D.new()
    self.backgroundProp_:setDeck(self.background_)

    self.bgLayer_:insertProp(self.backgroundProp_)
  end

  self.background_:setTexture(settings.levels[index].background_path)
end

function Level:loadByIndex(newIndex)
  self:clearCells_()
  local def = self:loadDefinition(newIndex)
  self:loadBackground(newIndex)
  self:createWalls_(def)
  self:createTransients_(def)
  self:createSpecials_(def)
  self.world_:stop()
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
function Level:unpause()
  self:showIntro()
end
