CollectionView = require '../../../framework/collection_view'
[ModuleName]ItemView = require './[module_name]_item_view'

class [ModuleName]View extends CollectionView
	templateName: '[module_path]:[module_name]'
	itemViewType: [ModuleName]ItemView
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

module.exports = [ModuleName]View