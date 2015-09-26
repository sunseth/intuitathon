lodash = require 'lodash'
request = require 'request'
natural = require 'natural'
{Post, Response, Video} = require('../data')
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
    tags = req.body.tags
    if tags.length > 0
      mr['query'] = {titleWords: {$in: tags}}
    else
      delete mr['query']
    query: {titleWords: {$in: tags}}
    Post.mapReduce(mr, (err, results) ->
      topWords = findTopWords(results, tags)
      res.send({topWords})
    )

  app.post '/posts', (req, res, next) ->
    tags = req.body.tags
    Post.find({titleWords: {$in: tags}}).exec (err, posts) ->
      relevantPosts = findRelevantPosts(posts, tags)
      res.send({relevantPosts})

  app.post '/video', (req, res, next) ->
    tags = req.body.tags
    Video.find({homeCategory: true}).exec (err, videos) ->
      bestVideo = findBestVideo(videos, tags)
      res.send {bestVideo}

findTopWords = (results, tags) ->
  numWords = 10 - tags.length
  numWords = if numWords <= 0 then 2 else numWords
  keyValSorted = lodash.sortBy(results, (pair) ->
    return pair.value)
  keyValLength = keyValSorted.length
  redundantTags = lodash.remove(keyValSorted, (keyVal) ->
    for tag in tags
      if tag == keyVal
        return true
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

findBestVideo = (videos, tags) ->
  highestRelevancy = 0
  returnVideo = null
  for video in videos
    totalRelevance = 0
    for word in video.titleWords
      for tag in tags
        if natural.JaroWinklerDistance(word, tag) > 0.85
          totalRelevance += 10
        else
          totalRelevance += natural.JaroWinklerDistance(word, tag)
    if totalRelevance > highestRelevancy
      highestRelevancy = totalRelevance
      returnVideo = video
  return returnVideo




