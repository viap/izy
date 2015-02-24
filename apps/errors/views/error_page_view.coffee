View = require '../../../framework/view'

class ErrorPageView extends View
	templateName: 'errors:error_page'
	events:
		"init": "init"

	init: ()->
		@

module.exports = ErrorPageView
