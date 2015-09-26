mongoose = require 'mongoose'
config = require '../config'

mongoose.connect config.mongo.uri, config.mongo.options
mongoose.connection.on 'error', (err) ->
  console.error config.mongo
  throw new Error(err) if err
mongoose.connection.once 'open', ->
console.log "Connected to #{config.mongo.uri}"

module.exports = exports = (app) ->

exports['Post'] = mongoose.model 'Post', require './schemas/posts', 'posts'
exports['Response'] = mongoose.model 'Response', require './schemas/responses', 'responses'
exports['Video'] = mongoose.model 'Video', require './schemas/videos', 'videos'