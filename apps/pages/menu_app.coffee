Application = require '../../framework/application'
ModelManager = require  '../../framework/model_manager'

MenuView = require './views/menu_view'
MenuModel = require './models/menu_model'

CommonInit = require  '../../common_init'

class MenuApp extends Application
	constructor: (params)->

		@model = ModelManager.getModel MenuModel, params
		@view = new MenuView()

		params = {} if ! params
		params.active = 0 if ! params.active			
			
		@model.setList [
						{ id: 1, name: 'Page-1', active: if params.active == 1 then true else false }
						{ id: 2, name: 'Page-2', active: if params.active == 2 then true else false }
						{ id: 3, name: 'Page-3', active: if params.active == 3 then true else false }
					]
		#example of using submodules
		#SubModuleName = CommonInit.getModule('SubModuleName')
		#@addSubmodule 'submodule_region', new SubModuleName()

		super params

module.exports = MenuApp