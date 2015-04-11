Start = cc.Layer.extend
  _music : null
  
  ctor: -> @_super()

  init: ->
    @_music = cc.audioEngine

    logo = cc.Sprite.create res.logo
    logo.x = cc.director.getWinSize().width / 2
    logo.y = cc.director.getWinSize().height / 2
    @addChild  logo, 1

    bg = cc.Sprite.create res.backgroundImage
    bg.x = cc.director.getWinSize().width / 2
    bg.y = cc.director.getWinSize().height / 2
    @addChild bg, 0

    label = new cc.LabelTTF "please, touch here to start","res/fonts/quicksandbook.ttf", 11
    label.attr
      x : cc.director.getWinSize().width / 2
      y : cc.director.getWinSize().height / 2 - 30
    label.setColor cc.color(80,80,80,255)
    @addChild label, 5
    label.runAction(
      new cc.RepeatForever(
        cc.sequence(
          cc.fadeTo 1, 0
          cc.fadeTo 1, 255
        )
      )
    )

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
      @_music.playEffect res.selectEffect
      menu = new menuScene()
      cc.director.runScene new cc.TransitionFade(1.2, menu)
      return true
    return false

@StartScene = cc.Scene.extend
  onEnter: -> @_super()

  init: ->
    layer = new Start()
    layer.init()
    @addChild layer, 10

