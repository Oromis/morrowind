angular.module("morrowindApp").directive('charEquipSlot', function() {
  return {
    restrict: 'EA',
    scope: {
      slot: '=',
      items: '=',
      char: '=',
      weapon: '=',
      index: '@',
      onItemSelected: '&',
      onUpdateItem: '&'
    },
    templateUrl: '/templates/char_equip_slot',
    link: function (scope, element) {
      scope.itemSelected = function(item) {
        scope.toggleMenu();
        scope.onItemSelected({item: item, slot: scope.slot});
      };

      scope.toggleMenu = function() {
        scope.showMenu = !scope.showMenu;
      };

      scope.updateItem = function(item) {
        scope.onUpdateItem({item: item});
      };
    }
  };
});