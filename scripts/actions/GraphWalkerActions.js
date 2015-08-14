define(['./ConnectionActions', './VertexActions', 'constants/GraphWalkerConstants', 'constants/StudioConstants'],
function() {
  'use strict';

  var $               = require('jquery');
  var connection      = require('actions/ConnectionActions');
  var Constants       = require('constants/GraphWalkerConstants');
  var RiotControl     = require('app/RiotControl');
  var EdgeActions     = require('actions/EdgeActions');
  var VertexActions   = require('actions/VertexActions');
  var StudioConstants = require('constants/StudioConstants');

  var METHODS = Constants.methods;
  var STATUS  = StudioConstants.status;

  var RUN_DELAY = 500;

  var _sendRequestRaw = function(request, callback) {
    // Add unique request ID
    request['requestId'] = Math.random().toString(36).substr(2);
    connection.send(JSON.stringify(request));
    // Wait for relevant response
    connection.readUntil(function(message) {
      if (message['requestId'] === request['requestId']) {
        callback(message);
        return true; // stop listening
      }
    });
  };

  var _sendRequest = function(request, onsuccess, onerror) {
    _sendRequestRaw(request, function(response) {
      if (response.success) {
        onsuccess && onsuccess(response);
      } else {
        onerror && onerror(response);
      }
    });
  };

  var _getNextElement = function(callback) {
    // Prepare server request
    var request = {
      command: METHODS.NEXT,
    };
    _sendRequest(request,
      // On success
      function(response) {
        callback(true, response.body);
        if (response.body.next) {
          setTimeout(function () {
            _getNextElement(callback);
          }, RUN_DELAY);
        }
      },
      // On error
      function(response) {
        callback(false, response.body.error);
      }
    );
  };

  return {
    addVertex: function(newVertex) {
      // Prepare server request
      var request = {
        command: METHODS.ADDVERTEX
      };
      _sendRequest(request,
        // On success
        function(response) {
          VertexActions.setProps(newVertex, {id: response.body.id, status: STATUS.VERIFIED});
        },
        // On error
        function(response) {
          VertexActions.setProps(newVertex, {status: STATUS.ERROR});
        }
      );
    },
    changeVertex: function(vertexId, props) {
      // Prepare server request
      var request = {
        command: METHODS.CHANGEVERTEX,
        id: vertexId,
        properties: props
      };
      // Mark as unverified
      VertexActions.setProps(vertexId, {status: STATUS.UNVERIFIED});
      _sendRequest(request,
        // On success
        function(response) {
          VertexActions.setProps(vertexId, {errorMessage: null, status: STATUS.VERIFIED});
        },
        // On error
        function(response) {
          VertexActions.setProps(vertexId, {errorMessage: response.body.error, status: STATUS.ERROR});
        }
      );
    },
    removeVertex: function(vertexId) {
      // TODO
    },
    addEdge: function(newEdge) {
      // Prepare server request
      var request = {
        command: METHODS.ADDEDGE
      };
      _sendRequest(request,
        // On success
        function(response) {
          EdgeActions.setProps(newEdge, {id: response.body.id, status: STATUS.VERIFIED});
        },
        // On error
        function(response) {
          EdgeActions.setProps(newEdge, {status: STATUS.ERROR});
        }
      );
    },
    changeEdge: function(edgeId, props) {
      // Prepare server request
      var request = {
        command: METHODS.CHANGEEDGE,
        id: edgeId,
        properties: props
      };
      // Mark as unverified
      EdgeActions.setProps(edgeId, {status: STATUS.UNVERIFIED});
      _sendRequest(request,
        // On success
        function(response) {
          EdgeActions.setProps(edgeId, {errorMessage: null, status: STATUS.VERIFIED});
        },
        // On error
        function(response) {
          EdgeActions.setProps(edgeId, {errorMessage: response.body.error, status: STATUS.ERROR});
        }
      );
    },
    removeEdge: function(edgeId) {
      // TODO
    },
    startRunningModel: function(modelId, callback) {
      // Prepare server request
      var request = {
        command: METHODS.START,
        id: modelId
      };
      var _this = this;
      _sendRequest(request,
        // On success
        function(response) {
          _getNextElement(callback);
        },
        // On error
        function(response) {
          callback(false, response.body.error);
        }
      );
    },
    stopRunningModel: function() {
      _sendRequest({command: METHODS.STOP});
    }
  }
})
