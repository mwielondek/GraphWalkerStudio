<studio-sidebar>
  <div id="sidebar">
    <sidebar-pane heading="Properties" if={ opts.model.id }>
      <properties-pane model={ parent.opts.model } selection={ parent.opts.selection } />
    </sidebar-pane>

    <sidebar-pane heading="Models">
      <models-pane model={ parent.opts.model } selection={ parent.opts.selection } tabs={ parent.opts.tabs }/>
    </sidebar-pane>

    <sidebar-pane heading="GraphWalker" collapsed={ true }>
      <graphwalker-pane connected={ parent.connectionOpen } />
    </sidebar-pane>

    <sidebar-pane heading="Settings" collapsed={ true }>
      <settings-pane options={ parent.opts.options } />
    </sidebar-pane>
  </div>

  <style>
    #sidebar {
      float: right;
      width: 310px;
      height: 100%;
      background-color: #47866f;
    }
  </style>

  var ConnectionActions = require('actions/ConnectionActions');

  var self = this;

  this.connectionOpen = false;

  var _toggle = function() {
    self.connectionOpen = !self.connectionOpen;
    self.update();
  };
  ConnectionActions.addConnectionListener({
    onopen: _toggle,
    onclose: _toggle
  });

</studio-sidebar>
