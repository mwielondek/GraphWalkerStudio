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
        <li>URL: <input name="ws_url" /><button onclick="{ connect }">Connect</button></li>
        <li><textarea name="output" readonly="true">output</textarea></li>
      </ul>
    </div>
  </div>

  <style>
    #contextpane {
      float: right;
      width: 300px;
      height: 100%;
      background-color: #47866f;
    }

    #contextpane > div {
      background-color: #01493a;
      color: white;
      margin: 10px;
      padding: 10px;
      min-height: 100px;
    }
    #contextpane ul {
      list-style: none;
      padding: 0;
    }
    #contextpane li {
      padding: 0 0 10px 0;
    }
    #contextpane textarea {
      vertical-align: top;
      width: 235px;
      min-height: 100px;
    }
  </style>
</studio-contextpane>
