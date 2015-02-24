fs = require 'fs'
ejs = require 'ejs'
async = require 'async'

moment = require 'moment'
moment.locale 'ru'

config = require '../../config'

Event = require './../event'
Utils = require './../utils'
BaseRenderer = require './../base_renderer'
TemplateManager = require './../template_manager'

Application = require  './../application'

# template includes begin
includes =
	moment: moment
	Utils: Utils
# template includes end

# abstract class for server rendering
class ServerRenderer extends BaseRenderer

	# should be overriden in derived class
	# context:
	# 	send: (data) ->
	# 		console.log data

	# should be overriden in derived class
	submodules: {}

	# should be overriden in derived class
	model: null
	view: null

	prepare: (regionsData, callback) ->
		#console.log 'Preparing result...'
		#console.log regionsData

		tasks = {}

		if _.isEmpty(@model) == false
			# function to fetch model
			#tasks.push _.bind(@model.fetch, @model)
			tasks.model = _.bind @model.fetch, @model

		if _.isEmpty(@submodules) == false
			# tasks to prepare submodules
			subTasks = {}

			_.each @submodules, (module, region)->
				subTasks[region] = _.bind module.prepare, module, regionsData

			# function to prepare all submodules in parallel
			tasks.submodules = (cb) -> async.parallel subTasks, cb

		async.series tasks, (err, data) =>
			if err
				callback err, null
				return

			data.regionsData = regionsData

			@_prepareCurrent data, callback

	_prepareCurrent: (data, callback) ->
		#console.log 'Prepare current'
		# prepare current after all subrendering done
		templateName = @view.templateName

		TemplateManager.getTemplate templateName, (err, template) =>
			if err
				callback err, null
				return

			options = {} # filename: templateName

			if Utils.isCollection @model

				showParams = region: @getRegion(), type: @getName()
				tasksCollection = {}

				_.each @model.getListForRender(), (itemModel, iterator)=>
					itemView = @view.add itemModel
					itemRenderer = new ServerRenderer()
					itemRenderer.view = itemView
					itemRenderer.model = itemModel
					itemRenderer.setRegion showParams.region + '_item'

					tasksCollection[ iterator ] = (cb)=>
						itemRenderer._prepareCurrent {model: itemModel, isCollectionItem: true, collectionItemType: showParams.type + '_item', collectionItemRegion: showParams.region + '_item'}, cb

				async.parallel tasksCollection, (err, collection_data) =>
					if err
						console.log 'ERROR: '+ err
						return

					# listContent - collection html
					listContent = ''
					_.each collection_data, (elementHTML)->
						listContent += elementHTML

					# @model - fetched model
					# data.submodules - submodules html
					# data.regionsData - regions data

					attributes = @model && @model.getAttributes && @model.getAttributes()
					_.extend options, attributes, data.submodules, data.regionsData, { moduleName: @getName(), moduleRegion: @getRegion(), listContent: listContent, model : @model }, includes

					try
						html = template options
					catch e
						html = @getErrorHtml e, options
						showParams.error = true

					result = Utils.insertDataAttrs html, showParams

					#console.log 'Success collection rendering: ' + @getRegion()

					callback null, result
			else

				showParams = {}
				if @model.getIdName()
					showParams.idName = @model.getIdName()
					showParams[@model.getIdName()] = @model.getId()
				if data.isCollectionItem
					showParams.type = data.collectionItemType if data.collectionItemType
					showParams.region = data.collectionItemRegion if data.collectionItemRegion
				else
					showParams.type = @getName()
					showParams.region = @getRegion()

				# @model - fetched model
				# data.submodules - submodules html
				# data.regionsData - regions data

				attributes = @model && @model.getAttributes && @model.getAttributes()
				_.extend options, attributes, data.submodules, data.regionsData, { moduleName: @getName(), moduleRegion: @getRegion() }, includes

				try
					html = template options
				catch e
					html = @getErrorHtml e, options
					showParams.error = true

				result = Utils.insertDataAttrs html, showParams
				#result = template options

				#console.log 'Success module rendering: ' + @getRegion()

				callback null, result

	render: (regionsData, callback) ->

		@prepare regionsData, (err, result) =>

			if err
				callback err, null if callback
				@view.show null, err
				return

			@view.show null, result

			callback null, result if callback

module.exports = ServerRenderer
