Application = require '../../framework/application'
ModelManager = require  '../../framework/model_manager'

InnerPageView = require './views/inner_page_view'
InnerPageModel = require './models/inner_page_model'

CommonInit = require  '../../common_init'

class InnerPageApp extends Application
	constructor: (params)->

		@model = ModelManager.getModel InnerPageModel, params
		@view = new InnerPageView()

		#example of using submodules
		MenuApp = CommonInit.getModule 'MenuApp'
		@addSubmodule 'menu', new MenuApp active: params.id

		super params

module.exports = InnerPageApp