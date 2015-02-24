config = require '../config'
async = require 'async'
fs = require 'fs'
RequestManager = require './request_manager'
ejs = require 'ejs'

class TemplateManager #extends Event
	## ============ STATIC ============ ##
	@instance: null
	@queue: {}
	@templates: {}
	# static method for singleton
	@getInstance: ()->
		if ! @instance
			@instance = new TemplateManager();
		@instance;
	## ============ STATIC ============ ##

	constructor: (name)->
		@name = name

	clear: ()->
		TemplateManager.instance = null
		TemplateManager.queue = {}
		TemplateManager.templates = {}

	getTemplate: (name, callback)->
		#console.log 'TEMPLATE REQUEST: ' + name
		#console.log TemplateManager.templates
		if TemplateManager.templates[name] != undefined
			#console.log 'GET CACHE TEMPLATE: ' + name
			callback null, TemplateManager.templates[name]
		else
			if	TemplateManager.queue[name] == undefined
				#console.log 'CREATE QUEUE: ' + name
				queue = @_createQueue(name)
			else
				#console.log 'EXISTENT QUEUE: ' + name
				queue = TemplateManager.queue[name]

			queue.unshift ( (next)=> @_task( name, callback, next ) ), @_onSuccess


	_createQueue: (name)->
		TemplateManager.queue[name] = async.queue ( worker, next )->
									worker( next )

	_onSuccess: (err)->
		#console.log 'SUCCESS TASK'

	_task: (name, callback, next)->
		if TemplateManager.templates[name] != undefined
			#console.log 'GET CACHE TEMPLATE: ' + name
			next()
			callback null, TemplateManager.templates[name]
		else
			if config.isBrowser()
				@_getTemplateHtml name, (err, template)=>
					#console.log 'GET HTML TEMPLATE: ' + name
					tmp = new ejs.compile template
					TemplateManager.templates[name] = tmp if !err
					next()
					callback err, tmp
			else
				@_getTemplateStr name, (err, template)=>
					#console.log 'GET STR TEMPLATE: ' + name
					tmp = new ejs.compile template
					TemplateManager.templates[name] = tmp if !err
					next()
					callback err, tmp

	_getTemplateStr: (name, callback) ->
		names = name.split ':'
		if names.length != 2
			callback 'incorrect length', null
		fs.readFile "./apps/#{names[0]}/templates/#{names[1]}.ejs", {encoding: 'UTF-8'}, callback

	_getTemplateHtml: (name, callback) ->
		names = name.split ':'
		if names.length != 2
			callback 'incorrect length', null
		RequestManager.get config.server.api + "/apps/#{names[0]}/templates/#{names[1]}", callback

module.exports = TemplateManager.getInstance();