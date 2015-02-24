CollectionView = require '../../../framework/collection_view'
MenuItemView = require './menu_item_view'

class MenuView extends CollectionView
	templateName: 'pages:menu'
	itemViewType: MenuItemView
	events:
		"init": "init"

	init: ()->

	appendElement: (data, model, itemView, collection)->
		$elem = $(data)
		$elem.appendTo @context
		context = @context.find '[data-'+model.getIdName()+'][data-'+model.getIdName()+'="'+model.getId()+'"]'
		if context.size()
			itemView.setContext context
			itemView.bindEvents()

module.exports = MenuView