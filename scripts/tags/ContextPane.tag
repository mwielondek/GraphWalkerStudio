<studio-contextpane>
  <div id="contextpane">
    <!-- TODO: change below to rg-tabs, once updated for riot 2.2 -->
    <div id="props" show={ opts.selection.length == 1 }>
      <h4>Properties</h4>
      <ul>
        <li>ID: { opts.selection }</li>
      </ul>
    </div>
    <div id="settings">
      <h4>Settings</h4>

      <h5>Connect to GraphWalker</h5>
      <ul>
        <li>URL: <input name="ws_url" />
        <button onclick="{ toggleConnection }">{ connected ? 'Disconnect' : 'Connect' }</button></li>
        <li><textarea name="output" readonly="true">output</textarea></li>
      </ul>
    </div>
  </div>

  <style>
    #contextpane {
      float: right;
      width: 310px;
      height: 100%;
      background-color: #47866f;
    }

    #contextpane > div {
      background-color: #01493a;
      color: white;
      margin: 10px;
      padding: 8px;
      min-height: 100px;
    }
    #contextpane ul {
      list-style: none;
      padding: 0;
      margin: 0 auto;
    }
    #contextpane li {
      padding: 0 0 10px 0;
    }
    #contextpane textarea {
      vertical-align: top;
      width: 255px;
      min-height: 100px;
    }
  </style>

  this.connected = false;

  toggleConnection() {
    this.connected ? this.disconnect() : this.connect();
  }
  connect() {

    var url = this.ws_url.value || (window.debug ? 'ws://localhost:9999' : '');
    this.write('connecting to', url);
    var ws = new WebSocket(url);
    this.websocket = ws;

    var _this = this;
    ws.onopen = function() {
      _this.write('connection opened');
      _this.connected = true;
      _this.update();
      ws.send('hello there');
    };
    ws.onclose = function() {
      _this.write('disconnected');
      _this.connected = false;
      _this.update();
    };
    ws.onmessage = function(evt) {
      _this.write('message', evt.data);
    };
  }
  disconnect() {
    this.websocket.close();
  }
  write() {
    this.output.value += '\n' + [].slice.call(arguments, 0).join(' ');
  }
</studio-contextpane>
