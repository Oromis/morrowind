angular.module("morrowindApp").directive('itemEditor', ['$http', '$timeout', function($http, $timeout) {
  return {
    restrict: 'EA',
    scope: {
      item: '=',
      itemPrototypes: '=',
      publishUrl: '@',
      onChange: '&',
      onDestroy: '&',
      onCancel: '&'
    },
    templateUrl: '/templates/charsheet_item',
    link: function (scope, element) {
      var itemBackup = null;

      scope.typeaheadOptions = {
        highlight: true
      };

      scope.editor = element.find('.item-editor');

      scope.editor.keypress(function(event) {
        if(event.which === 13) { // Enter
          scope.confirm();
          event.stopPropagation();
        }
      });

      scope.confirm = function() {
        if(typeof scope.item.weight === 'number') {
          scope.onChange({item: scope.item});
          backup(scope.item);
        }
      };

      scope.destroyItem = function() {
        scope.onDestroy({item: scope.item});
      };

      scope.cancel = function () {
        restore(scope.item);
        scope.onCancel({item: scope.item});
      };

      scope.publishItem = function () {
        $http.post(scope.publishUrl, {
          item_prototype: {
            name: scope.item.name,
            type: scope.item.type,
            category: scope.item.category,
            desc: scope.item.desc,
            value: scope.item.value,
            weight: scope.item.weight,
            range: scope.item.range,
            damage: scope.item.damage,
            speed: scope.item.speed,
            two_handed: scope.item.two_handed,
            armor: scope.item.armor,
            armor_type: scope.item.armor_type,
            slot: scope.item.slot
          }
        }).then(function(response) {
          scope.item.prototype_id = response.data.id;
        });
      };

      scope.editor.find('input').click(function (e) {
        $(this)
          .one('mouseup', function() {
            $(this).select();
          })
          .select();
      });

      // Listen for changes to the item.name property (this can be set
      //  to an object by typeahead, user should not see that)
      var revokeNameWatch = scope.$watch('item.name', function(newValue) {
        if(typeof newValue == 'object') {
          var proto = newValue;
          // Reference to an item_prototype -> enter in item
          scope.item.name = proto.name;
          scope.item.prototype_id = proto.id;
          scope.item.weight = proto.weight;
          scope.item.type = proto.type;
          scope.item.damage = proto.damage;
          scope.item.speed = proto.speed;
          scope.item.range = proto.range;
          scope.item.armor = proto.armor;
          scope.item.slot = proto.slot;
          scope.item.value = proto.value;
          scope.item.armor_type = proto.armor_type;
          scope.item.desc = proto.desc;
        }
      });

      element.on('$destroy', function() {
        revokeNameWatch();
      });

      scope.$watch('item', function (newVal, oldVal) {
        if(newVal != null && !newVal._null && oldVal != null && !oldVal._null) {
          restore(oldVal);
        }
        backup(newVal);

        if(newVal._element != null) {
          scope.editor.css('top', $(newVal._element).position().top - 40);
          delete newVal._element;
        }

        if (newVal.name == null || newVal.name === '') {
          var nameInput = element.find('.item-name');
          $timeout(function() {
            nameInput.focus();
          });
        }
      });

      function backup(item) {
        itemBackup = angular.copy(item);
      }

      function restore(item) {
        if(itemBackup != null) {
          angular.extend(item, itemBackup);
        }
      }
    }
  };
}]);
