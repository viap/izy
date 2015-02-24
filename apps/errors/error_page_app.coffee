Application = require '../../framework/application'
ModelManager = require  '../../framework/model_manager'

ErrorPageView = require './views/error_page_view'
ErrorPageModel = require './models/error_page_model'

CommonInit		= require  '../../common_init'

class ErrorPageApp extends Application
	constructor: (params)->

		@model = ModelManager.getModel ErrorPageModel, params
		@view = new ErrorPageView()

		#example of using submodules
		#SubModuleName = CommonInit.getModule('SubModuleName')
		#@addSubmodule 'submodule_region', new SubModuleName()

		super params

module.exports = ErrorPageApp