config = require  './config'
Router = require  './framework/router'
RequestManager = require './framework/request_manager'

class CommonInit extends Object

	## ============ STATIC ============ ##
	@instance: null
	@modules: {}
	# static method for singleton
	@getInstance: ()->
		if ! @instance
			@instance = new CommonInit();
		@instance;
	## ============ STATIC ============ ##

	constructor: ()-> @

	init: (context)->
		RequestManager.setDefaultData { platform: 1 }
		@initModules()
		Router.start context
		@getModules()

	getModules: ()->
		CommonInit.modules

	getModule:(name)->
		if CommonInit.modules[name]
			CommonInit.modules[name]
		else
			throw new Error 'Unknown module name: '+name

	initModules: ()->
		CommonInit.modules =
			MainApp:					require './apps/main/main_app'
			ShellApp:					require './apps/main/shell_app'
			UserApp:					require './apps/main/user_app'
			ErrorPageApp:				require './apps/errors/error_page_app'
			SandboxApp:					require './apps/main/sandbox_app'
			ConstructorApp:				require './apps/main/constructor_app'

			ShellApp:					require './apps/pages/shell_app'
			MainContentApp:				require './apps/pages/main_content_app'
			HeaderApp:					require './apps/pages/header_app'
			FooterApp:					require './apps/pages/footer_app'
			MenuApp:					require './apps/pages/menu_app'
			InnerPageApp:				require './apps/pages/inner_page_app'

		@initHandlers()

	initHandlers: (modules)->
			# setup module's routes
			Router.addHandler '/*path',							CommonInit.modules.MainApp,				'content',			CommonInit.modules.ShellApp
			Router.addHandler '/*path2',						CommonInit.modules.ShellApp,			'shell_content',	CommonInit.modules.MainContentApp
			Router.addHandler '/page/:id/*path',				CommonInit.modules.ShellApp,			'shell_content',	CommonInit.modules.InnerPageApp
			
			#Router.addHandler '/errors/:id/*path',				CommonInit.modules.DefaultShellApp,		'content',			CommonInit.modules.ErrorPageApp
			Router.addHandler '/sandbox/(?*q)',					CommonInit.modules.MainApp,				'content',			CommonInit.modules.SandboxApp
			Router.addHandler '/constructor/(?*q)',				CommonInit.modules.MainApp,				'content',			CommonInit.modules.ConstructorApp

module.exports = CommonInit.getInstance();
