<studio-sidebar>
  <div id="sidebar">
    <sidebar-pane heading="Properties" icon="list-unordered" if={ opts.model.id }>
      <properties-pane model={ parent.opts.model } selection={ parent.opts.selection } />
    </sidebar-pane>

    <sidebar-pane heading="Models" icon="file-directory">
      <models-pane model={ parent.opts.model } selection={ parent.opts.selection }
        vertices={ parent.opts.vertices } edges={ parent.opts.edges } models={ parent.opts.models } />
    </sidebar-pane>

    <sidebar-pane heading="GraphWalker" icon="primitive-dot" collapsed={ true }>
      <graphwalker-pane connected={ parent.connectionOpen } />
    </sidebar-pane>

    <sidebar-pane heading="Settings" icon="gear" collapsed={ true }>
      <settings-pane options={ parent.opts.options } />
    </sidebar-pane>
  </div>

  <style>
    #sidebar {
      float: right;
      width: 310px;
      height: 100%;
      background-color: #f0f0f0;
    }
  </style>

  var ConnectionActions = require('actions/ConnectionActions');

  var self = this;

  this.connectionOpen = false;

  var _toggle = function(toggle) {
    self.connectionOpen = toggle == undefined ?  !self.connectionOpen : toggle;
    self.update();
  };
  ConnectionActions.addConnectionListener({
    onopen: _toggle.bind(null, true),
    onclose: _toggle.bind(null, false)
  });

</studio-sidebar>
