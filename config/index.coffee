module.exports = {
  port: 9000
  mongo:
    uri: 'mongodb://localhost:27017/taxInfo'
    options:
      server:
        socketOptions: {keepAlive: 1, connectTimeoutMS: 60000}
}