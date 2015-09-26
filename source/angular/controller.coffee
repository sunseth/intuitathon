lodash = require('lodash')

module.exports = (app) ->
  app.controller 'AppController', class AppController
    constructor: (@$scope, @$http, @$sce) ->
      @$scope.suggestTags = []
      @$scope.displayTags = []
      @$scope.suggestTags = @getTags(@$scope.displayTags)


    getTags: (tags) ->
      @$http.post('/tags', {tags})
        .success (tags) =>
          console.log tags
          @$scope.suggestTags = tags.topWords
        .error (err) =>
          console.log err

    addTag: (tag) ->
      @$scope.displayTags.push(tag._id)
      @$scope.suggestTags = @getTags(@$scope.displayTags)
      @$scope.posts = @getPosts(@$scope.displayTags)

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
      console.log tags
      @$http.post('/posts', {tags})
        .success (posts) =>
          console.log posts
          @$scope.posts = posts
        .error (err) =>
          console.log err

    htmlParse: (html) ->
      return @$sce.trustAsHtml(html)