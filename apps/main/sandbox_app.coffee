Application       = require '../../framework/application'
ModelManager      = require '../../framework/model_manager'
CommonInit        = require '../../common_init'

SandboxView      = require './views/sandbox_view'
EmptyModel	     = require '../common/models/empty_model'

CommonInit		= require  '../../common_init'

class SandboxApp extends Application
	constructor: (params)->

		@view = new SandboxView()
		@model = ModelManager.getModel EmptyModel, params

		modules = []
		@model.set({modules: modules})

		super params

module.exports = SandboxApp