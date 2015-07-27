define(['./ConnectionActions'], function(connection) {

  return {

    sendRequestRaw: function(request, callback) {
      // Add unique request ID
      request['requestId'] = Math.random().toString(36).substr(2);
      connection.send(JSON.stringify(request));
      // Wait for relevant response
      connection.readUntil(function(message) {
        if (message['requestId'] == request['requestId']) {
          callback(message);
          return true; // stop listening
        }
      });
    },
    sendRequest: function(request, onsuccess, onerror) {
      this.sendRequestRaw(request, function(response) {
        if (response.success) {
          onsuccess(response);
        } else {
          onerror(response);
        }
      });
    }

  }
})
