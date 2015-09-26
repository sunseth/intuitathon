{Video} = require('../data')
config = require('../config')

async = require 'async'
lodash = require 'lodash'
request = require 'request'

youtubeUser = "TurboTax"
youtubeUrl = "https://www.googleapis.com/youtube/v3/channels?part=contentDetails&forUsername=#{youtubeUser}&key=#{config.youtube.key}"
request(youtubeUrl, (err, response, body) ->
  body = JSON.parse(body)
  uploadsKey = body.items[0].contentDetails.relatedPlaylists.uploads
  playlistUrl = "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&playlistId=#{uploadsKey}&key=#{config.youtube.key}"

  console.log body.pageInfo.totalResults
  totalVideos = 561
  videoCount = 0

  pageToken = null

  async.doWhilst(
    (dCb) ->
      request(playlistUrl, (err, _response, body) ->
        body = JSON.parse(body)
        pageToken = body?.nextPageToken
        videoCount += body.items.length
        playlistUrl = "https://www.googleapis.com/youtube/v3/playlistItems?pageToken=#{pageToken}&part=snippet&playlistId=#{uploadsKey}&key=#{config.youtube.key}"
        async.each body.items, (item, eCb) ->
          snippet = item.snippet
          published = snippet.publishedAt
          title = snippet.title
          description = snippet.description
          resourceId = snippet.resourceId
          videoId = resourceId.videoId
          console.log 'what'
          video = new Video
            title: title
            published: published
            description: description
            videoId: videoId
          video.save eCb
        , (err) ->
          console.log err if err
          dCb()
      )
    , () ->
      console.log videoCount, totalVideos
      return videoCount < totalVideos
    , (err) ->
      console.log err if err

  )


)