<studio-contextpane>
  <div id="contextpane">
    <properties-pane if={ opts.model } model={ opts.model } selection={ opts.selection } />
    <treeview-pane model={ opts.model } selection={ opts.selection } tabs={ opts.tabs }/>
    <connection-pane />
  </div>

  <style>
    #contextpane {
      float: right;
      width: 310px;
      height: 100%;
      background-color: #47866f;
    }
    #contextpane .panecontainer {
      display: block;
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

</studio-contextpane>
