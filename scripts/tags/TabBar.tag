<studio-tabs>
  <ul>
    <li each={ modelId in opts.tabs }>
      <div onclick={ selectTab } class="{ selected: parent.opts.model.id == modelId}">
        { name } <span onclick={ parent.closeTab }>[X]</span>
      </div>
    </li>

    <li><div id="add">&nbsp;<span onclick={ openTab }>[+]</span></div></li>
  </ul>

  <style scoped>
    ul {
      width: 100%;
      background-color: rgb(115, 112, 112);
      list-style: none;
      padding: 0;
      margin: 0;
    }
    li {
      display: inline-block;
    }
    div {
      height: 20px;
      width: 150px;
      border: 1px solid black;
      padding: 5px;
      text-align: left;
      vertical-align: middle;
      line-height: 20px;
      background-color: rgb(153, 153, 153);
    }
    span {
      float: right;
      color: rgba(0, 0, 0, 0.18)
    }
    span:hover {
      color: black;
      cursor: default;
    }
    div#add {
      border: 0px;
      width: 100%;
      margin-left: -5px;
    }
    div.selected {
      border: 1px solid #0e9c14;
      background-color: rgb(181, 181, 181);
    }
  </style>

  var ModelActions = require('actions/ModelActions');

  var self = this;

  // ModelActions.addChangeListener(function(models) {
  //   // Close tabs belonging to recently removed models
  //   opts.tabs.forEach(function(tab) {
  //     if (!models.contains(tab)) self.opts.tabs.close(tab.id);
  //   });
  //   self.update();
  // });

  openTab(e) {
    self.opts.model.new();
    e.preventUpdate = true; // Update is called indirectly above
  };

  closeTab(e) {
    self.opts.tabs.close(e.item.id);
    e.preventUpdate = true; // Update is called indirectly above

    // Don't trigger selectTab
    if (e) e.stopPropagation();
  }

  selectTab(e) {
    self.opts.model.set(e.item.id);
    e.preventUpdate = true; // Update is called indirectly above
  }
</studio-tabs>
