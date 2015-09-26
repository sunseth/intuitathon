module.exports = {
  port: 9000
  youtube:
    key: 'AIzaSyD9wc4oMlfzVLkVGu6rIhVR_RQQZHT95s8'
  mongo:
    uri: 'mongodb://localhost:27017/taxInfo'
    options:
      server:
        socketOptions: {keepAlive: 1, connectTimeoutMS: 60000}
}