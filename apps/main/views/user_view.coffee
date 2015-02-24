View = require '../../../framework/view'

class UserView extends View
	templateName: 'main:user'
	events:
		"init": "init"

	init: ()->

module.exports = UserView
