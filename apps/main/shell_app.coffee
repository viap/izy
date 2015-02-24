Application = require '../../framework/application'
ModelManager = require  '../../framework/model_manager'

ShellView = require './views/shell_view'
EmptyModel = require '../common/models/empty_model'

CommonInit = require  '../../common_init'

class ShellApp extends Application
	constructor: (params)->

		@model = ModelManager.getModel EmptyModel, params
		@view = new ShellView()

		#example of the use of submodules
		#SubModuleName = CommonInit.getModule('SubModuleName')
		#@addSubmodule 'submodule_region', new SubModuleName()

		super params

module.exports = ShellApp