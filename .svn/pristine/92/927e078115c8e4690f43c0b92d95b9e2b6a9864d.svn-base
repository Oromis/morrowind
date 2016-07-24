angular.module('morrowindApp').directive('propertyModifierConfig', ['$http', function($http) {
  return {
    scope: {
      mods: "=",
      propUrl: "=",
      nameStart: "@",
      nameEnd: "@",
      newText: "@",
      deleteText: "@"
    },
    restrict: 'E',
    replace: true,
    templateUrl: '/templates/property_modifier_config',

    link: function($scope, element, attrs) {
      var dataArrived = 1;
      $scope.modifiers = $scope.mods;
      $http.get($scope.propUrl).success(function(data) {
        $scope.properties = data;
          if(++dataArrived >= 2) {
            $scope.updateAbbreviations($scope);
          }
        });
      
      $scope.addModifier = function() {
        $scope.modifiers.push({ frontend_id: $scope.getFrontendId() });
      };

      $scope.removeModifier = function(modifier) {
        if(modifier.id) {
          // Existing modifier -> Delete on Server
          modifier._destroy = true;
        } else {
          // Now saved yet -> Just delete from model
          $scope.modifiers.splice($scope.modifiers.indexOf(modifier), 1);
        }
      };

      $scope.abbrChanged = function(mod) {
        var property = $scope.properties[mod.property_abbr];
        if(property) {
          mod.property_id = property.id;
          mod.property_img = {
            'background-image': 'url(' + property.icon + ')'
          };
        } else {
          mod.property_id = undefined;
          mod.property_img = { 
            'background-image': 'none'
          };
        }
      };

      $scope.updateAbbreviations = function() {
        $scope.modifiers.forEach(function(mod) {
          var property = $scope.getProperty(mod.property_id);
          if(property) {
            mod.property_abbr = property.abbr;
            $scope.abbrChanged(mod);
          }
          mod.frontend_id = mod.id;
        });
      };

      $scope.getProperty = function(id) {
        for(var abbr in $scope.properties) {
          if($scope.properties[abbr].id == id) {
            return $scope.properties[abbr];
          }
        }
        return null;
      };

      $scope.getFrontendId = function() {
        var id = 1;
        var conflicts = true;
        while(conflicts) {
          conflicts = false;
          for(var i = 0; i < $scope.modifiers.length; ++i) {
            if(id == $scope.modifiers[i].frontend_id) {
              ++id;
              conflicts = true;
              break;
            }
          }
        }
        return id;
      }; 
    }
  }
}]);

