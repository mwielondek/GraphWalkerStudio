<models-pane>
  <ul>
    <li if={ !opts.models.length }><a href="" onclick={ opts.model.new }>Create new model</a></li>
    <li if={ opts.models.length }>
      <input type="text" name="searchInput" placeholder="Search" onkeyup={ search }>
      <button onclick={ clearSearch }>Clear</button>
    </li>
    <li if={ opts.models.length }>
      <a href="" onclick={ expandAll }>Expand all</a>
      <a href="" onclick={ hideAll }>Hide not active</a>
    </li>
  </ul>
  <ul class="models">
    <li each={ model in opts.models } class="{ active: parent.opts.model.id == model.id}">
      <span onclick={ toggleExpand }
        class="octicon octicon-chevron-{ parent.expanded.contains(model.id) ? 'down' : 'right' }"></span>
      <a class="{ active: parent.opts.model.id == model.id}" onclick={ openModel }>
        { model.name }
      </a>
      <ul if={ parent.expanded.contains(model.id) }>
        <li each={ filterByModel(parent.opts.vertices, model).filter(searchFilter) }>
          <a class="vertex { selected: parent.parent.opts.selection.mapBy('id').contains(id) }"
           onclick={ select }>{ name }</a>
        </li>
        <li each={ filterByModel(parent.opts.edges, model).filter(searchFilter) }>
          <a class="edge { selected: parent.parent.opts.selection.mapBy('id').contains(id) }"
           onclick={ select }>{ name }</a>
        </li>
      </ul>
    </li>
  </ul>

  <style scoped>
    a {
      color: inherit;
    }
    a.active {
      background-color: rgba(55, 157, 200, 0.4);
    }
    a.selected {
      background-color: rgba(55, 157, 200, 0.75);
    }
    li.active {
      background-color: rgba(91, 133, 144, 0.2);
    }
    ul.models {
      list-style: none;
      background-color: #f0f0f0;
      color: black;
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

  // State
  self.expanded = [];
  self.searchQuery = '';

  self.on('update', function() {
    if (!self.expanded.contains(opts.model.id)) self.expanded.push(opts.model.id);
  });

  filterByModel(elements, model) {
    return elements.filter(function(el) { return el.modelId == model.id });
  }

  toggleExpand(e) {
    var modelId = e.item.model.id;
    self.expanded.toggle(modelId);
  }

  expandAll() {
    self.expanded = self.opts.models.mapBy('id');
  }

  hideAll() {
    self.expanded = [];
  }

  select(e) {
    e.preventUpdate = true; // Update is called by selection.update
    var element = e.item;
    self.opts.model.set(element.modelId);
    opts.selection.update(element);
  }

  openModel(e) {
    self.opts.model.set(e.item.model.id);
  }

  searchFilter(el) {
    return !self.searchQuery ? true : new RegExp(self.searchQuery).test(el.name);
  }

  search() {
    if (!self.expandedBeforeSearch) self.expandedBeforeSearch = self.expanded;
    self.searchQuery = self.searchInput.value;
    self.expandAll();
  }

  clearSearch() {
    self.searchQuery = self.searchInput.value = '';
    self.expanded = self.expandedBeforeSearch;
    delete self.expandedBeforeSearch;
  }

</models-pane>
