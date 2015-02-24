Application = require '../../framework/application'
ModelManager = require  '../../framework/model_manager'

ShellView = require './views/shell_view'
ShellModel = require './models/shell_model'

CommonInit = require  '../../common_init'

class ShellApp extends Application
	constructor: (params)->

		@model = ModelManager.getModel ShellModel, params
		@view = new ShellView()

		#example of using submodules
		HeaderApp = CommonInit.getModule 'HeaderApp'
		FooterApp = CommonInit.getModule 'FooterApp'
		
		@addSubmodule 'header', new HeaderApp()
		@addSubmodule 'footer', new FooterApp()

		super params

module.exports = ShellApp