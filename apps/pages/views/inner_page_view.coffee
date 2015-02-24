View = require '../../../framework/view'

class InnerPageView extends View
	templateName: 'pages:inner_page'
	events:
		"init": "init"

	init: ()->

module.exports = InnerPageView
