define(function() {

  var constants = {};


  // Keys might not always be the same as values. Change
  // only the values upon GW API change etc.
  constants.methods = {
    'ADDVERTEX': 'addVertex',
    'CHANGEVERTEX': 'changeVertex',
    'ADDEDGE': 'addEdge',
    'CHANGEEDGE': 'changeEdge',
    'START': 'startRunning',
    'NEXT': 'getNextElement',
    'STOP': 'stopRunning'
  }

  return constants;
});
