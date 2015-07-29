define(['constants/Utils'], function(Utils) {

  var Enum = Utils.Enum;
  var constants = {};

  constants.calls = new Enum([
    'GET_ALL',
    'GET_VERTEX',
    'ADD_VERTEX',
    'REMOVE_VERTEX',
    'CHANGE_VERTEX'
  ]);

  constants.events = new Enum([
    'VERTEX_LIST_CHANGED'
  ]);

  constants.status = new Enum([
    'UNVERIFIED',
    'VERIFIED',
    'ERROR'
  ]);


  return constants;
});
