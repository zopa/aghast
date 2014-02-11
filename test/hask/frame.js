function jsmain() {
    console.log('Testing...');
    var $scope = {};
    Haste['setPhones']($scope);
    console.log($scope);
}
