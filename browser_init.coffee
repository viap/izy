config = require './config'
commonInit = require './common_init'
Event = require './framework/event'
Router = require './framework/router'
RequestManager = require './framework/request_manager'
User = null

exports.init = ->
	modules = commonInit.init window
	userApp = commonInit.getModule 'UserApp'
	User = new userApp()

	$(document).on 'AppsLoaded', (e, apps) ->
		User.initUser() if User
		Router.meta = {}
		_.each apps, (appInfo) ->

			params = _.extend {}, appInfo.params, appInfo.queryData

			appClass = modules[appInfo.className]
			app = new appClass params

			if app.meta
				Router.meta[appInfo.className] = app.meta

			$context = $("[data-region=\"" + appInfo.regionName + "\"]").first()
			app.init context: $context, name: appInfo.regionName

	$(document).on "setMainMeta", (e, metaData)->
		Router.meta['MainApp'] = metaData

	$(document).on "click", 'a[href!=""]', (event)->
		Router.goToUrl event, $(this).attr "href"

	$(document).on 'ready', ()->
		Event::trigger 'ready'
		moment.locale 'ru'

	$(document).on 'scroll', ()->
		Event::trigger 'scroll'

	$(window).on 'resize', ()->
		Event::trigger 'resize'

	#history prev click
	$(window).on "popstate", ()->
		Event::trigger "go_to_url"