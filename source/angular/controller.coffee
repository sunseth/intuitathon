lodash = require('lodash')

module.exports = (app) ->
  app.controller 'AppController', class AppController
    constructor: (@$scope, @$http, @$sce) ->
      @$scope.suggestTags = []
      @$scope.displayTags = []
      @$scope.suggestTags = @getTags(@$scope.displayTags)
      @$scope.youtubeURL = "http://www.youtube.com/embed/M7lc1UVf-VE?enablejsapi=1&origin=http://example.com"


    getTags: (tags) ->
      @$http.post('/tags', {tags})
        .success (tags) =>
          @$scope.suggestTags = tags.topWords
        .error (err) =>
          console.log err

    addTag: (tag) ->
      @$scope.displayTags.push(tag._id)
      @$scope.suggestTags = @getTags(@$scope.displayTags)
      @getPosts(@$scope.displayTags)

    removeTag: (tag) ->
      @$scope.displayTags = lodash.remove(@$scope.displayTags, (_tag) ->
        return tag != _tag
      )
      @$scope.suggestTags = @getTags(@$scope.displayTags)
      @$scope.posts = @getPosts(@$scope.displayTags)

    getPosts: (tags) ->
      if tags.length == 0
        posts = []
        return
      @$http.post('/posts', {tags})
        .success (posts) =>
          @$scope.posts = posts
        .error (err) =>
          console.log err

    showVideo: () ->
      $('.ui.modal').modal('show')
      tags = @$scope.displayTags
      @$http.post('/video', {tags})
        .success (video) =>
          @$scope.videoId = video.bestVideo.videoId
        .error (err) =>
          console.log err

    htmlParse: (html) ->
      return @$sce.trustAsHtml(html)

    trustYoutubeSrc: (videoId) ->
      return @$sce.trustAsResourceUrl("http://www.youtube.com/embed/#{videoId}?enablejsapi=1&origin=http://example.com")