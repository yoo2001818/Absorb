express = require 'express'
serveStatic = require 'serve-static'
morgan = require 'morgan'
grunt = require 'grunt'

port = 8000

grunt.registerTask 'run', 'Runs the server.', () ->
  done = @async()
  app = express()

  app.use morgan 'short'
  app.use new serveStatic './build'

  app.listen port
  console.log "Listening on port #{port}"

console.log 'Building project before opening server'
grunt.tasks ['default', 'run']
