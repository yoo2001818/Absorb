express = require 'express'
serveStatic = require 'serve-static'
morgan = require 'morgan'

port = 8000

require './src/Init'
###
app = express()

app.use morgan 'short'
app.use new serveStatic './build'

app.listen port
console.log "Listening on port #{port}"
###
