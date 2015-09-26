mongoose = require 'mongoose'
Schema = mongoose.Schema

PostSchema = new Schema(
  "Post ID": Number,
  Subject: String,
  Details: String,
  "Created At": String,
  Edition: String,
  Platform: String,
  "Question Tags": String
  State: String,
  Reply: String,
  "Replied At": String,
  wordRank: [String]
)

module.exports = PostSchema