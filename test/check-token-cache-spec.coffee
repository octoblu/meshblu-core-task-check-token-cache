CheckTokenCache = require '../src/check-token-cache'
crypto = require 'crypto'
redis  = require 'fakeredis'
uuid   = require 'uuid'

describe 'CheckTokenCache', ->
  beforeEach ->
    @redisKey = uuid.v1()
    @sut = new CheckTokenCache cache: redis.createClient(@redisKey), pepper: 'totally-a-secret'
    @cache = redis.createClient @redisKey

  describe '->do', ->
    beforeEach (done) ->
      @cache.set 'barber-slips:FUujOBoQaaTSK9Ls8N7w7AaquAWV4NDXeHpIrnhC44w=', '', done

    describe 'when the uuid/token combination is in the cache', ->
      beforeEach (done) ->
        request =
          metadata:
            responseId: 'asdf'
            auth:
              uuid:  'barber-slips'
              token: 'Just a little off the top'

        @sut.do request, (error, @response) => done error

      it 'should respond with a 204', ->
        expect(@response).to.deep.equal
          responseId: 'asdf'
          code: 204
          status: 'No Content'

    describe 'when a different uuid/token combination is in the cache', ->
      beforeEach (done) ->
        @cache.set "beak:5Ick2qtwMTujgCkohjsBnDh6fykHwhPpfNfQwwEa8Rg=", '', done

      beforeEach (done) ->
        request =
          metadata:
            responseId: 'some-response'
            auth:
              uuid:  'beak'
              token: "(By which we mean a bird's horny projecting jaws)"

        @sut.do request, (error, @response) => done error

      it 'should respond with a 204', ->
        expect(@response).to.deep.equal
          responseId: 'some-response'
          code: 204
          status: 'No Content'

    describe 'when a uuid/token combination is not in the cache', ->
      beforeEach (done) ->
        request =
          metadata:
            responseId: "You'll swim with the fishes (Except they're actually mammals)!"
            auth:
              uuid:  'dolphin'
              token: 'are-they-legitimate'

        @sut.do request, (error, @response) => done error

      it 'should respond with a 404', ->
        expect(@response).to.deep.equal
          responseId: "You'll swim with the fishes (Except they're actually mammals)!"
          code: 404
          status: 'Not Found'

    describe 'when a different uuid/token combination is not in the cache', ->
      beforeEach (done) ->
        request =
          metadata:
            responseId: 'extreme'
            auth:
              uuid:  'got-too-extreme'
              token: 'sickblast-it-to-the-max-brotimes'

        @sut.do request, (error, @response) => done error

      it 'should respond with a 404', ->
        expect(@response).to.deep.equal
          responseId: 'extreme'
          code: 404
          status: 'Not Found'
