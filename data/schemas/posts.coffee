mongoose = require 'mongoose'
Schema = mongoose.Schema

PostSchema = new Schema(
  title: String,
  published: String,
  author: String,
  category: String,
  body: String,
  titleWords: [String],
  titleWordRank: Schema.Types.Mixed
)

module.exports = PostSchema