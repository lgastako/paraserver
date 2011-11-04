
class Scanner

    constructor: ->
        @done = false

    # By default we show all nodes, subclasses can override to
    # provide a different value from the set:
    #     NodeFilter.SHOW_ENTITY_REFERENCE
    #     NodeFilter.SHOW_DOCUMENT_TYPE
    #     NodeFilter.SHOW_ELEMENT
    #     NodeFilter.SHOW_ENTITY
    #     NodeFilter.SHOW_FRAGMENT
    #     NodeFilter.SHOW_ATTRIBUTE
    #     NodeFilter.SHOW_PROCESSING_INSTRUCTION
    #     NodeFilter.SHOW_NOTATION
    #     NodeFilter.SHOW_TEXT
    #     NodeFilter.SHOW_COMMENT
    #     NodeFilter.SHOW_CDATA_SECTION
    getNodesToShow: -> NodeFilter.SHOW_ALL

    # By default no custom filter, but subclasses can override to provide
    getCustomFilter: -> null

    # I think we probably always want entity references expanded (e.g. because
    # otherwise (tm), (c), (r) etc will be broken), but just in case you
    # can override to disable.
    getExpandEntityReferences: -> true

    # Call this on the element you want to scan from.  Defaults to
    # the current document.
    scan: (element=document.documentElement) ->
        log.debug "scanning..."
        walker = document.createTreeWalker element,
                                           do @getNodesToShow,
                                           do @getCustomFilter,
                                           do @getExpandEntityReferences

        @done = false

        count = 0
        logCount = -> log.debug "Visited " + count + " nodes"

        while not @done and walker.nextNode()
            @visit walker.currentNode
            count += 1
            if count % 100 == 0
                logCount count
        logCount count

    visit: (node) ->


# This class is just used to run multiple scanners across the tree in
# a single pass.  Short circuits when all of it's children have
# short-circuited.
class MultiScanner extends Scanner

    constructor: (@scanners) ->
        super
        indices = (x for x in [0..(@scanners.length - 1)])
        @scannersWithIndices = _(@scanners).zip indices
        @dones = (false for scanner in @scanners)

    visit: (node) ->
        for [scanner, index] in @scannersWithIndices
            if not @dones[index]
                scanner.visit node
                @dones[index] = scanner.done
        @done = _.all @dones, _.identity


exports.Scanner = Scanner
exports.MultiScanner = MultiScanner
