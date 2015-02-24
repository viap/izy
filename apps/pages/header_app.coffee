Application = require '../../framework/application'
ModelManager = require  '../../framework/model_manager'

HeaderView = require './views/header_view'
HeaderModel = require './models/header_model'

CommonInit = require  '../../common_init'

class HeaderApp extends Application
	constructor: (params)->

		@model = ModelManager.getModel HeaderModel, params
		@view = new HeaderView()

		#example of using submodules
		#SubModuleName = CommonInit.getModule('SubModuleName')
		#@addSubmodule 'submodule_region', new SubModuleName()

		super params

module.exports = HeaderApp