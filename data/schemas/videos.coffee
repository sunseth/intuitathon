mongoose = require 'mongoose'
Schema = mongoose.Schema

VideoSchema = new Schema(
  title: String,
  published: String,
  videoId: String,
  description: String,
  titleWords: [String],
  titleWordRank: Schema.Types.Mixed
)

module.exports = VideoSchema