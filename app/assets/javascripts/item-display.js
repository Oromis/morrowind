var app = angular.module("morrowindApp");
app.controller('ItemDisplayCtrl', ['$scope', '$window', '$http',
    function($scope, $window, $http) {
      $scope.items = [];
      $scope.init = function(baseUrl) {
        $http.get(baseUrl + '/item_prototypes.json').then(function(response) {
          $scope.items = response.data;
        });
        $scope.baseUrl = baseUrl;
      };
    }]);
