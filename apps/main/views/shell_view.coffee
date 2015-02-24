View = require '../../../framework/view'

class ShellView extends View
	templateName: 'main:shell'
	events:
		"init": "init"

	init: ()->

module.exports = ShellView
