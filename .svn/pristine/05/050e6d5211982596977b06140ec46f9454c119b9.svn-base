var app = angular.module("morrowindApp");
app.controller('SpellDisplayCtrl', ['$scope', '$window', '$http', 
    function($scope, $window, $http) {
      $scope.spells = [];
      $scope.init = function(baseUrl, icons) {
        $http.get(baseUrl + '/spells.json').success(function(spells) {
          $scope.spells = spells;
        });
        $scope.icons = icons;
        $scope.baseUrl = baseUrl;
      };

      $scope.onClick = function(spell) {
        $window.location.href = $scope.baseUrl + "/spells/" + spell.id + "/edit";
      };
    }]);
