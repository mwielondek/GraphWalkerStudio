<connection-pane class="panecontainer">
  <h4>Settings</h4>

  <h5>Connect to GraphWalker</h5>
  <ul>
    <li>URL: <input name="ws_url" />
    <button onclick="{ toggleConnection }">{ connected ? 'Disconnect' : 'Connect' }</button></li>
    <li><textarea name="output" readonly="true"></textarea></li>
  </ul>

  var ConnectionActions = require('actions/ConnectionActions');

  this.connected = false;

  var _this = this;
  this.on("mount", function() {
    // Set up connection listeners
    ConnectionActions.addConnectionListener({
      onopen: function(websocket) {
        _this.write('connection opened');
        _this.connected = true;
        _this.update();
      },
      onclose: function() {
        _this.write('disconnected');
        _this.connected = false;
        _this.update();
      },
      onmessage: function(message) {
        _this.write(JSON.stringify(message));
      }
    });
  });

  toggleConnection() {
    this.connected ? this.disconnect() : this.connect();
  }
  connect() {
    var url = this.ws_url.value || (window.debug ? 'ws://localhost:9999' : '');
    this.write('connecting to', url);

    ConnectionActions.isSocketOpen(function(isOpen) {
      // Close existing connection before connecting anew
      if (isOpen) ConnectionActions.disconnect();
      ConnectionActions.connect(url);
    });
  }
  disconnect() {
    ConnectionActions.disconnect();
  }
  write() {
    this.output.value += '\n' + [].slice.call(arguments, 0).join(' ');
  }
</connection-pane>
