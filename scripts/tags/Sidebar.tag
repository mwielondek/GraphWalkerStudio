<studio-sidebar>
  <div id="sidebar">
    <sidebar-pane heading="Properties" if={ opts.model.id }>
      <properties-pane model={ parent.opts.model } selection={ parent.opts.selection } />
    </sidebar-pane>

    <sidebar-pane heading="Models">
      <models-pane model={ parent.opts.model } selection={ parent.opts.selection } tabs={ parent.opts.tabs }/>
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

</studio-sidebar>
