Action = require('ecstasy').Action
assert = require './Assert'

_playerIdCount = 0

class PlayerComponent
  constructor: ({@id, @mouseX, @mouseY, @name}) ->
    @mouseX ?= 0
    @mouseY ?= 0
    @id ?= _playerIdCount++

PlayerAddAction = Action.scaffold (engine) ->
  assert @options?
  assert @options.name?
  @result = engine.e().c('player', @options).id
  
PlayerRemoveAction = Action.scaffold (engine) ->
  engine.removeEntity @player
  for entity in engine.e 'control'
    if entity.c('control').owner == @player.id
      entity.remove 'control'

PlayerMouseAction = Action.scaffold (engine) ->
  assert @player?
  playerComp = @player.c 'player'
  # Pre-check
  assert playerComp
  assert @options?
  assert typeof @options.mouseX == 'number'
  assert typeof @options.mouseY == 'number'
  # Set mouse position of player
  x = @options.mouseX
  y = @options.mouseY
  angle = Math.atan2 y, x
  dist = 2 * Math.min 80, Math.sqrt(y*y + x*x)
  playerComp.mouseX = dist * Math.cos angle
  playerComp.mouseY = dist * Math.sin angle
  @result = true

PlayerAssignAction = Action.scaffold (engine) ->
  assert @options?
  @entity.c 'control',
    owner: @options
  @result = true

module.exports =
  component: PlayerComponent
  mouseAction: PlayerMouseAction
  addAction: PlayerAddAction
  removeAction: PlayerRemoveAction
  assignAction: PlayerAssignAction
