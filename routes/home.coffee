lodash = require 'lodash'
request = require 'request'
{Post, Response} = require('../data')
config = require '../config'

mapf = () ->
  for key, val of this.titleWordRank
    emit(key, val)

reducef = (key, values) ->
  return Array.sum(values)

mr = {
  map: mapf
  reduce: reducef
}

module.exports = (app) ->

  app.get '/', (req, res, next) ->
    res.render 'index'

  app.post '/tags', (req, res, next) ->
    console.log 'tags'
    tags = req.body.tags
    console.log tags
    if tags.length > 0
      mr['query'] = {titleWords: {$in: tags}}
    else
      delete mr['query']
    query: {titleWords: {$in: tags}}
    Post.mapReduce(mr, (err, results) ->
      topWords = findTopWords(results, tags)
      console.log topWords
      res.send({topWords})
    )

  app.post '/posts', (req, res, next) ->
    console.log 'posts'
    tags = req.body.tags
    console.log tags
    Post.find({titleWords: {$in: tags}}).exec (err, posts) ->
      console.log lodash.pluck(posts, 'titleWords')
      relevantPosts = findRelevantPosts(posts, tags)
      console.log relevantPosts
      res.send({relevantPosts})

  app.get '/videos', (req, res, next) ->
    youtubeUser = "TurboTax"
    youtubeUrl = "https://www.googleapis.com/youtube/v3/channels?part=contentDetails&forUsername=#{youtubeUser}&key=#{config.youtube.key}"
    request(youtubeUrl, (err, response, body) ->
      body = JSON.parse(body)
      uploadsKey = body.items[0].contentDetails.relatedPlaylists.uploads
      playlistUrl = "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&playlistId=#{uploadsKey}&key=#{config.youtube.key}"
      request(playlistUrl, (err, _response, body) ->
        console.log JSON.parse(body)
        res.send JSON.parse(body)
      )
    )


findTopWords = (results, tags) ->
  numWords = 10 - Math.pow(2, tags.length)
  numWords = if numWords <= 0 then 2 else numWords
  keyValSorted = lodash.sortBy(results, (pair) ->
    return pair.value)
  keyValLength = keyValSorted.length
  redundantTags = lodash.remove(keyValSorted, (keyVal) ->
    for tag in tags
      return tag == keyVal
  )
  return keyValSorted.slice(keyValLength - numWords - 1, keyValLength)

findRelevantPosts = (posts, tags) ->
  highestRelevancy = 0
  returnPost = null
  for post in posts
    totalRelevance = 0
    rankedWords = post.titleWordRank
    for tag in tags
      totalRelevance += rankedWords[tag] || 0
    if totalRelevance > highestRelevancy
      highestRelevancy = totalRelevance
      returnPost = post
  return returnPost




