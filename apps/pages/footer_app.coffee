Application = require '../../framework/application'
ModelManager = require  '../../framework/model_manager'

FooterView = require './views/footer_view'
FooterModel = require './models/footer_model'

CommonInit = require  '../../common_init'

class FooterApp extends Application
	constructor: (params)->

		@model = ModelManager.getModel FooterModel, params
		@view = new FooterView()

		#example of using submodules
		#SubModuleName = CommonInit.getModule('SubModuleName')
		#@addSubmodule 'submodule_region', new SubModuleName()

		super params

module.exports = FooterApp