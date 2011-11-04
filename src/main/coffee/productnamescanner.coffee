scanner = require "./scanner"


class ProductNameScanner extends scanner.Scanner
    # We want to find the element on the page whose text is a prefix (or
    # less-likely-ly a postfix) of the page title and assume that text
    # is the product name.
    #
    # This page breaks because they have a mini-description that's longer
    # than the product title.
    # http://www.crutchfield.com/p_113KAC5204/Kenwood-KAC-5204.html?tp=35757

    constructor: (rawPageTitle=document.title) ->
        super
        @productName = null
        @candidates = []
        @pageTitle = smush rawPageTitle
        console.log "@pageTitle=[" + @pageTitle + "]"

    getNodesToShow: -> NodeFilter.SHOW_TEXT

    visit: (node) ->
        parentTagName = node.parentNode.tagName
        return if parentTagName == "SCRIPT" or parentTagName == "TITLE"
        [perfectMatch, candidate] = @testCandidacy node.data
        if perfectMatch
            # log.debug "perfect match"
            @productName = candidate
            @done = true
        else
            if candidate?
                # log.debug "adding candidate: " + candidate
                @candidates.push candidate

    testCandidacy: (text) ->
        cleaned = smush(text)
        return [false, null] if not cleaned?
        # If it's longer than the page title it can't be good, so short circuit
        return [false, null] if cleaned.length > @pageTitle.length
        result = [false, null]
        if cleaned.length >= (@pageTitle.length / 3)
            leftIndex = @pageTitle.indexOf cleaned
            if leftIndex == 0
                result = [true, text]
            else
                if @pageTitle.lastIndexOf(cleaned) == @pageTitle.length - cleaned.length
                    result = [true, text]
                else
                    if leftIndex > -1
                        result = [false, text]
        result

    getProductName: ->
        if not @productName?
            log.debug "no existing (short-circuited/perfect) product name so picking best candidate"
            @productName = do @pickBestCandidate
        @productName

    pickBestCandidate: ->
        if @candidates
            best = null
            log.object "candidates", @candidates
            for candidate in @candidates
                best = candidate unless best? and best.length > candidate.length
            best


asFunc = (window) ->
    pns = new scanner.ProductNameScanner
    ms = new scanner.MultiScanner
    do ms.scan window

exports.ProductNameScanner = ProductNameScanner
exports.asFunc = asFunc
