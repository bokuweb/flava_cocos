GameOver = cc.Layer.extend
  _music : null
  ctor: -> @_super()

  init: (id, stats)->
    @_music = cc.audioEngine
    score = stats.score

    highScore = sys.localStorage.getItem id
    if highScore < score
      sys.localStorage.setItem id, score
      highScore = score

    rank = @_calcRank score
    result = @_calcResult score, rank

    @_renderStats score, rank, result
    @_renderBackground()

    logo = cc.Sprite.create res.logo
    logo.x = 88
    logo.y = cc.director.getWinSize().height - 50
    @addChild  logo, 1

    @_debugLabel = new cc.LabelTTF "", "Arial", 8
    @_debugLabel.attr
      x : 120
      y: cc.winSize.height - 300
    @_debugLabel.setColor cc.color(25,25,25,25)
    @addChild @_debugLabel, 99

  _calcRank : (score)->
    if score > 97500      then  rank ="SSS"
    else if score > 95000 then  rank ="SS"
    else if score > 92500 then  rank ="S"
    else if score > 90000 then  rank ="A"
    else if score > 80000 then  rank ="B"
    else if score > 70000 then  rank ="C"
    else rank ="D"
    rank

  _calcResult : (score, rank)->
    if rank is "D" then result = "Failed" else
      if score >= 100000 then result = "Perfect!!" else result = "Clear!"
    result

  _renderStats : (score, rank, result)->
    overBg = cc.LayerColor.create new cc.Color(0,0,0,0)
    overBg.setOpacity 168
    @addChild overBg, 4

    resultLabel = new cc.LabelTTF "0", "Arial Bold", 76, cc.size(320,0), cc.TEXT_ALIGNMENT_CENTER
    resultLabel.attr
      x : 160
      y : cc.director.getWinSize().height - 90
    resultLabel.setColor cc.color(255,255,255,255)
    resultLabel.setString result
    @addChild resultLabel, 5

    scoreLabel = new cc.LabelTTF "0", "Arial Bold", 80, cc.size(320,0), cc.TEXT_ALIGNMENT_CENTER
    scoreLabel.attr
      x : 160
      y : cc.director.getWinSize().height - 190
    scoreLabel.setColor cc.color(255,255,255,255)

    scoreLabel.setString score
    @addChild scoreLabel, 5

    rankLabel = new cc.LabelTTF "0", "Arial Bold", 120, cc.size(320,0), cc.TEXT_ALIGNMENT_CENTER
    rankLabel.attr
      x : 160
      y : cc.director.getWinSize().height - 320
    rankLabel.setColor cc.color(255,255,255,255)

    rankLabel.setString rank
    @addChild rankLabel, 5

    rankMessageLabel = new cc.LabelTTF "0", "Arial", 16, cc.size(100,0), cc.TEXT_ALIGNMENT_LEFT
    rankMessageLabel.attr
      x : 100
      y : cc.director.getWinSize().height - 250
    rankMessageLabel.setColor cc.color(255,255,255,255)

    rankMessageLabel.setString "your rank is.."
    @addChild rankMessageLabel, 5

    scoreMessageLabel = new cc.LabelTTF "0", "Arial", 16, cc.size(100,0), cc.TEXT_ALIGNMENT_LEFT
    scoreMessageLabel.attr
      x : 100
      y : cc.director.getWinSize().height - 140
    scoreMessageLabel.setColor cc.color(255,255,255,255)

    scoreMessageLabel.setString "Score "
    @addChild scoreMessageLabel, 5

  _renderBackground : ->
    bg = cc.Sprite.create res.backgroundImage
    bg.x = cc.director.getWinSize().width / 2
    bg.y = cc.director.getWinSize().height / 2
    @addChild bg, 0
    bgToucheventListener = cc.EventListener.create
      event: cc.EventListener.TOUCH_ONE_BY_ONE
      swallowTouches: true
      onTouchBegan: @_onTouchBeganBg.bind @

    cc.eventManager.addListener bgToucheventListener.clone(), bg

  _onTouchBeganBg : (touch, event) ->
    target = event.getCurrentTarget()
    locationInNode = target.convertToNodeSpace touch.getLocation()
    s = target.getContentSize()
    rect = cc.rect 0, 0, s.width, s.height
    if cc.rectContainsPoint rect, locationInNode
      # on touch
      @_music.playEffect res.cancelEffect
      menu = new menuScene()
      cc.director.runScene menu
      return true
    return false

@gameOverScene = cc.Scene.extend
  onEnter: -> @_super()

  init: (id, stats)->
    layer = new GameOver()
    layer.init id, stats
    @addChild layer, 10
    return
