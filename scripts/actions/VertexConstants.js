define(function() {

  // Creates an enum object => {ENUM: 'ENUM'}
  function Enum(constantsList) {
    for (var i = 0; i < constantsList.length; i++) {
      var constant = constantsList[i];
      this[constant] = constant;
    }
  }

  var vertexConstants = [
    'GET_ALL',
    'ADD_VERTEX',
    'DEL_VERTEX',
    'VERTEX_LIST_CHANGED'
  ];

  return new Enum(vertexConstants);
});
