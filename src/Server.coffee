express = require 'express'
serveStatic = require 'serve-static'
morgan = require 'morgan'

port = 8000

app = express()
server = require('http').Server app
io = require('socket.io') server

app.use morgan 'short'
app.use new serveStatic './build'

server.listen port
console.log "Listening on port #{port}"
console.log 'You may need to run grunt before starting the server.'

require('./ServerGame') io