var app = angular.module("morrowindApp");

app.controller('CharsheetController', ['$scope', '$http', '$timeout',
  function ($scope, $http, $timeout) {
    $scope.char = {
      race: null,
      birthsign: null,
      specialization: null,
      fav_attribute1: null,
      fav_attribute2: null,
      property: {}
    };
    $scope.searchStrings = {};
    $scope.Math = window.Math;
    $scope.itemOrder = 'manual';
    $scope.hideEmpty = true;

    var creationDataFetched = false;
    var defaultDataFetched = false;
    var watchesSetUp = false;

    var actionQueue = [];

    var nullItem = {_null: true};

    var watchedParams = ['name', 'health', 'stamina', 'mana',
      'location', 'day', 'month',
      'mana_mult_buff', 'wounds', 'rolled_damage_right',
      'rolled_damage_left', 'armor_buff', 'damage_incoming',
      'offensive_buff', 'defensive_buff', 'evasion_buff', 'max_health',
      'speed_buff', 'initiative_roll', 'notes', 'level', 'level_count'];
    var watchedCollections = [
      {
        name: 'attributes',
        id: 'id',
        serverKey: 'character_properties_attributes',
        properties: ['points_buff', 'points_gained']
      },
      {
        name: 'skills',
        id: 'id',
        serverKey: 'character_properties_attributes',
        properties: ['points_buff', 'points_gained',
          'points_offensive', 'points_defensive']
      },
      {
        name: 'resistances',
        id: 'id',
        serverKey: 'character_properties_attributes',
        properties: ['points_buff']
      }
    ];

    $scope.itemTypes = [
      { id: 'melee_weapon', name: 'Nahkampf' },
      { id: 'ranged_weapon', name: 'Fernkampf' },
      { id: 'armor', name: 'Rüstung' },
      { id: 'consumable', name: 'Verbrauch' },
      { id: 'accessory', name: 'Accessoire' },
      { id: 'generic', name: 'Sonst.' }
    ];

    // The latest version of the char from the server
    var serverChar = {};

    $scope.init = function (charUrl, skillUrl, itemsUrl, slotUrl,
                            spellUrl, levelUpUrl, resources) {
      $scope.resources = resources;
      $scope.updateUrl = charUrl;
      $scope.skillUrl = skillUrl;
      $scope.itemsUrl = itemsUrl;
      $scope.slotUrl = slotUrl;
      $scope.spellUrl = spellUrl;
      $scope.levelUpUrl = levelUpUrl;
      $http.get(charUrl).success(charFromServer);
    };

    $scope.onCharacterUpdate = function(params) {
      $http.put($scope.updateUrl, { character: params })
        .then(responseToChar, restoreChar);
    };

    $scope.modifySkill = function(skill, delta) {
      doSafely(function() {
        $http.put($scope.skillUrl, {skill_id: skill.id, delta: delta})
          .then(responseToChar, restoreChar);
      });
    };

    $scope.addSpell = function (spellId) {
      doSafely(function () {
        $http.put($scope.spellUrl, {spell_id: spellId, perform: 'add'})
          .then(responseToChar, restoreChar);
      });
    };

    $scope.removeSpell = function (spell) {
      doSafely(function () {
        $http.put($scope.spellUrl, {spell_id: spell.id, perform: 'destroy'})
          .then(responseToChar, restoreChar);
      });
    };

    $scope.formatMultiplier = function(count) {
      if(count <= 3) {
        return Array(count + 1).join('*');
      } else {
        return count + '*';
      }
    };

    $scope.editingItem = nullItem;

    $scope.addItem = function(container, type, event) {
      type = type || null;
      var item = {
        quantity: 1,
        weight: 0,
        value: 0,
        type: type,
        condition: 100,
        index: container.items.length,
        container: container.key
      };
      container.items.push(item);
      if(type) {
        container.itemsByType[type].push(item);
      }
      $scope.editItem(item, event);
    };

    $scope.updateItem = function(item) {
      doSafely(function () {
        $http.put($scope.itemsUrl, { item: item })
          .then(responseToChar, restoreChar);
      });
      $scope.editingItem = nullItem;
    };

    $scope.destroyItem = function(item) {
      for(var i = 0; i < $scope.char.containers.length; ++i) {
        var container = $scope.char.containers[i];
        container.items.remove(item);
        if(item.type) {
          container.itemsByType[item.type].remove(item);
        }
      }

      if(item.id != null) {
        item._destroy = true;
        $scope.updateItem(item);
      }

      $scope.editingItem = nullItem;
    };

    $scope.editItem = function (item, event) {
      item._element = event.target;
      $scope.editingItem = item;
    };

    $scope.cancelItemEdit = function () {
      $scope.editingItem = nullItem;
    };

    $scope.itemSelected = function (slot, item) {
      doSafely(function () {
        var itemId = null;
        if(item) {
          itemId = item.id;
        }
        $http.put($scope.slotUrl, { slot_id: slot.id, item_id: itemId})
          .then(responseToChar, restoreChar);
      });
    };

    $scope.skillControlListeners = {
      accept: function (sourceItemScope, destScope) {
        var max = parseInt(destScope.element.attr('data-max')) || 0;
        if(destScope.modelValue.indexOf(sourceItemScope.modelValue) != -1) {
          // Already belongs here
          return true;
        }
        return destScope.modelValue.length < max;
      },
      itemMoved: function (event) {
        doSafely(function() {
          var skill = event.source.itemScope.modelValue;

          // Change the skill's type and index
          skill.skill_type = event.dest.sortableScope.element.attr('data-skill-type');
          skill.order = event.dest.index;

          // Update the order value and send changes to server
          var sourceItems = event.source.sortableScope.modelValue;
          var destItems = event.dest.sortableScope.modelValue;

          // Change order of all items after the removed element
          // (their index should change by -1) and after the inserted element
          // (their index should change by +1)
          var changelog = [];
          updateSkillOrder(sourceItems, changelog, event.source.index);
          updateSkillOrder(destItems, changelog, event.dest.index + 1);

          // Update the item that actually changed
          changelog.push({
            id: skill.id,
            order: skill.order,
            skill_type: skill.skill_type
          });

          sendUpdatedSkills(changelog);
        });
      },
      orderChanged: function(event) {
        doSafely(function() {
          // Update the order value of all affected skills and send
          // them to the server
          var skills = event.source.sortableScope.modelValue;
          var changelog = [];
          var indices = [event.source.index, event.dest.index].
            sort(function(a,b) { return a - b; });
          updateSkillOrder(skills, changelog, indices[0], indices[1]);

          // Send server update
          sendUpdatedSkills(changelog);
        });
      }
    };

    $scope.itemControlListeners =
    {
      accept: function () { return true; },
      itemMoved: function (event) {
        doSafely(function() {
          var item = event.source.itemScope.modelValue;

          // Change the item's container and index
          item.container = event.dest.sortableScope.element.attr('container');
          item.index = event.dest.index;

          // Update the index values and send changes to server
          var sourceItems = event.source.sortableScope.modelValue;
          var destItems = event.dest.sortableScope.modelValue;

          // Change order of all items after the removed element
          // (their index should change by -1) and after the inserted element
          // (their index should change by +1)
          var changelog = [];
          updateItemOrder(sourceItems, changelog, event.source.index);
          updateItemOrder(destItems, changelog, event.dest.index + 1);

          // Update the item that actually changed
          changelog.push({
            id: item.id,
            index: item.index,
            container: item.container
          });

          sendUpdatedItems(changelog);
        });
      },
      orderChanged: function(event) {
        doSafely(function() {
          // Update the order value of all affected skills and send
          // them to the server
          var items = event.source.sortableScope.modelValue;
          var changelog = [];
          var indices = [event.source.index, event.dest.index].
            sort(function(a,b) { return a - b; });
          updateItemOrder(items, changelog, indices[0], indices[1]);

          // Send server update
          sendUpdatedItems(changelog);
        });
      }
    };

    $scope.$watch('communicating', function (newVal) {
      if(!newVal) {
        // Execute deferred actions
        while(actionQueue.length > 0 && !$scope.communicating) {
          actionQueue.shift()();
        }
      }
    });

    $scope.newSpell = '';
    $scope.$watch('newSpell', function (newVal) {
      if(typeof newVal === 'object') {
        // Actual Spell selected
        var spell = newVal;
        $scope.addSpell(spell.id);
        $scope.newSpell = '';
      }
    });

    $scope.$watch('itemOrder', function (newVal) {
      if($scope.char != null && $scope.char.containers != null) {
        jQuery.each($scope.char.containers, function (i, container) {
          orderItems(container.items, newVal);
        });
      }
    });

    // Level up stuff
    $scope.levelUpAttributes = [];

    $scope.initLevelUp = function () {
      $scope.levelUpAttributes = [];
      $scope.char.level_up_mode = true;
      for(var i = 0; i < $scope.char.attributes.length; ++i) {
        $scope.char.attributes[i].levelUpSelected = false;
      }
    };

    $scope.abortLevelUp = function () {
      $scope.char.level_up_mode = false;
      $scope.levelUpAttributes = [];
    };

    $scope.addLevelUpAttribute = function (attr) {
      var abbr = attr.abbr;
      if($scope.levelUpAttributes.length < 3 && $scope.levelUpAttributes.indexOf(abbr) < 0) {
        $scope.levelUpAttributes.push(abbr);
        attr.levelUpSelected = true;
      }
    };

    $scope.finishLevelUp = function() {
      $scope.char.level_up_mode = false;
      doSafely(function () {
        $http.post($scope.levelUpUrl, {
          attributes: $scope.levelUpAttributes
        }).then(responseToChar, restoreChar);
      });
    };

    $scope.resiHpLoss = function(resi) {
      var dmg = resi.dmg || 0;
      var reduction = (resi.points / 100.0) || 0;
      var blocked = dmg * reduction;
      return Math.ceil(dmg - blocked);
    };

    $scope.strToNum = function (str) {
      if(str != null && typeof str === 'string') {
        return parseFloat(str.replace(/,/g, '.'));
      }
      return 0;
    };

    $scope.takeDamage = function (damage) {
      if(typeof(damage) !== 'number') {
        damage = $scope.strToNum(damage);
      }
      $scope.char.health -= Math.ceil(damage);
    };

    $scope.mod = function(n, m) {
      return ((n % m) + m) % m;
    };

    $scope.spellSuccessful = function (spell) {
      $scope.char.mana -= spell.mana_cost;
    };

    $scope.spellFailed = function (spell) {
      $scope.char.mana -= spell.mana_cost;
      $scope.char.stamina -= 20;
    };

    // -----------------------------------------------------------------------
    // Utility functions
    // -----------------------------------------------------------------------

    function doSafely(func) {
      if($scope.communicating) {
        actionQueue.push(func);
      } else {
        func();
      }
    }

    // watch end of digest cycle to update the server char
    function postDigest(callback){
      var unregister = $scope.$watch(function(){
        unregister();
        $timeout(function(){
          callback();
          postDigest(callback);
        }, 0, false);
      });
    }

    var charChangelog = {};

    // triggered after a digest cycle
    postDigest(function() {
      if(Object.keys(charChangelog).length > 0) {
        // Something changed -> Update the server
        console.log(JSON.stringify(charChangelog, null, 2));
        $scope.onCharacterUpdate(charChangelog);
        charChangelog = {};
      }
    });

    function valueChanged(properties) {
      angular.merge(charChangelog, properties);
    }

    function restoreChar() {
      charFromServer(serverChar);
    }

    function charFromServer(data) {
      serverChar = angular.copy(data);
      // Merge result json back into character model to get updated values
      // from the server
      angular.merge($scope.char, data);

      // Deleted spells / updated items are not recognized without this
      $scope.char.spells = data.spells;
      $scope.char.containers = data.containers;

      sortSkills();
      sortItems();
      sortAttributes();

      if(!creationDataFetched && $scope.char.creating) {
        // Fetch additional data needed for character creation
        creationDataFetched = true;
      }
      if(!defaultDataFetched) {
        // Fetch default resources
        fetchResource('attributes');
        fetchResource('item_prototypes');
        fetchResource('spells');
        defaultDataFetched = true;
      }

      if(!watchesSetUp) {
        setupPropertyWatches();
        setupCollectionWatches();
        watchesSetUp = true;
      }

      var now = $scope.now();
      console.log("Processing time: " + Math.floor(now - $scope.requestEnd) + "ms");
      console.log("Total time: " + Math.floor(now - $scope.requestStart) + "ms");
    }

    function sortAttributes() {
      for(var i = 0; i < $scope.char.attributes.length; ++i) {
        var attr = $scope.char.attributes[i];
        $scope.char.property[attr.abbr] = attr;
      }
    }

    function sortSkills() {
      $scope.char.sortedSkills = {
        major: [],
        minor: [],
        other: []
      };
      $scope.char.weaponSkills = [];
      $scope.char.schools = [];

      for(var i = 0; i < $scope.char.skills.length; ++i) {
        var skill = $scope.char.skills[i];
        insertSortedSkill($scope.char.sortedSkills[skill.skill_type], skill);
        if(skill.weapon_skill) {
          $scope.char.weaponSkills.push(skill);
        }
        if(skill.is_school_of_magic) {
          $scope.char.schools.push(skill);
        }
        $scope.char.property[skill.abbr] = skill;
      }
      $scope.char.weaponSkills.sort(function(a,b) {
        if(a.skill_type == b.skill_type) {
          return a.order - b.order;
        } else if(a.skill_type == 'major') {
          return -1;
        } else if(a.skill_type == 'minor') {
          return b.skill_type == 'major' ? 1 : -1;
        } else {
          return 1;
        }
      });

      // Update all skill's indices to make them consistent
      // (all skill lists should start with order = 0)
      var changelog = [];
      for(var skillType in $scope.char.sortedSkills) {
        if($scope.char.sortedSkills.hasOwnProperty(skillType)) {
          var skillsOfType = $scope.char.sortedSkills[skillType];
          updateSkillOrder(skillsOfType, changelog);
        }
      }

      // Let the server know that we reordered his stuff.
      sendUpdatedSkills(changelog);
    }

    function sortItems() {
      $scope.char.itemsBySlot = {};
      var itemsById = {};
      jQuery.each($scope.char.containers, function (i, container) {
        container.itemsByType = {
          melee_weapon: [],
          ranged_weapon: [],
          armor: [],
          generic: [],
          accessory: [],
          consumable: []
        };
        jQuery.each(container.items, function (j, item) {
          var arr = container.itemsByType[item.type];
          if(arr != null) {
            arr.push(item);
          }
          itemsById[item.id] = item;
          if(item.slot != null && (item.type == 'melee_weapon' ||
              item.type == 'ranged_weapon' || item.type == 'armor' ||
              item.type == 'accessory')) {
            if(!$scope.char.itemsBySlot[item.slot]) {
              $scope.char.itemsBySlot[item.slot] = [];
            }
            $scope.char.itemsBySlot[item.slot].push(item);
          }
        });
        orderItems(container.items, $scope.itemOrder);
      });

      for(var i = 0; i < $scope.char.slots.length; ++i) {
        var slot = $scope.char.slots[i];
        if(slot.item != null) {
          slot.item = itemsById[slot.item];
        }
      }
    }

    function orderItems(items, order) {
      switch (order) {
        case 'manual':
          items.sort(function (a, b) {
            return a.index - b.index;
          });
          break;

        case 'weight':
          items.sort(function (a, b) {
            return b.total_weight - a.total_weight;
          });
          break;

        case 'value':
          items.sort(function (a, b) {
            return b.total_value - a.total_value;
          });
          break;

        case 'name':
          items.sort(function (a, b) {
            return a.name.localeCompare(b.name);
          });
          break;
      }
    }

    function setupPropertyWatches() {
      for(var i = 0; i < watchedParams.length; ++i) {
        (function() {
          var param = watchedParams[i];
          $scope.$watch('char.' + param, function (newValue) {
            // Check if the value is actually unknown to the server
            //  (to avoid too many unnecessary requests)
            if(newValue != serverChar[param]) {
              // This actually is a new value -> send to server
              var args = {};
              args[param] = newValue;
              valueChanged(args);
            }
          });
        })();
      }
    }

    function setupCollectionWatches() {
      for(var i = 0; i < watchedCollections.length; ++i) {
        var collection = watchedCollections[i];
        for(var j = 0; j < $scope.char[collection.name].length; ++j) {
          for(var prop = 0; prop < collection.properties.length; ++prop) {
            (function () {
              var fixedCollection = collection;
              var item = j;
              var property = collection.properties[prop];
              $scope.$watch('char.' + collection.name + '[' + j + '].' + collection.properties[prop],
                function(newValue) {
                  if(newValue != serverChar[fixedCollection.name][item][property]) {
                    var args = {};
                    var inner = {
                      id: $scope.char[fixedCollection.name][item][fixedCollection.id]
                    };
                    inner[property] = newValue;
                    args [fixedCollection.serverKey] = [inner];

                    valueChanged(args);
                  }
                });
            })();
          }
        }
      }
    }

    function fetchResource(name) {
      $http.get($scope.resources[name]).success(function(data) {
        $scope[name] = data;
        if(name == 'item_prototypes') {
          var searchEngine = new Bloodhound({
            local: data,
            queryTokenizer: Bloodhound.tokenizers.whitespace,
            datumTokenizer: function(datum) { return Bloodhound.tokenizers.whitespace(datum.name) }
          });
          searchEngine.initialize();
          $scope.itemPrototypesEngine = {
            source: searchEngine.ttAdapter(),
            displayKey: 'name'
          };
        }
        if(name == 'spells') {
          var searchEngine = new Bloodhound({
            local: data,
            queryTokenizer: Bloodhound.tokenizers.whitespace,
            datumTokenizer: function(datum) { return Bloodhound.tokenizers.whitespace(datum.name) }
          });
          searchEngine.initialize();
          $scope.spellsEngine = {
            source: searchEngine.ttAdapter(),
            displayKey: 'name'
          };
        }
      });
    }

    $scope.spellsEngine = {
      source: {},
      displayKey: 'name'
    };

    function updateSkillOrder(skills, changelog, start, end) {
      updateOrder(skills, changelog, 'order', start, end);
    }

    function updateItemOrder(items, changelog, start, end) {
      updateOrder(items, changelog, 'index', start, end);
    }

    function updateOrder(items, changelog, property, start, end) {
      start = start || 0;
      end = end || items.length - 1;
      for(var i = start; i <= end; ++i) {
        if(items[i][property] != i) {
          items[i][property] = i;
          var change = { id: items[i].id };
          change[property] = i;
          changelog.push(change);
        }
      }
    }

    function sendUpdatedSkills(changelog) {
      if(changelog.length > 0) {
        valueChanged({character_properties_attributes: changelog});
      }
    }

    function sendUpdatedItems(changelog) {
      if(changelog.length > 0) {
        valueChanged({items_attributes: changelog});
      }
    }

    function insertSortedSkill(array, skill) {
      function locationOf(array, skill, start, end) {
        start = start || 0;
        end = end || array.length;
        var pivot = Math.floor(start + (end - start) / 2);
        if(start == end || array[pivot].order === skill.order) {
          return pivot;
        }
        if (end - start <= 1) {
          return array[pivot].order > skill.order ? start : start + 1;
        }

        if (array[pivot].order < skill.order) {
          return locationOf(array, skill, pivot, end);
        } else {
          return locationOf(array, skill, start, pivot);
        }
      }
      array.splice(locationOf(array, skill), 0, skill);
    }

    function responseToChar(response) {
      $scope.requestEnd = $scope.now();
      console.log("Request time: " + Math.floor($scope.requestEnd - $scope.requestStart) + "ms");
      charFromServer(response.data);
    }
  }]);

