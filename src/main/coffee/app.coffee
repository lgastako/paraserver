express = require "express"
jsdom = require "jsdom"
request = require "request"
url = require "url"

JQUERY_URL = "http://code.jquery.com/jquery-1.6.min.js"
ATTACHED_SCRIPTS = [JQUERY_URL]

app = module.exports = do express.createServer

app.configure "development", ->
    app.use express.errorHandler {dumpExceptions: true, showStack: true}

app.configure "production", ->
    app.use do express.errorHandler


# TODO: More error checking etc
splitScript = (script) -> script.split ".", 2


scrape = (req, res) ->
    url = req.param "url"
    scripts = req.param "scripts", "foo"
    if not url?
        res.end "Missing parameter 'url'."
        return
    if not scripts?
        res.end "Missing parameter 'scripts'."
        return
    request {uri: url}, (error, response, body) ->
        self = this
        self.items = []

        if error and response.statusCode != 200
            console.log "Request error."

        scripts = scripts.split(",")

        jsdom.env {html: body, scripts: ATTACHED_SCRIPTS}, (error, window) ->
            for scriptName in scripts
                console.log "Processing script: #{scriptName}"
                [modName, funcName] = splitScript scriptName
                console.log "modName: [#{modName}], funcName: [#{funcName}]"
                module = require "./" + modName
                # res.send module[funcName] window
            # # TODO: Error handling
            # $ = window.jQuery;
            # title = "The title is: "  + $("title").text()
            # console.log title
            # res.end title


app.get "/scrape", scrape


if not module.parent
  app.listen 3000
  console.log "Express server listening on port %d", app.address().port
