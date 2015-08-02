<models-pane>
  <ul class="models">
    <li if={ !models.length }><a href="" onclick={ opts.model.new }>Create new model</a></li>
    <li if={ models.length }>
      <a href="" onclick={ expandAll }>Expand all</a>
      <a href="" onclick={ hideAll }>Hide all</a>
    </li>
    <li each={ model in models } class="{ active: parent.opts.model.id == model.id}">
      <span onclick={ toggleExpand }>{ parent.expanded.contains(model.id) ? ARROW_DOWN : ARROW_RIGHT }</span>
      <a class="{ active: parent.opts.model.id == model.id}" onclick={ openModel }>
        { model.name }
      </a>
      <ul if={ parent.expanded.contains(model.id) }>
        <li each={ filterByModel(vertices, model) }>
          <a class="vertex { selected: parent.parent.opts.selection.mapBy('id').contains(id) }"
           onclick={ select }>{ id }</a>
        </li>
        <li each={ filterByModel(edges, model) }>
          <a class="edge { selected: parent.parent.opts.selection.mapBy('id').contains(id) }"
           onclick={ select }>{ id }</a>
        </li>
      </ul>
    </li>
  </ul>

  <style scoped>
    a {
      color: inherit;
    }
    a.active {
      color: #72b7d5;
    }
    a.selected {
      background-color: rgba(55, 157, 200, 0.75);
    }
    li.active {
      background-color: rgba(98, 171, 130, 0.3);
    }
    ul.models {
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
    return elements.filter(function(el) { return el.model.id == model.id });
  }

  toggleExpand(e) {
    var modelId = e.item.model.id;
    self.expanded.toggle(modelId);
  }

  expandAll() {
    self.expanded = self.models.mapBy('id');
  }

  hideAll() {
    self.expanded = [];
  }

  select(e) {
    e.preventUpdate = true; // Update is called by selection.update
    var element = e.item;
    self.opts.model.set(element.model);
    opts.selection.update(element);
  }

  openModel(e) {
    self.opts.model.set(e.item.model);
  }

</models-pane>
