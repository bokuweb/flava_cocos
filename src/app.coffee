gameLayer = cc.Layer.extend
  _noteOffsetX : 50
  _noteMarginX : 54
  _noteRemovesTiming : 0.2
  _noteMaskHeight : 190
  _playTime : 0
  _timeLabel : null
  _debugLabel : null
  _status : "stop"
  _music : null
  _musicInfo : null
  _volume : 1
  _targetY : 90
  _note :
    active : []
    timing : null
    key : null
    speed : 0
    index : 0
  _judgeLabel : null
  _threshold :
    great : 0.15
    good : 0.3
  _combo : 0
  _comboLabel : null
  _startTime : 0
  _score :
    real : 0
    display : 0
  _endTime : 30
  _judgeCount :
    great : 0
    good : 0
    bad : 0

  ctor: -> @_super()

  init: (info)->
    @_status = "stop"
    @_note.active.length = 0
    @_note.index = 0
    @_note.timing = info.timing
    @_note.key = info.key
    @_note.speed = info.speed

    cc.log info.timing
    
    @_startTime = 0
    @_score.real = 0
    @_score.display = 0
    for k, v of @_judgeCount then v = 0
    for k, v of @_score then v = 0
    @_musicInfo = info
    @_addBackground()
    @_renderTarget()
    @_music = cc.audioEngine
    @_music.setMusicVolume 1

    @_addJudgeLabel()
    @_addComboLabel()
    @_renderScore()
    @_addMusicInfo()
    @_addStartButton()

    logo = cc.Sprite.create res.logo
    logo.attr
      x : 83
      y : cc.director.getWinSize().height - 50
    @addChild  logo, 1

    closeToucheventListener = cc.EventListener.create
      event: cc.EventListener.TOUCH_ONE_BY_ONE
      swallowTouches: true
      onTouchBegan: @_onTouchBeganClose.bind @

    closeButton = new cc.Sprite res.closeButtonBlackImage
    closeButton.attr
      x : cc.director.getWinSize().width - 40
      y : cc.director.getWinSize().height - 40
    cc.eventManager.addListener closeToucheventListener.clone(), closeButton
    @addChild closeButton, 1
   
    @_debugLabel = new cc.LabelTTF "", "Arial", 8
    @_debugLabel.attr
      x : 120
      y: cc.winSize.height - 200
    @_debugLabel.setColor cc.color(25,25,25,255)      
    @addChild @_debugLabel, 99      

    #@_debugLabel.setString info.id + " / " + sys.localStorage.getItem info.id
    
  update: ->
    @_measureMusicTime()
    @_appendNote()
    @_moveNote()
    @_removeNoteIfTimeOver()
    @_judgeNote()
    @_updateScore()

  _renderTarget : ->
    for i in [0...5]
      target = new cc.Sprite res.targetImage
      target.attr
        x: @_noteMarginX * i + @_noteOffsetX
        y: @_targetY
        scale : 0
        opacity : 0
      @addChild target, 1
      target.runAction cc.spawn(cc.fadeIn(0.3), cc.scaleTo(0.3, 0.9))
    return

  _addBackground : ->
    bg = cc.Sprite.create res.backgroundImage
    bg.x = cc.director.getWinSize().width / 2
    bg.y = cc.director.getWinSize().height / 2
    bg.scale = 1
    @addChild bg, 0

  _addJudgeLabel : ->
    @_judgeLabel = new cc.LabelTTF "Great", "Arial", 20, cc.size(200,0), cc.TEXT_ALIGNMENT_LEFT
    @_judgeLabel.attr
      x : 225
      y : 235
      opacity : 0

    @_judgeLabel.setColor cc.color(72,72,72,255)
    @addChild @_judgeLabel, 5

  _addComboLabel : ->
    @_comboLabel = new cc.LabelTTF "0", "Arial", 20, cc.size(200,0), cc.TEXT_ALIGNMENT_LEFT
    @_comboLabel.attr
      x : 225
      y : 205
      opacity : 0
      isShown : false

    @_comboLabel.setColor cc.color(72,72,72,255)
    @addChild @_comboLabel, 5

  _renderScore : ->
    ###
    icon = new cc.Sprite res.scoreIconImage
    icon.attr
      x : 204
      y : cc.winSize.height - 144
      scale: 0.23
    icon.setAnchorPoint cc.p(0,1)
    @addChild icon, 5
    ###
    @_scoreLabel = new cc.LabelTTF "0", "Arial", 15, cc.size(200,0), cc.TEXT_ALIGNMENT_LEFT
    @_scoreLabel.attr
      x : 210
      y: cc.winSize.height - 170
      opacity : 0
      scale : 0
    @_scoreLabel.setColor cc.color(80,80,80,255)
    @addChild @_scoreLabel, 5
    @_scoreLabel.runAction cc.spawn(cc.fadeIn(0.3), cc.scaleTo(0.3, 1))
    
  _addMusicInfo : ->
    @_renderCoverImage()
    @_renderTitle()
    @_renderMode()
    @_renderLevel()
    @_renderHighScore()

  _renderCoverImage : ->
    coverImage = new cc.Sprite @_musicInfo.coverImage, cc.rect(0, 0, 60, 60)
    coverImage.attr
      x: 55
      y: cc.winSize.height - 110
      opacity : 0
      scale : 0
    @addChild coverImage, 6
    coverImage.runAction cc.spawn(cc.fadeIn(0.3), cc.scaleTo(0.3, 1))

  _renderTitle : ->
    title = new cc.LabelTTF "0", "Arial", 12, cc.size(200,0), cc.TEXT_ALIGNMENT_LEFT
    title.attr
      x : 210
      y : cc.winSize.height - 99
      opacity : 0
      scale : 0

    text = """
      #{@_musicInfo.title}
      #{@_musicInfo.artist}
      #{@_musicInfo.license}
    """

    title.setColor cc.color(51, 51, 51, 255)
    title.setString text
    @addChild title, 5
    title.runAction cc.spawn(cc.fadeIn(0.3), cc.scaleTo(0.3, 1))

  _renderMode : ->
    if @_musicInfo.mode is "normal" then mode = new cc.Sprite res.normalImage
    else if @_musicInfo.mode is "another" then mode = new cc.Sprite res.anotherImage
    mode.attr
      x : 110
      y : cc.winSize.height - 128
      opacity : 0
      scale: 0
      
    mode.setAnchorPoint cc.p(0,1)
    @addChild mode, 5
    mode.runAction cc.spawn(cc.fadeIn(0.3), cc.scaleTo(0.3, 0.6))

  _renderLevel : ->
    level = new cc.Sprite res.star, cc.rect(0, 0, 19*@_musicInfo.level, 18)
    level.attr
      x : 110
      y : cc.winSize.height - 144
      scale: 0
      opacity : 0
    level.setAnchorPoint cc.p(0,1)
    @addChild level, 5
    level.runAction cc.spawn(cc.fadeIn(0.3), cc.scaleTo(0.3, 0.6))

  _renderHighScore : ->
    icon = new cc.Sprite res.highBlackImage
    icon.attr
      x : 175
      y : cc.winSize.height - 129
      scale: 0
      opacity : 0
    icon.setAnchorPoint cc.p(0,1)
    @addChild icon, 5
    icon.runAction cc.spawn(cc.fadeIn(0.3), cc.scaleTo(0.3, 0.16))

    highScore  = new cc.LabelTTF "0", "Arial", 12, cc.size(100, 0), cc.TEXT_ALIGNMENT_LEFT
    highScore.attr
      x : 240
      y : cc.winSize.height - 133
      opacity : 0
      scale : 0

    text = sys.localStorage.getItem @_musicInfo.id
    if text  is "" then text = 0
    highScore.setColor cc.color(51, 51, 51, 255)
    highScore.setString text
    @addChild highScore, 5
    highScore.runAction cc.spawn(cc.fadeIn(0.3), cc.scaleTo(0.3, 1))

  _addStartButton : ->
    @startButton = new cc.LabelTTF "0", "Arial", 14, cc.size(200,30), cc.TEXT_ALIGNMENT_LEFT
    @startButton.attr
      x : 200
      y : cc.winSize.height - 230

    @startButton.setColor cc.color(51,51,51,255)
    @startButton.setString "Touch here to start!"
    @startButton.runAction(
      new cc.RepeatForever(
        cc.sequence(
          cc.fadeTo 1, 0
          cc.fadeTo 1, 255
        )
      )
    )
    @addChild @startButton, 10

    eventListener = cc.EventListener.create
      event: cc.EventListener.TOUCH_ONE_BY_ONE
      swallowTouches: true
      onTouchBegan: @_onTouchBeganStart.bind @
    cc.eventManager.addListener eventListener.clone(), @startButton

  _appendNote : ->
    eventListener = cc.EventListener.create
      event: cc.EventListener.TOUCH_ONE_BY_ONE
      swallowTouches: true
      onTouchBegan: @_onTouchBegan.bind(@)

    if @_note.timing[@_note.index]?
      while @_getCurrentTime() > (@_note.timing[@_note.index] - (cc.winSize.height / @_note.speed))
        note = new cc.Sprite(res.noteSingleImage)
        note.attr
          x: @_note.key[@_note.index] * @_noteMarginX  + @_noteOffsetX
          y: cc.winSize.height + note.height
          scale: 0
          rotation: 0
          opacity: 0
          scale: 0.9
          hasShown : false
          timing : @_note.timing[@_note.index]
          key : @_note.key[@_note.index]

        @_note.active.push note
        cc.eventManager.addListener eventListener.clone(),  note
        @addChild note, 10
        @_note.index++
      return

  _removeNoteIfTimeOver : ->
    note = @_note
    for value,i in note.active
      if value?.timing + @_noteRemovesTiming < @_getCurrentTime() and not value.removed
        value.runAction(
          cc.sequence(
            cc.fadeOut(0.3)
            cc.CallFunc.create(()=>
              if not value.clear
                @_updateJudgeLabel "Bad"
                @_combo = 0
                @_judgeCount.bad++
            @)
          )
        )
        value.removed = true
        break
    return

  _updateScore : ->
    if @_score.real > @_score.display then @_score.display += 10000 / @_note.timing.length
    else @_score.display = if Math.ceil(@_score.real) > 100000 then 100000 else Math.ceil(@_score.real)
    @_scoreLabel.setString ~~@_score.display

  _moveNote : ->
    note = @_note
    targetY = @_targetY
    threshold = @_threshold
    for value,i in note.active
      if value.timing > @_getCurrentTime()
        unless value.clear
          value.y = (value.timing - @_getCurrentTime()) * note.speed + targetY
          value.setRotation (value.timing - @_getCurrentTime()) * 720
      else
        value.y = targetY
        value.setRotation 0
      if value.y < cc.winSize.height - @_noteMaskHeight and not value.hasShown
        value.hasShown = true
        value.runAction cc.spawn(cc.fadeIn(0.2), cc.scaleTo(0.2, 1))
    return

  _judgeNote : ->
    note = @_note
    threshold = @_threshold
    for value,i in note.active
      if value.clear and not value.hasAnimationStarted and not value.removed
        value.runAction cc.spawn(cc.fadeOut(0.3), cc.scaleBy(0.3, 2, 2))
        value.hasAnimationStarted = true
        if -threshold.great < (value.timing - value.clearTime) < threshold.great
          judgement = "Great"
          @_score.real += 100000 / @_note.timing.length
          @_combo++
          @_judgeCount.great++
          cc.log @_score.real
        else if -threshold.good < (value.timing - value.clearTime) < threshold.good
          judgement = "Good"
          @_score.real += 70000 / @_note.timing.length
          @_combo++
          @_judgeCount.good++
        else
          judgement = "Bad"
          @_judgeCount.bad++
          @_combo = 0
        @_updateJudgeLabel judgement

    @_updateComboLabel()
    return

  _updateJudgeLabel : (text)->
    @_judgeLabel.stopAllActions()
    @_judgeLabel.opacity = 255
    @_judgeLabel.setString text
    @_judgeLabel.runAction cc.fadeOut(1)

  _updateComboLabel : ()->
    if @_combo >= 5
      @_comboLabel.isShown = true
      @_comboLabel.stopAllActions()
      @_comboLabel.opacity = 255
      @_comboLabel.setString "x"+@_combo+"chain!"
    else
      if @_comboLabel.isShown
        @_comboLabel.isShown = false
        @_comboLabel.runAction cc.fadeOut(0.5)

  _measureMusicTime : ->
    isPlaying = @_music.isMusicPlaying()
    if isPlaying
      if @_startTime is 0
        @_startTime  = new Date()
        @unschedule @_measureMusicTime

  _getCurrentTime : ->
    if @_startTime isnt 0 then (new Date() - @_startTime) / 1000 else 0

  _checkGameEnd : ->
    if @_getCurrentTime() >= @_endTime and @_status is "playing"
      @_status = "preClose"
      @unschedule @_checkGameEnd
      @schedule @_closeGame, 0.01

  _closeGame : ->
    @_volume -= 0.01
    @_music.setMusicVolume @_volume
    if @_volume <= 0 and @_status = "preClose"
      @_status = "close"

      overBackground = cc.Sprite.create res.backgroundImage
      overBackground.x = cc.director.getWinSize().width / 2
      overBackground.y = cc.director.getWinSize().height / 2
      overBackground.opacity = 0
      @addChild overBackground, 100
      overBackground.runAction(
        cc.sequence(
          cc.fadeIn(0.3)
          cc.CallFunc.create ()=>
            @_music.stopMusic()
            gameOver = new gameOverScene()
            gameOver.init @_musicInfo.id, 
              score : @_score.display
              great : @_judgeCount.great
              good  : @_judgeCount.good
              bad   : @_judgeCount.bad
            cc.director.runScene gameOver
        @)
      )

  _onTouchBegan : (touch, event) ->
    time = @_getCurrentTime()
    target = event.getCurrentTarget()
    locationInNode = target.convertToNodeSpace touch.getLocation()
    s = target.getContentSize()
    rect = cc.rect 0, 0, s.width, s.height
    if cc.rectContainsPoint rect, locationInNode
      unless target.clear
        target.clear = true
        target.clearTime = time
      return true
    return false

  _onTouchBeganStart : (touch, event) ->
    time = @_getCurrentTime()
    target = event.getCurrentTarget()
    locationInNode = target.convertToNodeSpace touch.getLocation()
    s = target.getContentSize()
    rect = cc.rect 0, 0, s.width, s.height
    if cc.rectContainsPoint rect, locationInNode
      @startButton.stopAllActions()
      @startButton.runAction cc.fadeTo(1, 0)
      @_status = "playing"
      @_music.playMusic res.music, false
      @schedule @_checkGameEnd, 1
      @scheduleUpdate()
      return true
    return false

  _onTouchBeganClose : (touch, event) ->
    target = event.getCurrentTarget()
    locationInNode = target.convertToNodeSpace touch.getLocation()
    s = target.getContentSize()
    rect = cc.rect 0, 0, s.width, s.height
    if cc.rectContainsPoint rect, locationInNode
      # タッチ時の処理
      @_music.playEffect res.cancelEffect
      if @_status is "playing"
        @_status = "preClose"
        @unschedule @_checkGameEnd
        @schedule @_closeGame, 0.01
      else if @_status is "stop"
        @_status = "preClose"
        @_music.setMusicVolume 0
        @unschedule @_checkGameEnd
        @schedule @_closeGame, 0.01        

      return true
    return false

@gameScene = cc.Scene.extend
  onEnter: ()->
    @_super()
    return
  init: (info)->
    layer = new gameLayer()
    layer.init info
    @addChild layer
    return

