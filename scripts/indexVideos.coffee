{Video} = require('../data')

async = require 'async'
lodash = require 'lodash'

youtubeUser = "TurboTax"
youtubeUrl = "https://www.googleapis.com/youtube/v3/channels?part=contentDetails&forUsername=#{youtubeUser}&key=#{config.youtube.key}"
request(youtubeUrl, (err, response, body) ->
  body = JSON.parse(body)
  uploadsKey = body.items[0].contentDetails.relatedPlaylists.uploads
  playlistUrl = "https://www.googleapis.com/youtube/v3/playlistItems?part=snippet&playlistId=#{uploadsKey}&key=#{config.youtube.key}"
  request(playlistUrl, (err, _response, body) ->
    body = JSON.parse(body)
  )
)