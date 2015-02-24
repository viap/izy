View = require '../../../framework/view'

class MenuItemView extends View
	templateName: 'pages:menu_item'
	events:
		"init": "init"

	init: ()->

module.exports = MenuItemView
