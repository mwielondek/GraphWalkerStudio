<connection-subpane>
  <h5>GraphWalker settings</h5>
  <ul>
    <li>URL: <input name="ws_url" disabled="{ connected }" type="text" />
    <button class="connect" onclick="{ toggleConnection }">{ connected ? 'Disconnect' : 'Connect' }</button></li>
    <li><a href="" onclick={ toggle('showTextarea') }>{showTextarea ? 'Hide' : 'Show'} connection log</a></li>
    <li show={showTextarea}><textarea name="output" readonly="true"></textarea></li>
  </ul>

  <style scoped>
    button.connect {
      width: 70px;
    }

    textarea[name='output'] {
      width: 235px;
      min-height: 100px;
      resize: vertical;
      border: 0;
      outline: none;
    }
  </style>

  var ConnectionActions = require('actions/ConnectionActions');
  this.mixin('tagUtils');

  this.connected = false;
  this.showTextarea = false;


  var _this = this;
  this.on("mount", function() {
    _this.ws_url.value = (window.debug ? 'ws://localhost:9999' : '');
    // Set up connection listeners
    ConnectionActions.addConnectionListener({
      onopen: function(websocket) {
        _this.write('connection opened');
        _this.connected = true;
        _this.ws_url.value = websocket.url;
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
    var url = this.ws_url.value;
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
</connection-subpane>
