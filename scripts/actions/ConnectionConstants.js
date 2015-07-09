define(function() {

  // Creates an enum object => {ENUM: 'ENUM'}
  function Enum(constantsList) {
    for (var i = 0; i < constantsList.length; i++) {
      var constant = constantsList[i];
      this[constant] = constant;
    }
  }

  var constants = {};

  constants.actions = new Enum([
    'CONNECTION_ESTABLISHED',
    'CONNECTION_CLOSED',
    'GET_WEBSOCKET',
    'CONNECT',
    'SEND',
    'READ'
  ]);


  return constants;
});
