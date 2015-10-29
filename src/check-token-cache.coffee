crypto = require 'crypto'
http   = require 'http'

class CheckTokenCache
  constructor: (options={}) ->
    {@cache,@pepper} = options

  do: (request, callback) =>
    {uuid,token} = request.metadata.auth
    hashedToken = @_hashToken uuid, token

    @cache.exists "#{uuid}:#{hashedToken}", (error, result) =>
      code = 204
      code = 404 if result == 0

      response =
        responseId: request.metadata.responseId
        code: code
        status: http.STATUS_CODES[code]

      callback null, response

  _hashToken: (uuid, token) =>
    hasher = crypto.createHash 'sha256'
    hasher.update uuid
    hasher.update token
    hasher.update @pepper
    hasher.digest 'base64'

module.exports = CheckTokenCache
