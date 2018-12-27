var app = angular.module("morrowindApp");
app.controller('SpellDisplayCtrl', ['$scope', '$window', '$http', 
    function($scope, $window, $http) {
      $scope.spells = [];
      $scope.init = function(baseUrl, icons) {
        $http.get(baseUrl + '/spells.json').then(function(response) {
          $scope.spells = response.data;
        });
        $scope.icons = icons;
        $scope.baseUrl = baseUrl;
      };

      $scope.onClick = function(spell) {
        $window.location.href = $scope.baseUrl + "/spells/" + spell.id + "/edit";
      };
    }]);
