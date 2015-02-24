Collection = require '../../../framework/collection'
MenuItemModel = require './menu_item_model'

class MenuModel extends Collection
	name: ''
	urlRoot: null
	modelType: MenuItemModel

module.exports = MenuModel