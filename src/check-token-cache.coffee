http         = require 'http'
TokenManager = require 'meshblu-core-manager-token'

class CheckTokenCache
  constructor: (options={}) ->
    {@cache,pepper,@uuidAliasResolver} = options
    @tokenManager = new TokenManager {pepper,@uuidAliasResolver}

  _doCallback: (request, code, callback) =>
    response =
      metadata:
        responseId: request.metadata.responseId
        code: code
        status: http.STATUS_CODES[code]
    callback null, response

  do: (request, callback) =>
    {uuid,token} = request.metadata.auth ? {}
    return @_doCallback request, 404, callback unless uuid? and token?
    @checkTokenCache { uuid, token }, (error, result) =>
      return callback error if error?
      @_doCallback request, (if result then 204 else 404), callback

  checkTokenCache: ({ uuid, token }, callback) =>
    @uuidAliasResolver.resolve uuid, (error, uuid) =>
      return callback error if error?
      hashedToken = @tokenManager.hashToken { uuid, token }
      @cache.exists "#{uuid}:#{hashedToken}", callback

module.exports = CheckTokenCache
