var app = angular.module("morrowindApp");
app.controller('ItemDisplayCtrl', ['$scope', '$window', '$http',
    function($scope, $window, $http) {
      $scope.items = [];
      $scope.init = function(baseUrl) {
        $http.get(baseUrl + '/item_prototypes.json').success(function(items) {
          $scope.items = items;
        });
        $scope.baseUrl = baseUrl;
      };

      $scope.onClick = function(item) {
        $window.location.href= $scope.baseUrl + "/item_prototypes/" + item.id + "/edit";
      };
    }]);
