define(function() {
  'use strict';
  
  return {
    // Creates an enum object => {ENUM: 'ENUM'}
    Enum: function(constantsList) {
      for (var i = 0; i < constantsList.length; i++) {
        var constant = constantsList[i];
        this[constant] = constant;
      }
    }

  };
});
