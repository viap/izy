Collection = require '../../../framework/collection'
[ModuleName]ItemModel = require './[module_name]_item_model'

class [ModuleName]Model extends Collection
	name: ''
	urlRoot: null
	modelType: [ModuleName]ItemModel

module.exports = [ModuleName]Model