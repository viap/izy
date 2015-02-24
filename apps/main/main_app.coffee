Application     = require '../../framework/application'
ModelManager    = require  '../../framework/model_manager'
Config 			= require '../../config'
CommonInit		= require  '../../common_init'

MainView        = require './views/main_view'
MainModel       = require './models/main_model'

class MainApp extends Application
	meta : {
		description: {content: "Main App Description"}
		keywords: {content: "Main App keyword"},
		prefix: {content: "Main App Prefix"}
	}
	constructor: ->
		@view = new MainView()
		@model = ModelManager.getModel MainModel

		apps = []
		@model.set 'apps', apps
		@model.set 'metaData', @meta
		
		super

	startOnBrowser: (modules) ->
		apps = @model.get 'apps' || []

		#id need for model init on browser
		_.each modules, (module)=>
			params = {}
			queryData = {}
			if module.model && module.model.getIdName
				params[ module.model.getIdName() ] = module.model.getId()
				queryData = module.model.queryData

			apps.push { className: module.getName(), regionName: module.getRegion(), params: params, queryData: queryData }
			@model.set 'apps', apps, silent: true

	setMeta: (metaObject)->

		#metaToString
		metaStr = ""
		ogMetaStr = ""
		#metaObject.push @meta
		_.each metaObject, (value, key)->
			ogMetaItem = '<meta property="og:'+key+'" content="'+value["content"]+'" class="dynamic_meta"/>'+'\n'
			ogMetaStr += ogMetaItem;
			metaItem = ' <meta name="'+key+'" '
			_.each value, (attrValue, attrKey)->
				metaItem += attrKey+'="'+attrValue+'" class="dynamic_meta"/>'+'\n'
			metaStr+=metaItem
		#metaToString

		@model.set 'meta', ogMetaStr + metaStr

module.exports = MainApp




