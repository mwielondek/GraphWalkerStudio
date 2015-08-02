<studio-sidebar>
  <div id="sidebar">
    <sidebar-pane heading="Properties" if={ opts.model.id }>
      <properties-pane model={ parent.opts.model } selection={ parent.opts.selection } />
    </sidebar-pane>

    <sidebar-pane heading="Models">
      <treeview-pane model={ parent.opts.model } selection={ parent.opts.selection } tabs={ parent.opts.tabs }/>
    </sidebar-pane>

    <sidebar-pane heading="Settings">
      <connection-pane />
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

</studio-sidebar>
