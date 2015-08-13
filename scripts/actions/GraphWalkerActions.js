define(['./ConnectionActions', './VertexActions', 'constants/GraphWalkerConstants', 'constants/VertexConstants'],
function(connection, VertexActions, Constants, VertexConstants) {
  'use strict';

  var METHODS = Constants.methods;
  var STATUS  = VertexConstants.status;

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

  return {
    sendRequest: function(request, onsuccess, onerror) {
      _sendRequestRaw(request, function(response) {
        if (response.success) {
          onsuccess(response);
        } else {
          onerror(response);
        }
      });
    },
    addVertex: function(newVertex) {
      // Prepare server request
      var request = {
        command: METHODS.ADDVERTEX
      };
      this.sendRequest(request,
        // On success
        function(response) {
          VertexActions.setProps(newVertex, {label: response.body.id, id: response.body.id, status: STATUS.VERIFIED});
        },
        // On error
        function(response) {
          VertexActions.setProps(newVertex, {id: response.body.id, status: STATUS.ERROR});
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
      this.sendRequest(request,
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
    }
  }
})
