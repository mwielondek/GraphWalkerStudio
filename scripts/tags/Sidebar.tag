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
    sidebar-pane {
      display: block;
      background-color: #01493a;
      color: white;
      margin: 10px;
      padding: 8px;
      min-height: 100px;
    }
    sidebar-pane > * > ul {
      list-style: none;
      padding: 0;
      margin: 0 auto;
    }
    sidebar-pane > * > ul > li {
      padding: 0 0 10px 0;
    }
    sidebar-pane textarea {
      vertical-align: top;
      width: 255px;
      min-height: 100px;
    }
  </style>

</studio-sidebar>
