fs = require 'fs'
#pth = require 'path'

class ServerController

	## ============ STATIC ============ ##
	@instance: null
	@appRoot: 'apps'
	@ptrRoot: 'apps/_patterns'
	@tmpRoot: 'apps/_patterns/_tmp'

	@file_module_single:			'apps/_patterns/single/[module_name]_app.coffee'
	@file_model:					'apps/_patterns/single/models/[module_name]_model.coffee'
	@file_view:						'apps/_patterns/single/views/[module_name]_view.coffee'
	@file_template:					'apps/_patterns/single/templates/[module_name].ejs'

	@file_module_collection:		'apps/_patterns/collection/[module_name]_app.coffee'
	@file_collection:				'apps/_patterns/collection/models/[module_name]_model.coffee'
	@file_collection_item:			'apps/_patterns/collection/models/[module_name]_item_model.coffee'
	@file_collection_view:			'apps/_patterns/collection/views/[module_name]_view.coffee'
	@file_collection_item_view:		'apps/_patterns/collection/views/[module_name]_item_view.coffee'
	@file_collection_template:		'apps/_patterns/collection/templates/[module_name].ejs'
	@file_collection_template_item:	'apps/_patterns/collection/templates/[module_name]_item.ejs'

	# static method for singleton
	@getInstance: ()->
		if ! @instance
			@instance = new ServerController();
		@instance;
	## ============ STATIC ============ ##

	createModule:(params, callback)->
		modulePath = ServerController.appRoot+'/'+params.modulePath
		moduleName = params.moduleName+'_app.coffee'

		@_isExistedFile modulePath, moduleName, ( err, exists )=>
			if ! exists

				mn = params.moduleName.charAt(0).toUpperCase() + params.moduleName.slice(1)
				mn = mn.replace /([_\-]+[a-z]{1})/gi, (str, p1) -> p1.slice(-1).toUpperCase()
				m_n = params.moduleName.replace /([_\-]?[A-Z])/g , (str,p1)-> '_' + p1.slice(-1).toLowerCase()

				correlations =
					ModuleName:  mn
					module_name: m_n
					module_path: params.modulePath

				if params.moduleType == 'Single'
					@createSingle params, correlations, callback
				else if params.moduleType == 'Collection'
					@createCollection params, correlations, callback
			else
				callback error: 2

	createSingle:(params, correlations, callback)->
		modulePath = ServerController.appRoot + '/' + params.modulePath

		try
			#module
			file = @_readFile( ServerController.file_module_single )
			file.name = @_replacePlaceholders file.name, correlations
			file.content = @_replacePlaceholders file.content, correlations
			@_writeFile modulePath + '/' + file.name, file.content

			#model
			file = @_readFile( ServerController.file_model )
			file.name = @_replacePlaceholders file.name, correlations
			file.content = @_replacePlaceholders file.content, correlations
			@_writeFile modulePath + '/models/' + file.name, file.content

			#view
			file = @_readFile( ServerController.file_view )
			file.name = @_replacePlaceholders file.name, correlations
			file.content = @_replacePlaceholders file.content, correlations
			@_writeFile modulePath + '/views/' + file.name, file.content

			#template
			file = @_readFile( ServerController.file_template )
			file.name = @_replacePlaceholders file.name, correlations
			file.content = @_replacePlaceholders file.content, correlations
			@_writeFile modulePath + '/templates/' + file.name, file.content

		catch e
			callback error:1, e: e

		callback error:0

	createCollection:(params, correlations, callback)->
		modulePath = ServerController.appRoot + '/' + params.modulePath #ServerController.tmpRoot
		try
			#module
			file = @_readFile( ServerController.file_module_collection )
			file.name = @_replacePlaceholders file.name, correlations
			file.content = @_replacePlaceholders file.content, correlations
			@_writeFile modulePath + '/' + file.name, file.content

			#model_collection
			file = @_readFile( ServerController.file_collection )
			file.name = @_replacePlaceholders file.name, correlations
			file.content = @_replacePlaceholders file.content, correlations
			@_writeFile modulePath + '/models/' + file.name, file.content

			#model_item
			file = @_readFile( ServerController.file_collection_item )
			file.name = @_replacePlaceholders file.name, correlations
			file.content = @_replacePlaceholders file.content, correlations
			@_writeFile modulePath + '/models/' + file.name, file.content

			#view_collection
			file = @_readFile( ServerController.file_collection_view )
			file.name = @_replacePlaceholders file.name, correlations
			file.content = @_replacePlaceholders file.content, correlations
			@_writeFile modulePath + '/views/' + file.name, file.content

			#view_collection_item
			file = @_readFile( ServerController.file_collection_item_view )
			file.name = @_replacePlaceholders file.name, correlations
			file.content = @_replacePlaceholders file.content, correlations
			@_writeFile modulePath + '/views/' + file.name, file.content

			#template
			file = @_readFile( ServerController.file_collection_template )
			file.name = @_replacePlaceholders file.name, correlations
			file.content = @_replacePlaceholders file.content, correlations
			@_writeFile modulePath + '/templates/' + file.name, file.content

			#template_item
			file = @_readFile( ServerController.file_collection_template_item )
			file.name = @_replacePlaceholders file.name, correlations
			file.content = @_replacePlaceholders file.content, correlations
			@_writeFile modulePath + '/templates/' + file.name, file.content
		catch e
			callback error:1, e: e

		callback error:0

	test:(params, callback )->
		#@_copyFile 'apps/_patterns/single/models/single_model.coffee','apps/_patterns/_tmp/single_model2.coffee', (err)-> if err then callback error:1 else callback error: 0
		#callback error:0, file: @_readFile 'apps/_patterns/single/models/[module_name]_model.coffee'

	_replacePlaceholders:(string, correlations)->
		result = string
		_.each correlations, (value, name)=>
			re = new RegExp('\\['+name+'\\]', 'g');
			result = result.replace re, value

		result

	_copyFile: (source, target, cb)->
		cbCalled = false;

		rd = fs.createReadStream source
		rd.on "error", (err)=>
			done err

		wr = fs.createWriteStream target
		wr.on "error", (err)=>
			done err

		wr.on "close", (ex)=>
		  done()

		rd.pipe wr

		done = (err)=>
			if !cbCalled
				cb err
				cbCalled = true

	_readFile:(file)->
		fileName = file.substr(file.lastIndexOf('/')+1)
		fileContent = fs.readFileSync(file, "utf8");

		name: fileName, content: fileContent

	_writeFile: (fileName, fileContent)->
		fs.writeFile fileName, fileContent, (err)=>
			if err
				console.log err
			else
				console.log "The file was saved!"

	getAppsPaths: (params, callback)->
		fs.readdir ServerController.appRoot, (err, data)=>
			count = data.length
			if count
				index = 0
				dirs = []
				_.each data, (path)->
					fs.stat ServerController.appRoot+'/'+path, (err, stat)=>
						index++
						if stat && stat.isDirectory() && path.slice(0,1) != '_'
							dirs.push path

						if index == count
							console.log index, count, dirs
							callback dirs

	_isExistedFile: (path, name, callback)->
		fs.exists path+'/'+name, (exists)->
			if exists
				#console.log 'EXIST: '+path+'/'+name
				callback null, true
			else
				#console.log 'NOT EXIST: '+path+'/'+name
				callback null, false



module.exports = ServerController.getInstance();