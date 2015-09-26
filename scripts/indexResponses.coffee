natural = require('natural')
classifier = require('classifier')

{Response} = require('../data')

Response.find({}).limit(100).exec (err, responses) ->
