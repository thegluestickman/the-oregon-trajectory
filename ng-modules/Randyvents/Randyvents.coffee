# event engine for angular applications (and games)
# conceptually similar to https://github.com/7yl4r/eventsEngine/tree/master/EventsEngine

#                     ` ' @@@@@@@@# +.
#                 , @@@@@@@@@@@@@@@@@@@@@@`
#               + @@@@@@@@@@@@@@@@@@@@@@@@@@`
#             ; @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@`
#            ' @@@@@@@@@@@@@@@@; @@@@@@@@@@@@@@@
#           @@@@@@@@@@@@@@@@@@. @@@@@@@@@@@@@@@@@
#          # @@@@@@@@@@@@@@@@# . @@@@@@@@@@# @@@@@@:
#        . @@@@# ` @@@@+ ` : . . # @@@@@@@@. ' @@@@@
#        # @@, . . # @@@@@@@@` . ' @@@@# ` . . . @@@@.
#        ` @@. . . . , `    ` . . `     , @@. . . # @@;
#        + @@. . . . `         `           ` . . . ` @@@
#        +@@ . . .        @    `   @       . . . . @@@
#        + @@: . . .           `             ` . . . @@#
#        . @@. . . .           `             ` . . . @@,
#          @@ . . . `         . .           . . . . @
#         ' , . . . . . . . . . . . . ` ` . . . . ` #
#          @@. . . . . . . . , ; . . . . . . . . # '
#           ; + . . . . . . + @@@@@@@@. . . . . ` @@:
#            # ` . . . ` @@@@@@@@@@@@. . . . . : '
#             @@. . . . # . ; ; , ` . . . . . @
#               , . . . . . ` ` . . . . . . ,
#               , + ; . . . , . . : . . . . + ,
#             ' ; + ; ' , . . . : . . . ' ; + ' '
#            ; ' ' ' ' ' + '         ' ' ' ' ' ' ' '
#          ` ' ' ' ; ' ; ' ' ;     : ; ; ; ' ; ' ; '
#          ; ' ; ; ; ; ' ' ' ' ;   ' ' ; ; ; ' ' ' ' ;
#        ' ; ' ' ; ' ' ' ; ' ' ; + ; ' ; ; ; ' ; ' ' '`


class Event
    constructor: (eventJSON, $scope)->
        @type = eventJSON.type
        @name = eventJSON.name
        @criteria = eventJSON.criteria
        @chance = eventJSON.chance
        @data = eventJSON.args
        @count = 0  # number of times event has triggered
        @scope = $scope

    trigger: ()->
        @count += 1
        console.log(@type, ':', @name, ' triggered')
        @scope.$broadcast(@type, [name, data])
        # or should this be $emit?

module.exports = class Randyvents
    # main class for handling random events
    constructor: ($scope, eventsFile)->
        @scope = $scope
        @events = []
        if eventsFile?
            @_loadEventsFromFile(eventsFile)
        else
            # TODO: this should do nothing, but we're loading for testing
            @_loadEventsFromFile("NOT_A_FILE.json")

    _loadEventsFromFile: (file)->
        # loads array of events from a single file
        # TODO: get this json from files
        eventArray = [
            {
                "type": "encounter",
                "name": "space-junk",
                "criteria": {
                    "locations": ['earth']
                },
                "chance": 0.5
            },{
                "type": "encounter",
                "name": "micro-meteroid",
                "criteria":{},
                "chance": 0.5
            }
        ]

        for event in eventArray
            new_event = new Event(event, @scope)
            @events.push(new_event)

    roll: ()->
        # Uses just one random call to optimize,
        # and only allows one event to trigger at a time.
        # This means that events aren't 100% random,
        # nor will empirical results match the given "chance" for each.
        # But I think this is a good thing.
        #
        # Consider 3 events w/ 0.5 chance, this is interpreted as:
        #   50% chance of encountering event,
        #   33% chance of each event when event is encountered
        # which means the actual chance of each ends up being 0.5*0.3.
        # Except it's not, b/c randomness isn't as fun as novelty.
        #
        # Why all this nonsense, you ask?
        #   * event chances don't have to be normalized to all other chances
        #        (read: you don't have to adjust all event chances to add one more)
        #   * grouping events this way allows us to artificially boost novelty
        die = Math.random()
        most_novel_event = {count: Number.MAX_VALUE}  # to track of the most novel event triggered
        trigger = false
        for event in @events
            if die > event.chance
                trigger = true
                if event.count < 1  # if never seen this event
                    event.trigger()
                    return
                else  # wait and maybe trigger a more novel event
                    if most_novel_event.count > event.count
                        most_novel_event = event
        # if we reach here, no novel events triggered
        if trigger
            most_novel_event.trigger()
        else
            return  # no events triggered
