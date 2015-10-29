crypto = require 'crypto'
http   = require 'http'
TokenManager = require 'meshblu-core-manager-token'

class CheckTokenCache
  constructor: (options={}) ->
    {@cache,@pepper} = options
    @tokenManager = new TokenManager pepper: @pepper

  do: (request, callback) =>
    {uuid,token} = request.metadata.auth
    hashedToken = @tokenManager.hashToken uuid, token

    @cache.exists "#{uuid}:#{hashedToken}", (error, result) =>
      code = 204
      code = 404 if result == 0

      response =
        responseId: request.metadata.responseId
        code: code
        status: http.STATUS_CODES[code]

      callback null, response

module.exports = CheckTokenCache
