define(function() {

  // Creates an enum object => {ENUM: 'ENUM'}
  function Enum(constantsList) {
    for (var i = 0; i < constantsList.length; i++) {
      var constant = constantsList[i];
      this[constant] = constant;
    }
  }

  var constants = {};

  constants.calls = new Enum([
    'GET_ALL',
    'GET_MODEL',
    'ADD_MODEL',
    'REMOVE_MODEL',
    'CHANGE_MODEL'
  ]);

  constants.events = new Enum([
    'MODEL_LIST_CHANGED'
  ]);


  return constants;
});
