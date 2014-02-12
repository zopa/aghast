'use strict';

/* Controllers */
function jsmain() {

    var phonecatApp = angular.module('phonecatApp', []);

    phonecatApp.controller('PhoneListCtrl', function ($scope, $http) {
        Haste['setPhones']($scope, $http); 
        });
}
