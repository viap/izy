View = require '../../../framework/view'
Router = require '../../../framework/router'
Utils = require '../../../framework/utils'
CommonInit = require '../../../common_init'
ModelManager = require '../../../framework/model_manager'

class SandboxView extends View
	modules: {}
	routes: {}
	templateName: 'main:sandbox'
	events:
		"init": "init"
		"submit .js-sandbox-form": "showModule"
		"change .js-sandbox-module-select": "selectModule"
		"click .js-sandbox-addparam": "addModuleParam"
		"keyup .js-sandbox-paramname": "changeParamName"

	init: ()->

		initParams = @initGetParams()

		preload = false;
		if initParams
			preload = true;

		@modules = CommonInit.getModules()

		modulesNames = _.map CommonInit.getModules(), (value, name)-> name
		modulesNames = modulesNames.sort()

		_.each modulesNames, (name)=>
			attrs = ''
			if name == initParams.name
				attrs = 'selected'
			@context.find('#moduleSelector').append('<option name="'+name+'" '+attrs+'>'+name+'</option>');

		rts = Router.getRoutes()
		_.each rts, (route, path)=>
			_.each route.handlers, (handler, region)=>
				name = handler.getName()
				@routes[name] = {} if ! @routes[name]
				@routes[name][path] = Utils.extractParameters( route.regexp, path )
				#r = Utils.routeToRegExp path
				#m = r.exec path

		if preload
			_.each initParams.params, (value, name)=>
				@addModuleParam(name, value)
			@context.find('#paramsBlock').removeClass('hidden')
			@context.find('#submitBtn').removeClass('hidden')
			@showModule null, @context.find('#sandboxForm')

		console.log 'Sandbox init'

	initGetParams: ()->
		activeModule = null
		activeModuleParams = {}

		params = Utils.getSearchParameters()
		if params.module
			activeModule = params.module
			_.each params, (value, name)=>
				if name.indexOf('params') == 0
					paramName = name.substr 7, name.length - 8
					activeModuleParams[ paramName ] = value

		if(activeModule)
			{ name: activeModule, params: activeModuleParams }
		else
			false


	selectModule: (e, $select)->
		paramsblock = @context.find('#paramsBlock').removeClass('hidden');
		paramsblock.find('.sandbox-line').remove();
		if @routes[ $select.val() ]
			_.each @routes[ $select.val() ], (params, path)=>
				if params.length > 0
					_.each params, (name)=>
						name = Utils.trim name, ':()*'
						paramsblock.find('#addParamButton').before '<div class="sandbox-line"><span class="sandbox-input-name">'+name+'</span><input type="text" name="params['+name+']" value="" class="sandbox-input"/></div>'
					# paramsblock.append '<hr />'

		@context.find('#submitBtn').removeClass('hidden')

	showModule: (e, $form)->
		if _.isObject $form
			moduleName = $form[0].moduleSelector.value
			params = {}
			getParams = []
			$form.find('input[name^="params\["]').each (index, input)->
				name = $(input).attr('name')
				name = name.substr 7, name.length - 8
				if name
					params[name] = $(input).val()
					getParams.push 'params['+name+']='+ $(input).val()

			if @modules[moduleName]
				module = ModelManager.getModel @modules[moduleName], params
				module.setViewContext @getClearContext()
				#name: 'moduleSandbox'
				module.model.loaded false
				module.model.loading false
				module.render null, ()->
					console.log 'success'

				url = '/sandbox/?module='+moduleName
				url += '&'+getParams.join('&') if getParams.length
				@goToUrl e, url, false

	addModuleParam: (name, value)->
		name = '' if ! _.isString name
		value = '' if ! _.isString value
		paramsblock = @context.find('#paramsBlock');
		paramsblock.find('#addParamButton').before '<div class="sandbox-line">
														<input class="sandbox-input-name js-sandbox-paramname" value="'+name+'" />
														<input type="text" name="params['+name+']" value="'+value+'" class="sandbox-input">
													</div>'

	changeParamName:(event, $target)->
		$target.siblings('input.sandbox-input').attr('name','params['+$target.val()+']')


	getClearContext: ()->
		@context.find('[data-region="content"]').html('<div id="emptyBox" data-region="moduleSandbox"></div>').find('#emptyBox')

module.exports = SandboxView