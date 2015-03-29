menu = cc.Layer.extend
  _itemPerPage : 6
  _itemnumPerLine : 3
  _notSelectedItemZIndex : 5
  _nextButtonZIndex : 5
  _previousButtonZIndex : 5
  _overBackgroundZIndex : 6
  _selectedItemZIndex : 6
  _closeButtonZIndex : 7
  _enterButtonZIndex : 7
  _showPageNum : 0
  _maxPageNum : 0
  _shownMusicItem : []
  _itemInfo : null
  _nextButton : null
  _enterButton : null
  _previousButton : null
  _blackBackground : null
  _selected : null

  ctor: -> @_super()

  _init: ->
    @_selected = null
    @_addBackground()

    @_maxPageNum = ~~((g_musicList.length - 1) / @_itemPerPage)
    pagerToucheventListener = cc.EventListener.create
      event: cc.EventListener.TOUCH_ONE_BY_ONE
      swallowTouches: true
      onTouchBegan: @_onTouchBeganPager.bind(@)
    @_shownMusicItem.length = 0
    @_showMusicItem(0)

    ###
    @_nextButton = new cc.Sprite(res.testImage, cc.rect(0, 0, 45, 45))
    @_nextButton.attr
      x : cc.director.getWinSize().width
      sequence : "next"

    if @_maxPageNum is 0 then @_nextButton.opacity = 0
    
    cc.eventManager.addListener(pagerToucheventListener.clone(), @_nextButton)
    @addChild(@_nextButton, @_nextButtonZIndex)

    
    @_previousButton = new cc.Sprite(res.testImage, cc.rect(0, 0, 45, 45))
    @_previousButton.attr
      x : 0
      opacity : 0
      sequence : "previous"

    cc.eventManager.addListener(pagerToucheventListener.clone(), @_previousButton)
    @addChild(@_previousButton, @_previousButtonZIndex)
    ###

    logo = cc.Sprite.create res.logo
    logo.x = 83
    logo.y = cc.director.getWinSize().height - 50
    @addChild  logo, 1

  _showMusicItem:(page)->
    musicItemToucheventListener = cc.EventListener.create
      event: cc.EventListener.TOUCH_ONE_BY_ONE
      swallowTouches: true
      onTouchBegan: @_onTouchBeganMusicItem.bind(@)

    for value,i in g_musicList[@_itemPerPage * page...@_itemPerPage * (page + 1)] when value?
      item = new cc.Sprite res.coverImage, cc.rect(0, 0, 60, 60)
      item.attr
        x: (i % @_itemnumPerLine) * 104 + 55
        y: ~~(i / @_itemnumPerLine) * -160 + cc.director.getWinSize().height - 135
        scale: 0
        opacity : 0
        info : value
        hasSelected : false

      cc.eventManager.addListener(musicItemToucheventListener.clone(), item)
      @addChild item, @_notSelectedItemZIndex
      
      item.title = new cc.LabelTTF "", "Arial", 12
      item.title.attr
        x : (i % @_itemnumPerLine) * 104 + 55
        y : ~~(i / @_itemnumPerLine) * -160 + cc.director.getWinSize().height - 177
        opacity: 0
        scale: 1
      item.title.setColor cc.color(25,25,25,255)
      item.title.setString value.title

      item.artist = new cc.LabelTTF "", "Arial", 10
      item.artist.attr
        x : (i % @_itemnumPerLine) * 104 + 55
        y : ~~(i / @_itemnumPerLine) * -160 + cc.director.getWinSize().height - 190
        opacity: 0
        scale: 1
      item.artist.setColor cc.color(25,25,25,255)
      item.artist.setString value.artist

      @addChild item.title, @_notSelectedItemZIndex
      @addChild item.artist, @_notSelectedItemZIndex

      if value.mode is "normal" then item.mode = new cc.Sprite res.normalImage
      else if value.mode is "another" then item.mode = new cc.Sprite res.anotherImage
      item.mode.attr
        x : (i % @_itemnumPerLine) * 104 + 55
        y : ~~(i / @_itemnumPerLine) * -160 + cc.director.getWinSize().height - 206
        opacity: 0
        scale: 0.6
      @addChild item.mode, 10

      item.level = new cc.Sprite res.star, cc.rect(0, 0, 19*value.level, 18)
      item.level.attr
        x : (i % @_itemnumPerLine) * 104 + 55
        y : ~~(i / @_itemnumPerLine) * -160 + cc.director.getWinSize().height - 218
        opacity: 0
        scale: 0.5
      @addChild item.level, 10

      @_shownMusicItem.push item

      item.runAction cc.spawn cc.fadeIn(0.3), cc.scaleTo(0.3, 1)
      item.title.runAction cc.fadeIn(0.3)
      item.artist.runAction cc.fadeIn(0.3)
      item.mode.runAction cc.fadeIn(0.3)
      item.level.runAction cc.fadeIn(0.3)

  _addBackground : ->
    @background = cc.Sprite.create res.backgroundImage
    @background.x = cc.director.getWinSize().width / 2
    @background.y = cc.director.getWinSize().height / 2
    @background.scale = 1
    @addChild  @background, 0

  _onTouchBeganMusicItem : (touch, event) ->
    size = cc.director.getWinSize()
    target = event.getCurrentTarget()
    locationInNode = target.convertToNodeSpace touch.getLocation()
    s = target.getContentSize()
    rect = cc.rect 0, 0, s.width, s.height
    if cc.rectContainsPoint rect, locationInNode
      if not @_selected
        @_selected = target.info.id
        cc.log target.info.id
        if not @_blackBackground?
          @_blackBackground = cc.LayerColor.create new cc.Color(0,0,0,0)
          @addChild(@_blackBackground, @_overBackgroundZIndex)

        @_blackBackground.setOpacity 160

        target.origin =
          x : target.x
          y : target.y
        target.hasSelected = true
        target.zIndex = @_selectedItemZIndex

        target.title.runAction cc.scaleTo(0.2, 0)
        target.artist.runAction cc.scaleTo(0.2, 0)
        target.mode.runAction cc.scaleTo(0.2, 0)
        target.level.runAction cc.scaleTo(0.2, 0)

        for value,i in @_shownMusicItem when not value.hasSelected
          value.runAction cc.scaleTo(0.2, 0)
          value.title.runAction cc.scaleTo(0.2, 0)
          value.artist.runAction cc.scaleTo(0.2, 0)
          value.mode.runAction cc.scaleTo(0.2, 0)          
          value.level.runAction cc.scaleTo(0.2, 0)

        #@_nextButton.runAction(cc.scaleTo(0.2, 0))
        #@_previousButton.runAction(cc.scaleTo(0.2, 0))

        if not @_itemInfo?
          @_itemInfo = new cc.LabelTTF "a", "Arial", 14
          @_itemInfo.attr
            x : 190
            y : size.height / 2 + 38
            opacity : 255
            scale : 0
          @addChild @_itemInfo, @_selectedItemZIndex

          @_itemInfo.mode = new cc.Sprite res.normalImage
          @_itemInfo.mode.attr
            x : 109
            y : size.height / 2 + 5
            opacity: 255
            scale: 0

          @addChild @_itemInfo.mode, @_selectedItemZIndex

          @_itemInfo.icon = new cc.Sprite res.highWhiteImage
          @_itemInfo.icon.attr
            x : 180
            y : size.height / 2 +5            
            scale: 0
            @_itemInfo.icon.setAnchorPoint cc.p(0,1)
            @addChild @_itemInfo.icon, @_selectedItemZIndex

          @_itemInfo.highScore  = new cc.LabelTTF "0", "Arial", 11, cc.size(0,0), cc.TEXT_ALIGNMENT_LEFT
          @_itemInfo.highScore.attr
            x : 198
            y : size.height / 2 
            scale: 0

          @_itemInfo.highScore.setColor cc.color(255, 255, 255, 255)
          @addChild @_itemInfo.highScore, @_selectedItemZIndex
    
          @_itemInfo.level = new cc.Sprite res.starWhite
          @_itemInfo.level.attr
            x : 109
            y : size.height / 2 -12
            opacity: 255
            scale: 0

          @addChild @_itemInfo.level, @_selectedItemZIndex

        if target.info.mode is "normal" then @_itemInfo.mode.initWithFile res.normalImage
        else if target.info.mode is "another" then @_itemInfo.mode.initWithFile res.anotherImage

        highScore = if sys.localStorage.getItem target.info.id? then sys.localStorage.getItem  target.info.id else 0
        @_itemInfo.highScore.setString highScore

        
        @_itemInfo.level.initWithFile res.starWhite, cc.rect(0, 0, 19*target.info.level, 18)
        @_itemInfo.level.setAnchorPoint cc.p(0,1)
        @_itemInfo.mode.setAnchorPoint cc.p(0,1)

        text = """
          #{target.info.title}
          #{target.info.artist}
          #{target.info.license}
        """
        
        @_itemInfo.setString text
        @_itemInfo.setColor cc.color(255,255,255,255)
        @_itemInfo.runAction cc.spawn(cc.fadeIn(0.3), cc.scaleTo(0.3, 1))
        @_itemInfo.level.runAction cc.spawn(cc.fadeIn(0.3), cc.scaleTo(0.3, 0.6))
        @_itemInfo.mode.runAction cc.spawn(cc.fadeIn(0.3), cc.scaleTo(0.3, 0.6))
        @_itemInfo.highScore.runAction cc.spawn(cc.fadeIn(0.3), cc.scaleTo(0.3, 1))
        @_itemInfo.icon.runAction cc.spawn(cc.fadeIn(0.3), cc.scaleTo(0.3, 0.16))
        
        target.runAction(
          cc.sequence(
            cc.spawn(
              cc.moveTo(0.2, size.width / 2 - 100, size.height / 2 + 30)
              cc.scaleTo(0.2, 0)
            )
            cc.scaleTo(0.2, 1)
          )
        )

        closeToucheventListener = cc.EventListener.create
          event: cc.EventListener.TOUCH_ONE_BY_ONE
          swallowTouches: true
          onTouchBegan: @_onTouchBeganClose.bind(@)

        if not @_closeButton?
          @_closeButton = new cc.Sprite res.closeButtonImage
          @_closeButton.attr
            x : size.width - 40
            y : size.height - 40

          cc.eventManager.addListener closeToucheventListener.clone(), @_closeButton
          @addChild @_closeButton, @_closeButtonZIndex
        @_closeButton.runAction cc.fadeIn(0.3)

        enterToucheventListener = cc.EventListener.create
          event: cc.EventListener.TOUCH_ONE_BY_ONE
          swallowTouches: true
          onTouchBegan: @_onTouchBeganEnter.bind(@)

        if not @_enterButton?
          @_enterButton = new cc.Sprite(res.playButton)
          @_enterButton.attr
            x : size.width / 2
            y : size.height / 2 -60
            opacity : 0
            scale : 0

          cc.eventManager.addListener enterToucheventListener.clone(), @_enterButton
          @addChild @_enterButton, @_enterButtonZIndex
        @_enterButton.runAction cc.spawn(cc.fadeIn(0.3), cc.scaleTo(0.3, 1))
      return true
    return false

  _gameStart : ->
    game = new gameScene()
    game.init @_shownMusicItem[@_selected].info
    @_selected = null
    cc.director.runScene game

  _onTouchBeganPager : (touch, event) ->
    target = event.getCurrentTarget()
    locationInNode = target.convertToNodeSpace touch.getLocation()
    s = target.getContentSize()
    rect = cc.rect(0, 0, s.width, s.height)
    if (cc.rectContainsPoint(rect, locationInNode))
      # タッチ時の処理
      if target.sequence is "next"
        if @_showPageNum < @_maxPageNum then @_showPageNum++ else return
      else
        if @_showPageNum > 0 then @_showPageNum-- else return
      for value in @_shownMusicItem
        value.runAction(
          cc.sequence(
            cc.spawn(cc.fadeOut(0.3), cc.scaleTo(0.3, 0))
            cc.CallFunc.create(()->
              @removeChild(value)
            @)
          )
        )
        value.title.runAction(
          cc.sequence(
            cc.fadeOut(0.3)
            cc.CallFunc.create(()->
              value.title.opacity = 0
              @removeChild(value.title)
            @)
          )
        )
      setTimeout ()=>
        @_shownMusicItem = []
        @_showMusicItem(@_showPageNum)
      , 500
      return true
    return false

  _onTouchBeganClose : (touch, event) ->
    target = event.getCurrentTarget()
    locationInNode = target.convertToNodeSpace(touch.getLocation())
    s = target.getContentSize()
    rect = cc.rect(0, 0, s.width, s.height)
    if cc.rectContainsPoint(rect, locationInNode)
      # タッチ時の処理
      @_selected = null
      @_closeButton.runAction cc.fadeOut(0.3)
      @_blackBackground.runAction cc.fadeOut(0.3)
      #@_itemInfo.runAction cc.sequence(cc.fadeOut(0.3))
      @_enterButton.runAction cc.sequence(cc.spawn(cc.fadeOut(0.3), cc.scaleTo(0.3, 0)))
      @_itemInfo.runAction cc.spawn(cc.fadeOut(0.3), cc.scaleTo(0.3, 0))
      @_itemInfo.mode.runAction cc.spawn(cc.fadeOut(0.3), cc.scaleTo(0.3, 0))
      @_itemInfo.level.runAction cc.spawn(cc.fadeOut(0.3), cc.scaleTo(0.3, 0))
      @_itemInfo.highScore.runAction cc.spawn(cc.fadeOut(0.3), cc.scaleTo(0.3, 0))
      @_itemInfo.icon.runAction cc.spawn(cc.fadeOut(0.3), cc.scaleTo(0.3, 0))
      
      for value,i in @_shownMusicItem
        value.runAction cc.scaleTo(0.2, 1)
        value.title.runAction cc.scaleTo(0.2, 1)
        value.artist.runAction cc.scaleTo(0.2, 1)        
        value.mode.runAction cc.scaleTo(0.2, 0.6)
        value.level.runAction cc.scaleTo(0.2, 0.5)
      #@_nextButton.runAction(cc.scaleTo(0.2, 1))
      #@_previousButton.runAction(cc.scaleTo(0.2, 1))
      for value,i  in @_shownMusicItem when value.hasSelected
        value.hasSelected = false
        value.runAction(
          cc.sequence(
            cc.spawn(
              cc.scaleTo(0.2, 0)
              cc.moveTo(0.2, value.origin.x, value.origin.y)
            )
            cc.scaleTo(0.2, 1)
          )
        )

      return true
    return false

  _onTouchBeganEnter : (touch, event) ->
    target = event.getCurrentTarget()
    locationInNode = target.convertToNodeSpace(touch.getLocation())
    s = target.getContentSize()
    rect = cc.rect(0, 0, s.width, s.height)
    if cc.rectContainsPoint(rect, locationInNode)
      # タッチ時の処理
      for value in @_shownMusicItem
        value.runAction(
          cc.sequence(
            cc.spawn(cc.fadeOut(0.3), cc.scaleTo(0.3, 0))
          )
        )
        value.title.runAction(cc.sequence(cc.fadeOut(0.3)))
      @schedule @_gameStart, 0.5

      @_itemInfo.runAction cc.sequence(cc.fadeOut(0.3))
      @_itemInfo.mode.runAction cc.sequence(cc.fadeOut(0.3))
      @_itemInfo.highScore.runAction cc.sequence(cc.fadeOut(0.3))
      @_itemInfo.icon.runAction cc.sequence(cc.fadeOut(0.3))
      @_itemInfo.level.runAction cc.sequence(cc.fadeOut(0.3))      
      @_enterButton.runAction cc.spawn(cc.fadeOut(0.3), cc.scaleTo(0.3, 0))
      return true
    return false


@menuScene = cc.Scene.extend
  onEnter: ->
    @_super()
    layer = new menu()
    layer._init()
    cc.director.setContentScaleFactor(2)
    @addChild(layer, 0)
    return

