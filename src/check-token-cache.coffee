crypto = require 'crypto'
http   = require 'http'
TokenManager = require 'meshblu-core-manager-token'

class CheckTokenCache
  constructor: (options={}) ->
    {@cache,pepper,uuidAliasResolver} = options
    @tokenManager = new TokenManager {pepper, uuidAliasResolver}

  _doCallback: (request, code, callback) =>
    response =
      metadata:
        responseId: request.metadata.responseId
        code: code
        status: http.STATUS_CODES[code]
    callback null, response

  do: (request, callback) =>
    {uuid,token} = request.metadata.auth
    return @_doCallback request, 404, callback unless uuid? and token?

    @tokenManager.hashToken uuid, token, (error, hashedToken) =>
      return callback error if error?
      return @_doCallback request, 404, callback unless hashedToken?

      @cache.exists "#{uuid}:#{hashedToken}", (error, result) =>
        return @_doCallback request, (if result then 204 else 404), callback

module.exports = CheckTokenCache
