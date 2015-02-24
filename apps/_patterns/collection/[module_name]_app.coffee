Application = require '../../framework/application'
ModelManager = require  '../../framework/model_manager'

[ModuleName]View = require './views/[module_name]_view'
[ModuleName]Model = require './models/[module_name]_model'

CommonInit = require  '../../common_init'

class [ModuleName]App extends Application
	constructor: (params)->

		@model = ModelManager.getModel [ModuleName]Model, params
		@view = new [ModuleName]View()

		#example of using submodules
		#SubModuleName = CommonInit.getModule('SubModuleName')
		#@addSubmodule 'submodule_region', new SubModuleName()

		super params

module.exports = [ModuleName]App