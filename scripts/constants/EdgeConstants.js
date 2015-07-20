define(function() {

  // Creates an enum object => {ENUM: 'ENUM'}
  function Enum(constantsList) {
    for (var i = 0; i < constantsList.length; i++) {
      var constant = constantsList[i];
      this[constant] = constant;
    }
  }

  var constants = {};

  // IDEA: change below to POJO in order to be able to change the value without
  // changing the key in case of value collisions. Applies to all Constants files.
  constants.calls = new Enum([
    'GET_ALL_EDGES',
    'GET_EDGE',
    'ADD_EDGE',
    'REMOVE_EDGE',
    'CHANGE_EDGE'
  ]);

  constants.events = new Enum([
    'EDGE_LIST_CHANGED'
  ]);

  constants.status = new Enum([
    'UNVERIFIED',
    'VERIFIED',
    'ERROR'
  ]);


  return constants;
});
