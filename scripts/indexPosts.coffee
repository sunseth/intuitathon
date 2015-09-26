async = require 'async'
lodash = require 'lodash'
natural = require 'natural'
TfIdf = natural.TfIdf
tfidf = new TfIdf()

keyword_extractor = require('keyword-extractor')
htmlparser = require 'htmlparser2'
htmlText = ""
parser = new htmlparser.Parser({
  ontext: (text) ->
    htmlText += text
}, {decodeEntities: true})

stopwords = require('stopwords').english

{Post} = require('../data')
rootWords =
  deduct: 'deduction'
  homes: 'home'
  improvements: 'improvement'
  savings: 'save'
  'summer-time': 'summer'
  taxes: 'tax'

homeWords = ['home', 'house', 'lien', 'mortgage' ,'property', 'residence', 'foreclosure']

count = 0
extractionOptions = {
  language:"english",
  remove_digits: true,
  return_changed_case:true,
  remove_duplicates: false
}

Post.find({}).exec (err, posts) ->
  async.eachLimit posts, 5, (post, eCb) ->
    title = post.title
    titleExtract = keyword_extractor.extract(title, extractionOptions)
    post.titleWords = titleExtract

    parser.write(post.body)
    bodyExtract = keyword_extractor.extract(htmlText, extractionOptions)

    htmlText = ""
    titleWordImportance = {}
    tfidf.addDocument(bodyExtract)

    for word in titleExtract
      tfidf.tfidfs(word, (i, measure) ->
        titleWordImportance[word] = measure)
    titleWordImportance = collapseRootWords(titleWordImportance)
    homeCategory = determineHomeCategory(titleWordImportance)
    console.log titleWordImportance
    console.log homeCategory
    post.titleWordRank = titleWordImportance
    post.save eCb
  console.log 'done'

collapseRootWords = (titleWords) ->
  collapsedWords = {}
  for word, value of titleWords
    collapsed = rootWords[word] || word
    collapsedWords[collapsed] ||= 0
    collapsedWords[collapsed] += value
  return collapsedWords

determineHomeCategory = (titleWords) ->
  for word in titleWords
    for hword in homeWords
      if natural.JaroWinklerDistance(word, hword) > 0.75
        return true
  return false