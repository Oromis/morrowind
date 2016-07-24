angular.module("morrowindApp").controller('ItemFormCtrl', ['$scope', '$window',
function($scope, $window) {
  $scope.item = {
  };
  $scope.init = function() {
    $scope.item = $window.item;
  };
  $scope.$watch("item.type", function(newType, oldType) {
    if($scope.isWeapon(newType)) {
      $scope.setSlot('hand');
    } else if(newType == 'armor') {
      $scope.setSlot('chest');
    } else if(newType == 'accessory') {
      $scope.setSlot('neck');
    } else if(!$scope.isWearable(newType)) {
      $scope.setSlot(null);
    }
  });
  $scope.isWeapon = function(type) {
    return type == 'ranged_weapon' ||
           type == 'melee_weapon';
  };
  $scope.isWearable = function(type) {
    return $scope.isWeapon(type) ||
           type == 'armor' ||
           type == 'accessory';
  };
  $scope.setSlot = function(slot) {
    $scope.item.slot = slot;
  };
}]);
