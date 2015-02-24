Application = require '../../framework/application'
ModelManager = require  '../../framework/model_manager'

DefaultFooterView = require './views/default_footer_view'
DefaultFooterModel = require './models/default_footer_model'

CommonInit = require  '../../common_init'

class DefaultFooterApp extends Application
	constructor: (params)->

		@model = ModelManager.getModel DefaultFooterModel, params
		@view = new DefaultFooterView()

		#example of using submodules
		#SubModuleName = CommonInit.getModule('SubModuleName')
		#@addSubmodule 'submodule_region', new SubModuleName()

		super params

module.exports = DefaultFooterApp