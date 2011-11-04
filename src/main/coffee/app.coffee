express = require "express"
jsdom = require "jsdom"
request = require "request"
url = require "url"

JQUERY_URL = "http://code.jquery.com/jquery-1.6.min.js"
ATTACHED_SCRIPTS = [JQUERY_URL]

app = module.exports = express.createServer();


scrape = (req, res) ->
    url = req.param "url"
    request {uri: url}, (error, response, body) ->
        self = this
        self.items = []

        if error and response.statusCode != 200
            console.log "Request error."

        jsdom.env {html: body, scripts: ATTACHED_SCRIPTS}, (error, window) ->
            $ = window.jQuery;
            title = "The title is: "  + $("title").text()
            console.log title
            res.end title


app.get "/scrape", scrape


if not module.parent
  app.listen 3000
  console.log "Express server listening on port %d", app.address().port
