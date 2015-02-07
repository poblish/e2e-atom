E2EListener = require './e2-e-listener'
# {CompositeDisposable} = require 'atom'

module.exports = E2E =
  e2EView: null

  activate: (state) ->
    @e2EView = new E2EListener()
    @e2EView.start()

  deactivate: ->
    console.log "E2E DEactivated"
    @e2EView.stop()

  toggle: ->
    console.log 'E2E was toggled!'
