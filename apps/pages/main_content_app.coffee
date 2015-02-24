Application = require '../../framework/application'
ModelManager = require  '../../framework/model_manager'

MainContentView = require './views/main_content_view'
MainContentModel = require './models/main_content_model'

CommonInit = require  '../../common_init'

class MainContentApp extends Application
	constructor: (params)->

		@model = ModelManager.getModel MainContentModel, params
		@view = new MainContentView()

		#example of using submodules
		MenuApp = CommonInit.getModule 'MenuApp'
		@addSubmodule 'menu', new MenuApp()

		super params

module.exports = MainContentApp