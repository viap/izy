View = require '../../../framework/view'

class HeaderView extends View
	templateName: 'pages:header'
	events:
		"init": "init"

	init: ()->

module.exports = HeaderView
