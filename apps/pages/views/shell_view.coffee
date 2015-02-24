View = require '../../../framework/view'

class ShellView extends View
	templateName: 'pages:shell'
	events:
		"init": "init"

	init: ()->

module.exports = ShellView
