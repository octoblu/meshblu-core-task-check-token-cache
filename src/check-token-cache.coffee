crypto = require 'crypto'
http   = require 'http'
TokenManager = require 'meshblu-core-manager-token'

class CheckTokenCache
  constructor: (options={}) ->
    {@cache,@pepper} = options
    @tokenManager = new TokenManager pepper: @pepper

  do: (request, callback) =>
    {uuid,token} = request.metadata.auth
    @tokenManager.hashToken uuid, token, (error, hashedToken) =>
      return callback error if error?

      @cache.exists "#{uuid}:#{hashedToken}", (error, result) =>
        code = 404
        code = 204 if result

        response =
          metadata:
            responseId: request.metadata.responseId
            code: code
            status: http.STATUS_CODES[code]

        callback null, response

module.exports = CheckTokenCache
