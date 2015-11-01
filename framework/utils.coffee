Config = require '../config'
class Utils

	@_optionalParam = /\((.*?)\)/g
	@_namedParam    = /(\(\?)?:\w+/g
	@_splatParam    = /\*\w+/g
	@_escapeRegExp  = /[\-{}\[\]+?.,\\\^$|#\s]/g

	# params, optional params, splat param
	@_paramName     = /[^:\*]*(?::|\*)(\w+)[^:\*]*/g
	#/[^:\*\(\)\/]*(\(\/:|\*|:)(\w+)[^:\*\(\)]*/g

	@extractParameters: (route, fragment)->
		fragment = fragment.replace /([\(\)])/g, ''
		params = route.exec fragment
		if params
			params = params.slice 1
			_.map params, (param, i) ->
				result = null
				if i == params.length - 1
					result = param || null;
				else
					result = decodeURIComponent(param) if param
				result

	@correlateValuesAndNames: (path, values)->
		params = {}
		#if values.length
		while match = @_paramName.exec path
			params[ match[1] ] = if values and values.length then values.shift() else undefined

		console.log 'Parse route names of parameters: ' + JSON.stringify params
		params

	@routeToRegExp: (route) ->
		route = route.replace @_escapeRegExp, '\\$&'
					.replace @_optionalParam, '(?:$1)?'
					.replace @_namedParam, (match, optional) ->
						if optional then match else '([^\/]+)'
					.replace @_splatParam, '(.*?)'

		#console.log route
		new RegExp '^' + route + '$';

	@pasteParamsToString: (string, params)->
		if ! _.isString( string ) || !_.isObject( params )
			return

		replacer1 = (match)->
			params[match.slice( 1 )] || ''

		replacer2 = (substr)->
			reg = /[^\w]*(\w+):(\w+)[^\w]*/
			matches = reg.exec substr
			if matches
				'/' + matches[1] + ( params[matches[2]] || '' )
			else
				substr

		string = string.replace @_escapeRegExp, '\\$&'
					.replace @_optionalParam, replacer2
					.replace @_namedParam, replacer1
					.replace @_splatParam, replacer1


	@isModel: (model)->
		if _.isFunction model
			!! model.idName
		else
			!! ( model && model.getIdName )

	@isCollection: (model)->
		if _.isFunction model
			! model.idName
		else
			!! ( model && model.getList )

	@insertDataAttrs: (code, params)->
		attrs = '$&'

		patternTest = /^(?:<%.*%>|<!--.*-->)?\s*<(\w+).*>/
		patternMainTest = /^\s*<!DOCTYPE.*/
		patternReplace = /<\w+(\s*)[^>]*/

		_.each params, (value, key)->
			if !_.isUndefined value && !_.isNull value
				attrs += ' data-'+key+'="'+value+'"'

		if ! patternTest.test(code) && ! patternMainTest.test(code)
			code = '<div >'+code+'</div>'

		code.replace patternReplace, attrs

	@parseUrl: (url)->
		o =
			strictMode: false
			key: ["source","protocol","authority","userInfo","user","password","host","port","relative","path","directory","file","query","anchor"]
			parser:
				strict: /^(?:([^:\/?#]+):)?(?:\/\/((?:(([^:@]*):?([^:@]*))?@)?([^:\/?#]*)(?::(\d*))?))?((((?:[^?#\/]*\/)*)([^?#]*))(?:\?([^#]*))?(?:#(.*))?)/
				loose:  /^(?:(?![^:@]+:[^:@\/]*@)([^:\/?#.]+):)?(?:\/\/\/?)?((?:(([^:@]*):?([^:@]*))?@)?([^:\/?#]*)(?::(\d*))?)(((\/(?:[^?#](?![^?#\/]*\.[^?#\/.]+(?:[?#]|$)))*\/?)?([^?#\/]*))(?:\?([^#]*))?(?:#(.*))?)/

		m = o.parser[ if o.strictMode then "strict" else "loose" ].exec url
		uri = {}
		i = 14

		while i--
			uri[o.key[i]] = m[i] || ""

		uri

	@trim: ( str, charlist )->
		charlist = if !charlist then ' \s\xA0' else charlist.replace /([\[\]\(\)\.\?\/\*\{\}\+\$\^\:])/g, '\$1'
		re = new RegExp '^[' + charlist + ']+|[' + charlist + ']+$', 'g'
		str.replace re, ''

	@getSearchParameters:()->
		prmstr = window.location.search.substr(1)
		if !! prmstr then @toAssocArray(prmstr) else {}

	@toAssocArray:( prmstr )->
		params = {}
		prmarr = prmstr.split("&")
		_.each prmarr, (param)->
			tmparr = param.split "="
			params[tmparr[0]] = tmparr[1]

		params

	@setMetaOnBrowser: (metaObject)->
		$('[data-type="MainApp"] head .dynamic_meta').remove()

		context = $('[data-type="MainApp"] head')
		_.each metaObject, (attrs, key)->
			if ( $('meta[name="'+key+'"]') ).length
				_.each attrs, (attrValue, attrKey)->
					$('meta[name="'+key+'"]').attr(attrKey, attrValue)
			else
				ogMetaItem = '<meta property="og:'+key+'" content="'+attrs["content"]+'" class="dynamic_meta"/>'+'\n'
				metaItem = '<meta name="'+key+'"'
				_.each attrs, (attrValue, attrKey)->
					metaItem += attrKey+'="'+attrValue+'" class="dynamic_meta"/>'
				context.prepend(ogMetaItem+metaItem)

		#$('meta[property="share:title"]').attr("content", title)

	@escapeHtml: (text)->
		text
			.replace /&/g, "&amp;"
			.replace /</g, "&lt;"
			.replace />/g, "&gt;"
			.replace /"/g, "&quot;"
			.replace /'/g, "&#039;"

	@durationToString: ( duration )->
		duration = parseInt( duration ) || 0

		minutes = Math.floor duration / 60
		seconds = Math.floor duration % 60
		minutes = if minutes < 10 then '0' + minutes else minutes
		seconds = if seconds < 10 then '0' + seconds else seconds

		minutes + ':' + seconds

	@uniqid: ( prefix, more_entropy )->
		#  discuss at: http:#phpjs.org/functions/uniqid/
		# original by: Kevin van Zonneveld (http:#kevin.vanzonneveld.net)
		#  revised by: Kankrelune (http:#www.webfaktory.info/)
		#        note: Uses an internal counter (in php_js global) to avoid collision
		#        test: skip
		#   example 1: uniqid();
		#   returns 1: 'a30285b160c14'
		#   example 2: uniqid('foo');
		#   returns 2: 'fooa30285b1cd361'
		#   example 3: uniqid('bar', true);
		#   returns 3: 'bara20285b23dfd1.31879087'

		prefix = '' if ! prefix

		formatSeed = (seed, reqWidth)->
			# to hex str
			seed = parseInt(seed, 10).toString 16
			# so long we split
			if reqWidth < seed.length
				return seed.slice seed.length-reqWidth

			# so short we pad
			if reqWidth > seed.length
				return Array( 1+reqWidth-seed.length ).join('0') + seed

			return seed

		# END REDUNDANT
		# init seed with big random int
		if ! @uniqidSeed
			@uniqidSeed = Math.floor Math.random() * 0x75bcd15

		@uniqidSeed++

		# start with prefix, add current milliseconds hex string
		retId = prefix
		retId += formatSeed( parseInt(new Date().getTime() / 1000, 10), 8 )
		# add seed hex string
		retId += formatSeed @uniqidSeed, 5
		# for more entropy we add a float lower to 10
		if more_entropy
			retId += (Math.random() * 10).toFixed(8).toString()

		retId

module.exports = Utils