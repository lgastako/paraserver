var ATTACHED_SCRIPTS, JQUERY_URL, app, express, jsdom, scrape, simplerequest, url;
express = require("express");
jsdom = require("jsdom");
simplerequest = require("request");
url = require("url");
JQUERY_URL = "http://code.jquery.com/jquery-1.6.min.js";
ATTACHED_SCRIPTS = [JQUERY_URL];
app = module.exports = express.createServer();
scrape = function(request, response) {
  url = request.param("url");
  return simplerequest({
    uri: url
  }, function(error, response, body) {
    var self;
    self = this;
    self.items = [];
    if (error && response.statusCode !== 200) console.log("Request error.");
    return jsdom.env({
      html: body,
      scripts: ATTACHED_SCRIPTS
    }, function(error, window) {
      var $, title;
      $ = window.jQuery;
      title = $("title").text();
      console.log(title);
      return response.end(title);
    });
  });
};
app.get("/scrape", scrape);
if (!module.parent) {
  app.listen(3000);
  console.log("Express server listening on port %d", app.address().port);
}