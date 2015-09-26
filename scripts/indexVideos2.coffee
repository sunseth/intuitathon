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

{Video} = require('../data')
rootWords =
  deduct: 'deduction'
  deductions: 'deduction'
  homes: 'home'
  improvements: 'improvement'
  savings: 'save'
  'summer-time': 'summer'
  taxes: 'tax'

count = 0
extractionOptions = {
  language:"english",
  remove_digits: true,
  return_changed_case:true,
  remove_duplicates: false
}

homeWords = ['home', 'house', 'lien', 'mortgage' ,'property', 'residence', 'foreclosure', 'energy',
'wind']

Video.find({}).exec (err, videos) ->
  async.eachLimit videos, 5, (video, eCb) ->
    title = video.title
    titleExtract = keyword_extractor.extract(title, extractionOptions)
    titleCollapsed = collapseWords(titleExtract)
    homeCategory = determineHomeCategory(titleCollapsed)
    video.homeCategory = homeCategory
    video.titleWords = titleCollapsed
    video.save eCb
  , (err) ->
    console.log err

collapseWords = (titleWords) ->
  collapsedRootWords = []
  for word in titleWords
    collapsed = rootWords[word] || word
    collapsedRootWords.push collapsed
  return collapsedRootWords

determineHomeCategory = (titleWords) ->
  for word in titleWords
    for hword in homeWords
      if natural.JaroWinklerDistance(word, hword) > 0.85
        console.log word, hword
        return true
  return false