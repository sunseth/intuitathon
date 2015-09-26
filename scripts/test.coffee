{Post} = require('../data')

mapf = () ->
  for key, val of this.titleWordRank
    emit(key, val)

reducef = (key, values) ->
  return Array.sum(values)

mr = {
  map: mapf
  reduce: reducef
}

Post.mapReduce(mr, (err, results) ->
  console.log results
)