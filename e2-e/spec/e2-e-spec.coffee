E2E = require '../lib/e2-e'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "E2E", ->
  [workspaceElement, activationPromise] = []

  beforeEach ->
    workspaceElement = atom.views.getView(atom.workspace)
    activationPromise = atom.packages.activatePackage('e2-e')

  describe "when the e2-e:toggle event is triggered", ->
    it "hides and shows the modal panel", ->
      # Before the activation event the view is not on the DOM, and no panel
      # has been created
      expect(workspaceElement.querySelector('.e2-e')).not.toExist()

      # This is an activation event, triggering it will cause the package to be
      # activated.
      atom.commands.dispatch workspaceElement, 'e2-e:toggle'

      waitsForPromise ->
        activationPromise

      runs ->
        expect(workspaceElement.querySelector('.e2-e')).toExist()

        e2EElement = workspaceElement.querySelector('.e2-e')
        expect(e2EElement).toExist()

        e2EPanel = atom.workspace.panelForItem(e2EElement)
        expect(e2EPanel.isVisible()).toBe true
        atom.commands.dispatch workspaceElement, 'e2-e:toggle'
        expect(e2EPanel.isVisible()).toBe false

    it "hides and shows the view", ->
      # This test shows you an integration test testing at the view level.

      # Attaching the workspaceElement to the DOM is required to allow the
      # `toBeVisible()` matchers to work. Anything testing visibility or focus
      # requires that the workspaceElement is on the DOM. Tests that attach the
      # workspaceElement to the DOM are generally slower than those off DOM.
      jasmine.attachToDOM(workspaceElement)

      expect(workspaceElement.querySelector('.e2-e')).not.toExist()

      # This is an activation event, triggering it causes the package to be
      # activated.
      atom.commands.dispatch workspaceElement, 'e2-e:toggle'

      waitsForPromise ->
        activationPromise

      runs ->
        # Now we can test for view visibility
        e2EElement = workspaceElement.querySelector('.e2-e')
        expect(e2EElement).toBeVisible()
        atom.commands.dispatch workspaceElement, 'e2-e:toggle'
        expect(e2EElement).not.toBeVisible()
