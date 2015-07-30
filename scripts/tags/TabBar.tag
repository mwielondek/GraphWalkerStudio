<studio-tabs>
  <ul>
    <li each={ opts.tabs }><div onclick={ selectTab } class="{ selected: parent.opts.model.id == id}">{ name }
      <span onclick={ parent.closeTab }>[X]</span></div></li>

    <li><div id="add">&nbsp;<span onclick={ addTab }>[+]</span></div></li>
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

  ModelActions.addChangeListener(function(models) {
    // Close tabs belonging to recently removed models
    opts.tabs.forEach(function(tab) {
      if (models.indexOf(tab) == -1) self.closeTab(null, tab.id);
    });
    self.update();
  });

  addTab(e, model) {
    // TODO: use promises
    if (model) {
      // Open existing model
      opts.tabs.push(model);
      opts.setmodel(model);
    } else {
      // Create new model
      ModelActions.add({}, function(model) {
        opts.tabs.push(model);
        opts.setmodel(model);
      });
    }
  }

  closeTab(e, modelId) {
    var model = modelId || e.item.id;

    var index = opts.tabs.mapBy('id').indexOf(model);

    // Change model selection if selected model is being removed
    if (opts.model.id == model) {
      // Try selecting model immediately next to the left
      var next = index - 1;
      next = next < 0 ? 1 : next;
      opts.setmodel(opts.tabs[next]);
    }

    opts.tabs.splice(index, 1);

    // Don't trigger selectTab
    if (e) e.stopPropagation();
  }

  selectTab(e) {
    opts.setmodel(e.item);
  }
</studio-tabs>
