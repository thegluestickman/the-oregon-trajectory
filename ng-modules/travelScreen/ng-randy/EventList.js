/*

This file contains the list of in-travel random events.
Feel free to add your own events, I'll try and explain the syntax a bit here:
Each event is an object encapsulated by {}, so it looks like this:
{
    "type": "watevs",
    "name": "my-event",
}
Here is a breakdown of the event attributes:
    * name - a unique name for your event.
    * chance - the chance of encountering your event at each event point (imagine all other events are not there)
    * triggeredAction - (see ./Event.coffee setTriggerFunction() for details)
        * function - key for function to be fired when your event is activated
        * args - arguments to pass to the activation function
    * sprite - key used to set the sprite (see ./Event.coffee getSprite() for details)
    * criteria - NOT YET IMPLEMENTED, feel free to leave this out for now
 */

PHANTOM_SIGNAL = require("./situations/phantomSignal.coffee");
PHANTOM_SIGNAL2 = require("./situations/phantomSignal2.coffee");
MEDICINE = require("./situations/medicine.coffee");
MEDICINE2 = require("./situations/medicine2.coffee");
SOLAR_FLARE = require("./situations/solarFlare.coffee");
SOLAR_FLARE2 = require("./situations/solarFlare2.coffee");

module.exports = [
    {
        "name": "space-junk",
        "criteria": {
            "locations": ['earth']
        },
        "chance": 0.4,
        "triggeredAction": {
            "function": "switchToModule",
            "args": {
                "moduleName": "debris-encounter"
            }
        },
        "sprite":"randomDebris"
    },{
        "name": "micro-meteroid",
        "criteria":{},
        "chance": 0.6,
        "triggeredAction": {
            "function": "switchToModule",
            "args": {
                "moduleName": "asteroid-mining"
            }
        },
        "sprite": "randomAsteroid"
    },{
        "name": "trading-post",
        "criteria":{},
        "chance": 0.2,
        "triggeredAction": {
            "function": "switchToModule",
            "args": {
                "moduleName": "trader"
            }
        },
        "sprite":"randomStation"
    },{
        "name": "phantom-signal",
        "criteria":{},
        "chance": .1,
        "triggeredAction": {
            "function": "switchToModule",
            "args": {
                "moduleName": "situation",
                "moduleArgs": PHANTOM_SIGNAL
            }
        }
    },{
        "name": "medicine",
        "criteria":{},
        "chance": .1,
        "triggeredAction": {
            "function": "switchToModule",
            "args": {
                "moduleName": "situation",
                "moduleArgs": MEDICINE
            }
        }
    },{
        "name": "solar-flare",
        "criteria":{},
        "chance": .1,
        "triggeredAction": {
            "function": "switchToModule",
            "args": {
                "moduleName": "situation",
                "moduleArgs": SOLAR_FLARE
            }
        }
    },{
        "name": "phantom-signal-two",
        "criteria":{},
        "chance": .1,
        "triggeredAction": {
            "function": "switchToModule",
            "args": {
                "moduleName": "situation",
                "moduleArgs": PHANTOM_SIGNAL2
            }
        }
    },{
        "name": "medicine-two",
        "criteria":{},
        "chance": .1,
        "triggeredAction": {
            "function": "switchToModule",
            "args": {
                "moduleName": "situation",
                "moduleArgs": MEDICINE2
            }
        }
    },{
        "name": "solar-flare-two",
        "criteria":{},
        "chance": .1,
        "triggeredAction": {
            "function": "switchToModule",
            "args": {
                "moduleName": "situation",
                "moduleArgs": SOLAR_FLARE2
            }
        }
    },{
        "name": "solar-flare-two",
        "criteria":{},
        "chance": .1,
        "triggeredAction": {
            "function": "switchToModule",
            "args": {
                "moduleName": "situation",
                "moduleArgs": require("./situations/repairs.coffee")
            }
        }
    }
];