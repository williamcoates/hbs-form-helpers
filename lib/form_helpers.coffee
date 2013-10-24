class FormHelpers
  @INPUTS = ['text', 'password', 'number', 'email', 'url', 'range', 'hidden']
  @OTHERS = ['select', 'textArea', 'labelId', 'errorMessage']

  _i18n: (ctx, msg) ->
    if ctx.i18n
      ctx.i18n.__(msg)
    else
      msg

  _objectNamespace: (ctx) ->
    null

  _parseMagicMarkers: (val) ->
    if val.substring?
      val.replace('$currentYear', new Date().getFullYear())
    else
      val

  _id: (ctx, name) ->
    if @_objectNamespace(ctx)
      "#{@_objectNamespace(ctx)}_#{name}"
    else
      name

  labelId: (ctx, name) ->
    "#{@_id(ctx, name)}_label"

  _name: (ctx, name) ->
    if @_objectNamespace(ctx)
      "#{@_objectNamespace(ctx)}[#{name}]"
    else
      name

  _nameAndId: (ctx, name) ->
    "name=\"#{@_name(ctx, name)}\" id=\"#{@_id(ctx, name)}\""

  _inputClass: ->
    ''

  messageContainer: (ctx, name, body) ->
    isError = @isError(ctx, name)
    """<div class="controls#{if isError then ' error' else ''}">#{body}#{@errorTag(ctx, name)}</div>"""

  isError: (ctx, name) ->
    @_errorMessage(ctx, name)?

  _errorMessage: (ctx, name) ->
    errors =
      if @_objectNamespace(ctx)
         ctx[@_objectNamespace(ctx)]?.errors
      else
        ctx?.errors
    errorObj = errors?[name]
    if errorObj?.substring
      errorObj
    else
      errorObj?.message

  errorMessage: (ctx, name) ->
    @messageContainer(ctx, name, '')

  errorTag: (ctx, name) ->
    if @isError(ctx, name)
      """<div class="error">#{@_i18n(ctx, @_errorMessage(ctx, name))}</div>"""
    else
      ''

  _getValue: (ctx, name) ->
    throw "You must pass a context" unless ctx
    if @_objectNamespace(ctx)
       ctx[@_objectNamespace(ctx)]?[name]
    else
      ctx[name]

  inputTag: (ctx, type, name, options) ->
    inputOptions = options.hash
    value = @_getValue(ctx, name)
    value = '' unless value?
    if type is 'textarea'
      body = value
      tagName = 'textarea'
      endTag = ">#{body}</#{tagName}>"
    else
      typeAttribute = 'type="' + type + '"'
      valueAttribute = value
      tagName = 'input'
      endTag =  "/>"

    knownOptionalAttributes = ['placeholder', 'min', 'max', 'step', 'pattern']
    optionalAttributes = {}
    # i18n
    if inputOptions?['placeholder']
      inputOptions['placeholder'] = @_i18n(ctx, inputOptions?['placeholder'])
    for a in knownOptionalAttributes
      if inputOptions?[a]
        optionalAttributes[a] = inputOptions[a]
    optionalAttributesString = ("#{key}=\"#{@_parseMagicMarkers(val)}\"" for key, val of optionalAttributes).join('')
    isAutofocus = inputOptions?.autofocus is true
    isRequired = inputOptions?.required is true
    @messageContainer(ctx, name, """<#{tagName} #{typeAttribute} class="#{@_inputClass()}" #{@_nameAndId(ctx, name)} value="#{value}"
          #{if isAutofocus then 'autofocus' else ''} #{if isRequired then 'required' else ''} #{optionalAttributesString} #{endTag}""")

  textArea: (ctx, name, options) ->
    @inputTag(ctx, 'textarea', name, options)

  select: (ctx, name, options) ->
    selectOptions = options.hash
    optionsString = ("""<option value="#{key}">#{@_i18n(ctx, value)}</option>""" for key, value of selectOptions).join("")
    """<select #{@_nameAndId(ctx, name)}>#{optionsString}</select>"""

  # Sets up a helper, fixing the context so that we have the Handlebars context in first arg instead of as 'this'
  helper: (name) ->
    self = this # FormHelper's ctx
    (args...) ->
      ctx = this # Handlebars ctx
      #console.log "Calling helper method '#{name}' with args %j ", args
      self[name](ctx, args...)

  @registerHelpers: (hbs) ->
    helpers = new @
    # Setup input helpers
    for i in @INPUTS
      do (i) ->
        helpers["#{i}Input"] = (ctx, args...) ->
          @inputTag(ctx, i, args...)
        hbs.registerHelper "#{i}Input", helpers.helper("#{i}Input")
    # Setup other helpers
    for name in @OTHERS
      hbs.registerHelper name, helpers.helper(name)

module.exports = FormHelpers
