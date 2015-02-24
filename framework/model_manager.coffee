config = require '../config'
async = require 'async'
fs = require 'fs'
ejs = require 'ejs'
Utils = require  './utils'

class ModelManager #extends Event
	## ============ STATIC ============ ##
	@instance: null
	@models: {}
	# static method for singleton
	@getInstance: ()->
		if ! @instance
			@instance = new ModelManager();
		@instance;
	## ============ STATIC ============ ##

	constructor: (name)->
		@name = name

	clear: ()->
		ModelManager.instance = null
		ModelManager.models = {}

	getModel: (modelType, params)->

		#console.log 'MODEL REQUEST: ' + modelType.getName()

		if _.isFunction modelType

			if Utils.isCollection modelType
				name = modelType.getName() + ':' + JSON.stringify params
			else
				id = params && params[modelType.idName] || params && params.name || ''
				name = modelType.getName()+':'+id

			if ModelManager.models[name] != undefined
				#console.log 'GET CACHE MODEL: ' + name
				model = ModelManager.models[name]

				# set params for model, but not for collection
				if Utils.isModel modelType
					model.set params
				else if _.isArray(params && params.list) && params.list.length
					idname = model.modelType.idName
					_.each params.list, (attrs)->
						if attrs[idname]
							itemModel = model.get attrs[idname]
							if Utils.isModel itemModel
								itemModel.set attrs
			else
				#console.log 'CREATE MODEL: ' + name
				model = new modelType(params)
				if config.isBrowser()
					ModelManager.models[name] = model

			model

	setModel: ( model )->
		if Utils.isCollection model
			name = model.getName()+':'+JSON.stringify model.getAttributes()
		else if Utils.isModel model
			name = model.getName()+':'+model.getId()

		if name
			ModelManager.models[name] = model
			return true
		else
			return false

module.exports = ModelManager.getInstance()