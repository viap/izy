#Utils = require '../../../framework/utils'
View = require '../../../framework/view'
RequestManager = require '../../../framework/request_manager'

class ConstructorView extends View
	templateName: 'main:constructor'
	events:
		"init": "init"
		"click .js-test": 'getPaths'
		"submit .constructor-form": "validateForm"

	init: ()->
		@getPaths()

	getPaths: ()->
		RequestManager.get '/server/getAppsPaths/',(err, data)=>
			data = JSON.parse data if _.isString data
			_.each data, (path)=>
				@context.find('#modulePath').append('<option name="'+path+'">'+path+'</option>')

	validateForm:(events, form)->
		moduleName = form.find('input[name="moduleName"]').val();
		regexp = /^[a-z0-9_\-]+$/i

		if regexp.test moduleName
			@createModule()
		else
			if moduleName.length
				@context.find('.constructor-message').html 'Вводи только английские буквы, цифры, тире и подчеркивания!'
			else
				@context.find('.constructor-message').html 'Название введи, а!'

	createModule:()->
		paramsArray = @context.find('#constructorForm').serializeArray()
		params = {}
		_.each paramsArray,(param)->
			params[param.name] = param.value

		RequestManager.get '/server/createModule/', data: params,(err, data)=>
			if ! err && data && ! _.isUndefined data.error

				switch data.error
					when 0 then (()=>
							@context.find('[name=moduleName]').val ''
							@context.find('.constructor-message').html 'Модуль "'+params.modulePath+'/'+params.moduleName+'" создан!'
						)(); break
					when 1 then (()=>
							@context.find('.constructor-message').html 'Модуль "'+params.modulePath+'/'+params.moduleName+'" не создан :-('
						)(); break
					when 2 then (()=>
							@context.find('.constructor-message').html 'Модуль "'+params.modulePath+'/'+params.moduleName+'" уже существует!'
						)(); break

module.exports = ConstructorView