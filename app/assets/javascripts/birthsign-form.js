angular.module("morrowindApp").controller('BirthsignFormController', ['$scope', '$http', '$window',
function($scope, $http, $window) {
  $scope.birthsign = {};
  $scope.init = function() {
    $scope.birthsign = $window.birthsign;
  };
}]);
