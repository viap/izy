config = require '../config'
async = require 'async'
Event = require './event'
Utils = require './utils'
RequestManager = require './request_manager'
UserModel = require '../apps/main/models/user_model'

ModelManager = require './model_manager'


class Router extends Event

	## ============ STATIC ============ ##
	@instance: null
	# global routes array
	@routes: {}
	@wrapperApps:[]
	@modules: null
	# static method for singleton
	@getInstance: ()->
		if ! @instance
			@instance = new Router();
		@instance;

	@meta: null
	## ============ STATIC ============ ##

	constructor: (name) ->
		@name = name
		@

	getRoutes: ()->
		Router.routes

	browserRoute: (route, name, callback)->
		# forbid regular expression
		if !_.isRegExp route
			route = Utils.routeToRegExp route
		if _.isFunction name
			callback = name
			name = ''

		if ! callback
			callback = @[name]

		Backbone.history.route route, (fragment)=>
			args = Utils.extractParameters route, fragment
			if @execute(callback, args, name) != false
				@trigger.apply @, ['route:' + name].concat args
				@trigger 'route', name, args
				Backbone.history.trigger 'route', @, name, args
		@

	_bindBrowserRoutes: (browserRoutes)->
		if ! browserRoutes
			return
		_.each browserRoutes, (calback, route) =>
			@browserRoute route, calback
		return

	execute: (callback, args, name)->
		if (callback)
			callback.call @, args

	addHandler: (path, rootApp, region, handlerApp) ->

		if !Router.routes[path]
			Router.routes[path] =
				regexp: Utils.routeToRegExp path
				rootApp: rootApp
				handlers: {}

		if rootApp != Router.routes[path].rootApp
			console.log 'ERROR IN ROUTE:'
			console.log path
			console.log rootApp
			console.log region
			console.log handlerApp
			console.log 'ROUTE SKIPPED!!!'
			return

		if Router.wrapperApps.indexOf( rootApp.getName() ) < 0
			Router.wrapperApps.push rootApp.getName()

		Router.routes[path].handlers[region] = handlerApp

	start: (context) ->
		if config.isBrowser() == true
			@startBrowser context
		else
			@startNode context

	correctUrl: (url)->
		queryPos = url.indexOf '?'
		hashPos = url.indexOf '#'
		if queryPos >= 0
			if url.substr(queryPos-1,1) != '/'
				url = url.substr( 0, queryPos ) + '/' + url.substr( queryPos )
		else if hashPos >= 0
			if hashPos > 0 && url.substr(hashPos-1,1) != '/'
				url = url.substr( 0, hashPos ) + '/' + url.substr( hashPos )
		else if url.substr(url.length-1,1) != '/'
			url = url + '/'
		url

	startNode: (expressApp) ->
		expressApp.use (req, res, next) =>

			hasRoute = false
			currentRoutes = {}
			hierarchy = {}
			@modules = []
			@meta = []
			url = @correctUrl req.url

			# redirect if missing closing /
			if url != req.url
				res.writeHead 302, 'Location': url
				res.end()
				return

			currentRoutes = @_getNodeRoutes url

			#------------------------------------------------
			error404 = true
			_.each currentRoutes, ( route) =>
				_.each route.handlers, ( handler )=>
					if Router.wrapperApps.indexOf( handler.getName() ) < 0
						error404 = false

			# redirect to error 404 page
			if error404
				url = '/errors/404/'
				currentRoutes = @_getNodeRoutes url
			#-------------------------------------------------

			if currentRoutes
				# building hierarchy: start
				_.each currentRoutes, (route, path) =>
					params = Utils.correlateValuesAndNames path, Utils.extractParameters route.regexp, url
					#add GET and POST params
					params = _.extend params, req.query, req.body

					_.each route.handlers, (handler, region)=>

						# current's leaf
						name = handler.getName()
						if ! hierarchy[name]
							hierarchy[name] = {parent:null, children:[], handler: handler, params: params, region: region, route: { path: path } }
						else
							hierarchy[name].params = params if ! hierarchy[name].params
							hierarchy[name].region = region if ! hierarchy[name].region
							hierarchy[name].route = {} if ! hierarchy[name].route
							hierarchy[name].path = path if ! hierarchy[name].path

						# parent's leaf
						rootName = route.rootApp.getName()
						hierarchy[rootName]  = {parent:null, children:[], handler: route.rootApp } if ! hierarchy[rootName]

						if ! hierarchy[name].parent
							hierarchy[name].parent = hierarchy[rootName] # route.rootApp
							hierarchy[rootName].children.push hierarchy[name] #handler
				# building hierarchy: stop

				console.log 'SERVER MODULES HIERARCHY:'
				#console.log hierarchy
				#return

				@hierarchyRender hierarchy['MainApp'], ( err, module, data )=>
					if err
						res.send 'TODO: Error handling templates ' + err
						return

					@meta.push module.meta
					metaData = {}

					_.each @meta, (tags)=>
						_.each tags, (attrs, name)=>
							metaData[name] = attrs if ! metaData[name]

					module.setMeta metaData
					module.startOnBrowser @modules
					module.setViewContext res
					module.render data, ()=>
						hierarchy = null
						currentRoutes = null
						Router.instance = null
						ModelManager.clear()
						Event::clear()
						console.log 'MEMORY USAGE: '+ process.memoryUsage().heapUsed
						res.end()
			else
				next()

	_getNodeRoutes: (url)->
		hasRoute = false
		currentRoutes = {}
		_.each Router.routes, (route, path) =>
			if route.regexp.test url
				currentRoutes[path] = route
				hasRoute = true

		if hasRoute
			currentRoutes
		else
			false


	hierarchyRender: ( hierarchyItem, callback )->

		tasks = {}
		regions = {}

		_.each hierarchyItem.children, ( childItem )=>
			if ! regions[ childItem.region ]
				regions[ childItem.region ] = childItem
			else
				regions[ childItem.region ] = @_determineAppropriateChild childItem, regions[ childItem.region ]

		_.each regions, ( childItem )=>
			tasks[ childItem.region ] = ( cb )=>
				@hierarchyRender( childItem, cb )

		async.parallel tasks, (err, data) =>

			if err
				console.log 'TODO: Error handling'
				return

			module = new hierarchyItem.handler( hierarchyItem.params )
			module.setRegion hierarchyItem.region

			if _.isEmpty hierarchyItem.parent
				callback err, module, data
			else
				@modules.push module
				module.prepare data, ()=>
					# meta
					@meta.push module.meta
					callback.apply @, arguments

	_determineAppropriateChild: ( child1, child2 )->
		if _.keys( child1.params ).length > _.keys( child2.params ).length
			return child1
		else if _.keys( child1.params ).length < _.keys( child2.params ).length
			return child2

		if child1.route.path.lastIndexOf('/') > child2.route.path.lastIndexOf('/')
			return child1
		else if child1.route.path.lastIndexOf('/') < child2.route.path.lastIndexOf('/')
			return child2

		if child1.children.length > 0 and child2.children.length == 0
			return child1
		if child2.children.length > 0 and child1.children.length == 0
			return child2

		return child1

	startBrowser: (window) ->
		$(document).ready =>
			console.log "start browser"

			@meta = {}
			backboneRoutes = {}
			# --------------------------------------------------------------------------------------
			hierarchy = {}
			hierarchyPaths = 'MainApp': [ { path: '/*', regExp: new RegExp '^\/(.*?)$' } ]

			_.each Router.routes, (route, path) =>
				_.each route.handlers, (handler, region)=>

					name = handler.getName()
					hierarchyPaths[name] = [] if ! hierarchyPaths[name]

					#if ! hierarchyPaths[name][path]
					#	hierarchyPaths[name][path] = route.regexp
					hierarchyPaths[name].push path: path, regExp: route.regexp
			# --------------------------------------------------------------------------------------------

			_.each Router.routes, (route, path)=>
				_.each route.handlers, (handler, region)=>

					# current's leaf
					name = handler.getName()
					hierarchy[name] = {} if ! hierarchy[name]

					if ! hierarchy[name][path]
						hierarchy[name][path] = parent:null, children:[], handler: handler, instance: null, notRender: false, params: {}, region: region, route: { path: path, regexp: route.regexp }
					else
						hierarchy[name][path].params = {} if ! hierarchy[name][path].params
						hierarchy[name][path].region = region if ! hierarchy[name][path].region

					# parent's leaf
					rootName = route.rootApp.getName()
					if( rootRoute = _.find hierarchyPaths[ rootName ], (route)-> route.regExp.test path )
						hierarchy[rootName] = {} if ! hierarchy[rootName]
						hierarchy[rootName][rootRoute.path]  = {parent:null, children:[], handler: route.rootApp, instance: null, notRender: false } if ! hierarchy[rootName][rootRoute.path]

						if ! hierarchy[name][path].parent
							hierarchy[name][path].parent = hierarchy[rootName][rootRoute.path]
							hierarchy[rootName][rootRoute.path].children.push hierarchy[name][path]

			#return

			#console.log 'CLIENT MODULES HIERARCHY:'
			#console.log hierarchy
			# --------------------------------------------------------------------------------------

			_.each Router.routes, (route, path) =>#client
				backboneRoutePath = path.substring 1 if path[0] == '/'

				backboneRoutes[ backboneRoutePath ] = (params) =>

					_.each route.handlers, (handler, region) =>

						# redirect to error 404 page
						if Router.wrapperApps.indexOf( handler.getName() ) >= 0
							Backbone.history.loadUrl Backbone.history.getFragment '/errors/404/'
							return

						renderStart = @_findRenderStart hierarchy[handler.getName()][path]

						@_renderBranch renderStart, ()=>
							data_arr = _.sortBy $('[data-type]'), (item)-> $(item).parents(["data-type"]).size()
							types = _.map data_arr, (item)-> $(item).attr "data-type"
							modules = _.uniq types
							curMeta = {}
							_.each modules, (moduleName) =>
								_.extend(curMeta, @meta[moduleName]) if @meta[moduleName]

							Utils.setMetaOnBrowser curMeta

			@_bindBrowserRoutes  backboneRoutes
			Backbone.history.start { pushState: true, silent: true }

	# checks need to reload module
	_unChangingElement: ( renderElement )->
		if renderElement.region and renderElement.handler.getName()
			$renderElement = $("[data-region=\"#{renderElement.region}\"][data-type=\"#{renderElement.handler.getName()}\"]")
			if $renderElement.size() == 0
				return false
			else
				idName = $renderElement.attr 'data-idName'
				if idName
					url = '/' + Backbone.history.fragment #document.location.pathname + document.location.search + document.location.hash
					params = Utils.correlateValuesAndNames renderElement.route.path, Utils.extractParameters renderElement.route.regexp, url
					if params[idName] != $renderElement.attr('data-'+idName)
						return false
		return true

	# looks for the first reloadable module
	_findRenderStart: (renderStart)->
		result = renderStart
		curElement = renderStart

		while curElement.parent
			if ! @_unChangingElement curElement.parent
				result = curElement.parent
			curElement = curElement.parent

		if result.parent?.handler && result.parent.children?.length
			result = result.parent
			#if ! result.region or $('[data-region="'+result.region+'"]').size() == 1 and $('[data-region="'+result.region+'"]').is(':not([data-error="true"])')
			if result.region and $('[data-region="'+result.region+'"][data-error="true"]').size()
				result.notRender = false
			else
				result.notRender = true

		return result

	_renderBranch: (renderStart, callback)->

		url = '/' + Backbone.history.fragment #document.location.pathname + document.location.search + document.location.hash
		tasksEmpty = {}
		tasksFull = {}
		regions = {}

		_.each renderStart.children, ( childItem )=>
			#if( route = _.find childItem.routes, (route)-> route.regexp.test url )
			if childItem.route.regexp.test url
				if ! regions[ childItem.region ]
					regions[ childItem.region ] = childItem
				else
					regions[ childItem.region ] = @_determineAppropriateChild childItem, regions[ childItem.region ]

		_.each regions, ( childItem )=>
			if ! childItem.instance
				params = Utils.correlateValuesAndNames childItem.route.path, Utils.extractParameters childItem.route.regexp, url
				getParams = Utils.getSearchParameters()
				_.extend params, getParams

				childItem.instance = new childItem.handler params

			tasksEmpty[ childItem.region ] = ( cb )=>
				childItem.instance.getEmptyHtml childItem.region, cb

			tasksFull[ childItem.region ] = ( cb )=>
				@_renderBranch childItem, (err, data)->
											childItem.instance = null
											cb err, data

		if renderStart.notRender != true
			async.parallel tasksEmpty, (err, data) =>

				if err
					console.log 'TODO: Error handling'
					return

				#if( ! renderStart.instance and route = _.find renderStart.routes, (route)-> route.regexp.test url )
				params = Utils.correlateValuesAndNames renderStart.route.path, Utils.extractParameters renderStart.route.regexp, url
				getParams = Utils.getSearchParameters()
				_.extend params, getParams

				renderStart.instance = new renderStart.handler params if ! renderStart.instance

				if renderStart.instance.meta
					@meta[renderStart.handler.getName()] =  renderStart.instance.meta

				renderStart.instance.setRegion renderStart.region
				renderStart.instance.setViewContext $("[data-region=\"#{renderStart.region}\"]").first()

				renderStart.instance.render _.extend( {region: renderStart.region}, data ), (err,data)=>
					async.parallel tasksFull
					renderStart.instance = null
					callback err, data if _.isFunction callback

		else
			async.parallel tasksFull, (err, data)=>
				renderStart.notRender = false
				callback( null, null )  if _.isFunction callback

	goToUrl: ( event, url, options )->
		if config.isBrowser()
			options = true if _.isUndefined( options ) or _.isNull( options )
			cur_url = document.location.pathname+document.location.search + document.location.hash
			if url == cur_url
				return false
			url = Utils.parseUrl url
			if url.host == '' or url.host == document.location.host
				resultUrl = @correctUrl url.relative
				# stopPropogation and preventDefault
				if event.stopPropagation then event.stopPropagation() else event.cancelBubble = true
				if event.preventDefault then event.preventDefault() else event.returnValue = false

				if resultUrl[0] != '#'
					Backbone.history.navigate resultUrl, options
					Event::trigger "go_to_url"
				else
					document.location.hash = resultUrl.slice 1

module.exports = Router.getInstance();