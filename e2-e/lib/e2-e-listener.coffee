module.exports =
class E2EListener
  constructor: ->
    # console.log 'Creating...'
    @host = atom.config.get('e2e-remote.host') or 'localhost'
    @port = atom.config.get('e2e-remote.port') or 4333

  start: ->
    @io = require 'socket.io-client'

    console.log 'Connecting...'

    @socket = @io.connect('http://localhost:4333', {resource : 'node_modules/socket.io'})

    @socket.on 'status', (data) ->
      updateStatus(editor,data) for editor in atom.workspace.getEditors()
      # @socket.emit 'pause', 'Msg!!!'
      return

    atom.commands.add 'atom-workspace', "E2E:pauseScenario", => @pauseScenario()
    atom.commands.add 'atom-workspace', "E2E:resumeScenario", => @resumeScenario()
    atom.commands.add 'atom-workspace', "E2E:cancelScenario", => @cancelScenario()

  pauseScenario: ->
    @socket.emit 'pause'

  resumeScenario: ->
    @socket.emit 'resume'

  cancelScenario: ->
    @socket.emit 'cancel'

  updateStatus = (editor, resp) ->
    # console.log 'updateStatus()', editor.getPath(), resp
    if editor.getPath() == resp.filePath
      if resp.status == 'false' || resp.status == 'true'
        # Clear markers... in 1.5 seconds
        clearAllMarkersEventually(editor)
      else
        if resp.lineNumber < 1
          clearAllMarkersEventually(editor)
          console.log 'Warning: invalid lineNumber via ', resp
          return;

        clearAllMarkersNow(editor)  # Remove previous marker (hammer/nut)

        marker = editor.markBufferRange editor.getBuffer().rangeForRow( resp.lineNumber - 1), invalidate: 'never', e2eStatusMarker: true
        editor.decorateMarker marker, type: 'gutter', class: 'e2e-gutter'
        editor.decorateMarker marker, type: 'highlight', class: 'e2e-highlight'
        # editor.decorateMarker marker, type: 'line', class: 'e2e-highlight'
        # console.log 'Got match', marker
    else
      # console.log 'NO MATCH', editor.getPath(), resp

  clearAllMarkersNow = (editor) ->
    m.destroy() for m in editor.findMarkers e2eStatusMarker: true
    return

  clearAllMarkersEventually = (editor) ->
    setTimeout ->
      clearAllMarkersNow(editor)
    , 1500
    return

  stop: ->
    console.log 'Stopping...'
    @socket.disconnect()
