angular.module("morrowindApp").directive('abilityConfig', ['$http', function($http) {
  return {
    scope: {
      abilities: "=",
      propUrl: "=",
      nameStart: "@",
      nameEnd: "@",
      newText: "@",
      deleteText: "@"
    },
    restrict: 'E',
    replace: true,
    templateUrl: '/templates/ability_config',

    link: function($scope, element, attrs) {
      $scope.abilities.forEach(function(ability) {
        ability.frontend_id = ability.id;
      });
      $scope.addAbility = function() {
        $scope.abilities.push({ 
          frontend_id: $scope.getFrontendId(),
          property_modifiers: []
        });
      };

      $scope.removeAbility = function(ability) {
        if(ability.id) {
          // Existing ability -> Delete on Server
          ability._destroy = true;
        } else {
          // Now saved yet -> Just delete from model
          $scope.abilities.splice($scope.abilities.indexOf(ability), 1);
        }
      };

      $scope.getFrontendId = function() {
        var id = 1;
        var conflicts = true;
        while(conflicts) {
          conflicts = false;
          for(var i = 0; i < $scope.abilities.length; ++i) {
            if(id == $scope.abilities[i].frontend_id) {
              ++id;
              conflicts = true;
              break;
            }
          }
        }
        return id;
      };
    }
  };
}]);
