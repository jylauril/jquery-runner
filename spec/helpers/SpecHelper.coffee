beforeEach ->
  toStr = (test) -> Object.prototype.toString.call(test)
  ofType = (type) -> typeof @actual is type
  ofString = (type) -> toStr(@actual) is type
  matchType = (test) -> toStr(@actual) is toStr(test)
  have = (prop) -> !_.isUndefined(@actual[prop])
  haveOwn = (prop) -> Object.prototype.hasOwnProperty.call(@actual, prop)
  emptyObject = () -> _.isEmpty(@actual)
  haveProperties = (api) ->
    api = api.split(/[^\w]+/g) if _.isString api
    if not _.isArray(api) and _.isObject(api) then api = _.keys api
    if _.isArray api
      for key in api
        expect(@actual).toHave(key)
      return true
    else return false
  mimicStructure = (skel) ->
    if not _.isArray(skel) and _.isObject(skel)
      for key, value of skel
        expect(@actual).toHave(key)
        expect(@actual[key]).toMatchType(value)
      return true
    else return haveStructure.call(@, skel)

  @addMatchers
    toBeOfType: ofType
    toBeEmptyObject: emptyObject
    toBeOfString: ofString
    toMatchType: matchType
    toHave: have
    toHaveOwn: haveOwn
    toHaveProperties: haveProperties
    toMimicStructure: mimicStructure
