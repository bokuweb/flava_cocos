@Note = cc.Sprite.extend(
  tmpWidth:0
  tmpHeight:0
  animation:null

  ctor:->
    pFrame = cc.spriteFrameCache.getSpriteFrame("note01.png")
    @_super(pFrame)
    @setBlendFunc(cc.SRC_ALPHA, cc.ONE)
    @tmpWidth = @width
    @tmpHeight = @height
    @animation = cc.animationCache.getAnimation("Note")
    cc.log "run"

  play:->
    @runAction(cc.animate(@animation))
)
