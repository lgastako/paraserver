express = require "express"
jsdom = require "jsdom"
simplerequest = require "request"
url = require "url"

JQUERY_URL = "http://code.jquery.com/jquery-1.6.min.js"
ATTACHED_SCRIPTS = [JQUERY_URL]

app = module.exports = express.createServer();

scrape = (request, response) ->
    url = request.param "url"
    simplerequest {uri: url}, (error, response, body) ->
        self = this
        self.items = []

        if error and response.statusCode != 200
            console.log "Request error."

        jsdom.env {html: body, scripts: ATTACHED_SCRIPTS}, (error, window) ->
            $ = window.jQuery;
            title = $("title").text()
            console.log title
            response.end title

app.get "/scrape", scrape

if not module.parent
  app.listen 3000
  console.log "Express server listening on port %d", app.address().port
