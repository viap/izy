Application		= require '../../framework/application'
ModelManager	= require '../../framework/model_manager'
CommonInit		= require '../../common_init'

ConstructorView	= require './views/constructor_view'
EmptyModel		= require '../common/models/empty_model'

CommonInit		= require  '../../common_init'

class ConstructorApp extends Application
	constructor: (params)->

		@view = new ConstructorView()
		@model = ModelManager.getModel EmptyModel, params

		super params

module.exports = ConstructorApp