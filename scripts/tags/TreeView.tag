<treeview-pane class="panecontainer">
  <h4>Models</h4>
  <ul class="treeview">
    <li each={ model in models } class="{ active: parent.opts.model.id == model.id}">
      <span onclick={ toggleExpand }>{ parent.expanded.contains(model.id) ? ARROW_DOWN : ARROW_RIGHT }</span>
      <a class="{ active: parent.opts.model.id == model.id}" onclick={ openModel }>
        { model.name }
      </a>
      <ul if={ parent.expanded.contains(model.id) }>
        <li each={ filterByModel(vertices, model.id) }>
          <a class="vertex { selected: parent.parent.opts.selection.mapBy('id').contains(id) }"
           onclick={ select }>{ id }</a>
        </li>
        <li each={ filterByModel(edges, model.id) }>
          <a class="edge { selected: parent.parent.opts.selection.mapBy('id').contains(id) }"
           onclick={ select }>{ id }</a>
        </li>
      </ul>
    </li>
  </ul>

  <style scoped>
    a.active {
      color: #72b7d5;
    }
    a.selected {
      background-color: rgba(55, 157, 200, 0.75);
    }
    li.active {
      background-color: rgba(98, 171, 130, 0.3);
    }
    ul.treeview {
      background-color: rgba(98, 171, 130, 0.1);
    }
  </style>


  var VertexActions   = require('actions/VertexActions');
  var EdgeActions     = require('actions/EdgeActions');
  var ModelActions    = require('actions/ModelActions');
  var StudioConstants = require('constants/StudioConstants');

  var self = this;

  // CONSTANTS
  ARROW_RIGHT = '\u25b7';
  ARROW_DOWN = '\u25bd';

  // Store data
  self.models   = [];
  self.vertices = [];
  self.edges    = [];

  // State
  self.expanded = [];


  ModelActions.addChangeListener(function(models) {
    self.models = models;
    self.update();
  });
  VertexActions.addChangeListener(function(vertices) {
    self.vertices = vertices;
    self.update();
  });
  EdgeActions.addChangeListener(function(edges) {
    self.edges = edges;
    self.update();
  });

  filterByModel(elements, model) {
    return elements.filter(function(el) { return el.modelId == model });
  }

  toggleExpand(e) {
    var modelId = e.item.model.id;
    self.expanded.toggle(modelId);
  }

  select(e) {
    e.preventUpdate = true; // Update is called by selection.update
    opts.selection.update(e.item);
  }

  openModel(e) {
    console.log(e.item);
    self.opts.tabs.push(e.item.model);
  }

</treeview-pane>
