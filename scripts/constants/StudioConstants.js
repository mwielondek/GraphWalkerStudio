define(['constants/Utils'], function(Utils) {

  var Enum = Utils.Enum;
  var constants = {};

  constants.types = {
    'T_VERTEX': 'vertex',
    'T_EDGE': 'edge',
    'T_MODEL': 'model'
  };

  constants.calls = new Enum([
    'CLEAR_SELECTION'
  ]);

  return constants;
});
