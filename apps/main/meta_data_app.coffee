Application = require '../../framework/application'
ModelManager = require  '../../framework/model_manager'

MetaDataView = require './views/meta_data_view'
MetaDataModel = require './models/meta_data_model'

CommonInit		= require  '../../common_init'

class MetaDataApp extends Application
	constructor: (params)->

		@model = ModelManager.getModel MetaDataModel, params
		@view = new MetaDataView()

		#example of the use of submodules
		#SubModuleName = CommonInit.getModule('SubModuleName')
		#@addSubmodule 'submodule_region', new SubModuleName()

		super params

module.exports = MetaDataApp