var app = angular.module("morrowindApp");
app.controller('RaceFormController', ['$scope', '$http', '$window',
function($scope, $http, $window) {
  $scope.race = {};
  $scope.init = function() {
    $scope.race = $window.race;
  };
}]);

app.controller('RaceIndexController', ['$scope', '$timeout',
  function ($scope, $timeout) {
    $scope.mode = 'attributes';

    $scope.modeChanged = function() {
    };

    $timeout(function() {
      $scope.modeChanged();
    }, 500);
  }]);
