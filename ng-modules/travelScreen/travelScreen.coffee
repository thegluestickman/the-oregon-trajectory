require('angular');

Tile = require('./Tile.coffee')
Sprite = require('./Sprite.coffee')
Nodule = require('nodule')
Location = require('./../theOregonTrajectory/Location.coffee')

Randy = require('./ng-randy/ng-randy.coffee')

MIN_TRAVELS_PER_EVENT = 1000  # min amount of travel between events
EVENT_VARIABILITY = 10  # affects consistency in event timing. high values = less consistent timing. must be > 0
# units of EVENT_VARIABILITY are fraction of MIN_TRAVELS_PER_EVENT, eg 3 means MIN_TRAV./3

# switching to javascript here...
`
var app = angular.module('travel-screen', [
    require('ng-hold'),
    require('game'),
    require('game-btn')
]);

app.directive("travelScreen", function() {
    return {
        restrict: 'E',
        templateUrl: "ng-modules/travelScreen/travelScreen.html"
    };
});

app.controller("travelScreenController", ['$rootScope', '$scope', 'data', 'music', '$interval', function($rootScope, $scope, data, music, $interval){
    var vm = this;
    vm.data = data;
    vm.randy = new Randy($scope);
    randyTime = 0;
    window.randy = vm.randy;  // for debug
    vm.canvasElement = document.getElementById("travelCanvas");
    vm.ctx = vm.canvasElement.getContext("2d");
    vm.ship = data.ship;

    vm.onEntry = function(){
        $scope.$emit('changeMusicTo', music.ambience);
        vm.startTravel();
    }

    vm.onExit = function(){
        vm.stopTravel()
    }

    // nodule for handling module entry/exit and such
    vm.nodule = new Nodule($rootScope, 'travel-screen', vm.onEntry, vm.onExit);

    var timeoutId;

    vm.init = function(){
        vm.tiles = [new Tile(0, document.getElementById("bg-earth"))];
        vm.sprites = {}
        vm.shipY = 300;
        vm.shipX = 0+vm.ship.w/2;
        vm.travelling = false;
    }
    vm.init();
    $scope.$on('resetGame', vm.init);

    vm.startTravel = function(){
        vm.travelling = true;
        timeoutId = $interval(vm.go, TRAVEL_SPEED);
    }

    vm.go = function(){
        if (vm.travelling) vm.travel();
        else if (typeof timeoutId !== 'undefined') vm.stopTravel();
    }

    // PRIVATE FUNCTION
    var cancelInterval = function() {
        var result = $interval.cancel(timeoutId);
        if (result == true) timeoutId = undefined;
    }

    vm.stopTravel = function(){
        vm.travelling = false;
        cancelInterval();
    }
    $scope.$on('switchToModule', function(switchingTo){
    });

    vm.toggleTravel = function(){
        if (vm.travelling){
            vm.stopTravel();
        } else {
            vm.startTravel();
        }
    };

    vm.getNextTile = function(xpos){
        // if distance travelled to destination big enough, append destination tile, else use filler
        var halfTileWidth = 1000*TRAVELS_PER_MOVE;  // estimated width (should be close to avg) (in moves)
        if (data.nextWaypoint.distance < halfTileWidth ){
            console.log(data.nextWaypoint);
            // TODO: return relevant location tile
            if (data.nextWaypoint.name == 'moon'
                || data.nextWaypoint.name == 'mars'
                || data.nextWaypoint.name == 'ceres'
                || data.nextWaypoint.name == 'jupiter'
                || data.nextWaypoint.name == 'europa'
            ){
                img = document.getElementById(data.nextWaypoint.name);
            } else {
                // filler
                img = document.getElementById("filler");
            }
        } else {
            // filler
            img = document.getElementById("filler");
        }
        // return tile
        return new Tile(xpos, img);
    }

    vm.travel = function(){
        if (data.fuel >= data.fuelExpense) {
            data.travel();

            // move ship to optimal screen position
            if (vm.shipX < vm._getIdealShipPos()) {
                vm.shipX += 1;
                vm.data.distanceTraveled += 1
            } else {
                vm.shipX = vm._getIdealShipPos();
            }

            // move the tiles
            vm.tiles.forEach(function (tile) {
                tile.travel();
            });

            // remove old offscreen tiles
            while (vm.tiles[0].hasTravelledOffscreen()) {
                vm.tiles.splice(0, 1);  // remove leftmost tile
                console.log('tile removed');
            }

            // append new bg tiles if needed
            var overhang = vm.tiles[vm.tiles.length - 1].getOverhang();
            while (overhang < 100) {
                vm.tiles.push(vm.getNextTile(window.innerWidth + overhang));
                overhang = vm.tiles[vm.tiles.length - 1].getOverhang();
                console.log('tile added');
                if (vm.tiles.length > 100){
                    throw new Error('too many tiles!');
                }
            }

            // handle arrival at stations/events
            if (!data.BYPASS_LOCATIONS){
                for (var loc_i in data.locations){
                    var location = data.locations[loc_i];
                    var pos = location.x;
                    var loc = location.name;
                    if (pos < data.distanceTraveled &&
                        data.visited.indexOf(loc) < 0) {  // passing & not yet visited
                        data.visited.push(loc);
                        data.encounter_object = location;  // store the location obj for use by the triggered module
                        console.log('arrived at ', loc);
                        data.locations[loc_i].trigger({'$scope':$scope})
                    }
                }
            }

            // handle random events
            // TODO: if is a good time/place for an event
            if (randyTime > MIN_TRAVELS_PER_EVENT){
                if (randy.roll()){
                    randyTime = 0
                } else {
                    randyTime = MIN_TRAVELS_PER_EVENT/EVENT_VARIABILITY
                }
            } else {
                randyTime += 1
            }
        }
        // TODO: else if within range of shop and have money, switch to shop screen module to buy fuel
        else { // end game
            vm.stopTravel();
            data.end();
        }
    }

    vm.drift = function(height){
        // returns slightly drifted modification on given height
        if (Math.random() < 0.01) {  // small chance of drift
            height += Math.round(Math.random() * 2 - 1);
            if (height > 400) {
                height = 399
            } else if (height < 200) {
                height = 201
            }
        }
        return height;
    }

    vm.drawSprite = function(location){
        // draws location sprite if in view at global Xposition
        // if w/in reasonable draw distance
        var spriteW = 500;  // max sprite width (for checking when to draw)
        var Xposition = location.x + vm.shipX;


        if (data.distanceTraveled + window.innerWidth + spriteW > Xposition    // if close enough
            && data.distanceTraveled - spriteW < Xposition                  ) { // if we haven't passed it
            location.sprite.y = vm.drift(location.sprite.y);
            location.sprite.r += location.sprite.spin;
            var rel_x = Xposition-data.distanceTraveled;
            location.sprite.x = rel_x;
            // use existing y value (add small bit of drift)
            location.sprite.draw(vm.ctx)
        }
    }

    vm.drawLocations = function(){
        for (var loc_i in data.locations){
            try {
                vm.drawSprite(data.locations[loc_i]);
            } catch (err){
                console.log(loc_i, 'of', data.locations.length, data.locations[loc_i]);
            }
        }
    }

    vm.drawBg = function(){
        vm.tiles.forEach(function(tile) {
            tile.draw(vm.ctx);
        });
    }

    vm.drawShip = function(){
        vm.shipY = vm.drift(vm.shipY);
        vm.ship.draw(vm.ctx, vm.shipX, vm.shipY)
    }

    vm.draw = function(){
        // resize element to window
        vm.ctx.canvas.width  = window.innerWidth;  //TODO: only do this when needed, not every draw
        vm.drawBg();
        vm.drawLocations();
        vm.drawShip();
    }
    $scope.$on('draw', vm.draw);

    vm._getIdealShipPos = function(){
        return window.innerWidth / 3
    }

    $scope.$on('encounter', function(ngEvent, event){
        // on random encounter
        // NOTE: ngEvent here is the angular event, "event" is the ng-randy event... (sorry for confuzzlation)
        console.log('adding encounter:', ngEvent, event);
        // TODO: wrap this in data.addLocation method which checks that no locations are too near each other
        vm.data.locations.push(new Location(
            event.name + '_' + event.count,
            vm.data.distanceTraveled + window.innerWidth + 300,
            0,
            ngEvent.name,
            event.doAction,
            event.sprite
        ));
    });
}]);
`
module.exports = angular.module('travel-screen').name

