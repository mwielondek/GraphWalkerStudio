(function(tagger) {
  if (typeof define === 'function' && define.amd) {
    define(['riot'], function(riot) { tagger(riot); });
  } else if (typeof module !== 'undefined' && typeof module.exports !== 'undefined') {
    tagger(require('riot'));
  } else {
    tagger(window.riot);
  }
})(function(riot) {
riot.tag('studio-canvas', '<vertex each="{ filterByModel(vertices) }" selection="{ parent.opts.selection }"></vertex> <edge each="{ filterByModel(edges) }" selection="{ parent.opts.selection }"></edge>', 'studio-canvas { height: 100%; display: block; position: relative; margin-right: 310px; background-color: #f0f0f0; border: 2px solid #10586b; } studio-canvas.highlight { border: 2px solid #2cb9de; }', 'class="{ highlight: !selection.length }"', function(opts) {

  var $                 = require('jquery');
  var jsp               = require('jsplumb');
  var RiotControl       = require('app/RiotControl');
  var VertexActions     = require('actions/VertexActions');
  var EdgeActions       = require('actions/EdgeActions');
  var StudioConstants   = require('constants/StudioConstants');
  var ConnectionActions = require('actions/ConnectionActions');
  var rubberband        = require('utils/rubberband');

  var self = this

  self.vertices = []
  self.edges = []

  this.addVertex = function(e) {

    var vertex = {
      model: opts.model,
      view: {
        centerY: e.pageY - self.root.offsetTop,
        centerX: e.pageX - self.root.offsetLeft
      }
    }

    VertexActions.add(vertex);
  }.bind(this);

  this.addEdge = function(sourceDomId, targetDomId) {
    var sourceVertexId = $('#'+sourceDomId).attr('vertex-id');
    var targetVertexId = $('#'+targetDomId).attr('vertex-id');
    var edge = {
      model: opts.model,
      sourceDomId: sourceDomId,
      targetDomId: targetDomId,
      sourceVertexId: sourceVertexId,
      targetVertexId: targetVertexId
    };
    EdgeActions.add(edge);
  }.bind(this);

  this.filterByModel = function(elements) {
    return elements.filter(function(el) { return el.model.id == opts.model.id });
  }.bind(this);

  VertexActions.getAll(function(vertices) {
    self.vertices = vertices;
  });
  VertexActions.addChangeListener(function(vertices) {
    self.vertices = vertices;
    self.update();
  });

  EdgeActions.getAll(function(edges) {
    self.edges = edges;
  });
  EdgeActions.addChangeListener(function(edges) {
    self.edges = edges;
    self.update();
  });

  self.on('mount', function() {

    jsp.ready(function() {

      jsp.importDefaults({
        Endpoint: ['Dot', {radius: 2}],
        Anchor: 'Continuous',
        Connector: [
          'StateMachine', {
            curviness: 0,
            proximityLimit: 260
        }],
        HoverPaintStyle: {strokeStyle: '#0b771b', lineWidth: 3 },
        PaintStyle: {strokeStyle: '#000000', lineWidth: 1 },
        ConnectionOverlays: [
            [ 'Arrow', {
                location: 1,
                id: 'arrow',
                length: 12,
                foldback: 0.1
            } ],
            [ 'Label', { id: 'label', cssClass: 'edge-label' }]
        ]
      });

      jsp.registerConnectionType('selected', {

        paintStyle: {strokeStyle: '#0b771b', lineWidth: 3 }
      });

      jsp.setContainer(self.root);

      jsp.bind('beforeDrop', function(params) {
        self.addEdge(params.sourceId, params.targetId);
        return false;
      });

      jsp.bind('click', function(connection, evt) {
        var edge = connection.getParameter('_edgeObject');
        self.opts.selection.update(edge, evt.metaKey);
      });
    });

    rubberband(self.root, 'vertex', function(selectedVertices, append) {


      setTimeout(function() {
        self.opts.selection.update(selectedVertices.mapBy('_vertexObject'), append);
      }, 0);
    });

    $(self.root)

      .on('dblclick', function(e) {
        if (e.target === this) self.addVertex(e);
      })

      .on('click', function(e) {
        if (e.target == this) self.opts.selection.clear();
      });

  });

  self.on('update', function() {
    var selection = self.opts.selection.mapBy('view.domId');
    jsp.clearDragSelection();
    jsp.addToDragSelection(selection);
  });








});
riot.tag('connection-pane', '<h5>Connect to GraphWalker</h5> <ul> <li>URL: <input name="ws_url" __disabled="{ connected }"> <button onclick="{ toggleConnection }">{ connected ? \'Disconnect\' : \'Connect\' }</button></li> <li><textarea name="output" readonly="true"></textarea></li> </ul>', function(opts) {

  var ConnectionActions = require('actions/ConnectionActions');

  this.connected = false;

  var _this = this;
  this.on("mount", function() {
    _this.ws_url.value = (window.debug ? 'ws://localhost:9999' : '');

    ConnectionActions.addConnectionListener({
      onopen: function(websocket) {
        _this.write('connection opened');
        _this.connected = true;
        _this.ws_url.value = websocket.url;
        _this.update();
      },
      onclose: function() {
        _this.write('disconnected');
        _this.connected = false;
        _this.update();
      },
      onmessage: function(message) {
        _this.write(JSON.stringify(message));
      }
    });
  });

  this.toggleConnection = function() {
    this.connected ? this.disconnect() : this.connect();
  }.bind(this);
  this.connect = function() {
    var url = this.ws_url.value;
    this.write('connecting to', url);

    ConnectionActions.isSocketOpen(function(isOpen) {

      if (isOpen) ConnectionActions.disconnect();
      ConnectionActions.connect(url);
    });
  }.bind(this);
  this.disconnect = function() {
    ConnectionActions.disconnect();
  }.bind(this);
  this.write = function() {
    this.output.value += '\n' + [].slice.call(arguments, 0).join(' ');
  }.bind(this);

});
riot.tag('edge', '', '.edge-label { background-color: white; opacity: 0.8; padding: 5px; border: 1px solid black; min-width: 10px; min-height: 8pt; } .edge-label:empty:not(:hover):not(:focus) { opacity: 0; }', 'id="{ id }" source="{ sourceVertexId }" target="{ targetVertexId }"', function(opts) {

  var $ = require('jquery');
  var jsp = require('jsplumb');
  var Constants = require('constants/EdgeConstants');
  var EdgeActions = require('actions/EdgeActions');

  var self = this;
  self.defaults = {
    label: self.id + ': ' + self.sourceVertexId + '->' + self.targetVertexId,
    status: Constants.status.UNVERIFIED
  };

  self.one('update', function() {


    var merged = $.extend(true, {}, self.defaults, self);
    $.extend(true, self, merged);
  });

  self.on('mount', function() {
    self.connection = jsp.connect({source: self.sourceDomId, target: self.targetDomId});
    self.connection.getOverlay('label').setLabel(self.label);
    self.connection.setParameter('_edgeObject', self);

    if (self.sourceDomId == self.targetDomId)
      setTimeout(function() {jsp.revalidate(self.sourceDomId)}, 0);

    EdgeActions.setProps(self.id, {_jsp_connection: self.connection});
  });

  self.on('update', function() {
    self.selected = self.opts.selection.mapBy('id').contains(self.id);
  });

  self.on('updated', function() {

    var connection = self.connection;
    var SELECTED = 'selected';
    if (connection && connection.connector) {
      if (self.selected && !connection.hasType(SELECTED)) connection.addType(SELECTED);
      if (!self.selected && connection.hasType(SELECTED)) connection.removeType(SELECTED);
    }
  })

  self.on('unmount', function() {
    if (self.connection.connector) jsp.detach(self.connection);
  });

});
riot.tag('models-pane', '<ul class="models"> <li if="{ !models.length }"><a href="" onclick="{ opts.model.new }">Create new model</a></li> <li if="{ models.length }"> <input type="text" name="searchInput" placeholder="Search" onkeyup="{ search }"> <button onclick="{ clearSearch }">Clear</button> </li> <li if="{ models.length }"> <a href="" onclick="{ expandAll }">Expand all</a> <a href="" onclick="{ hideAll }">Hide not active</a> </li> <li each="{ model in models }" class="{ active: parent.opts.model.id == model.id}"> <span onclick="{ toggleExpand }">{ parent.expanded.contains(model.id) ? ARROW_DOWN : ARROW_RIGHT }</span> <a class="{ active: parent.opts.model.id == model.id}" onclick="{ openModel }"> { model.name } </a> <ul if="{ parent.expanded.contains(model.id) }"> <li each="{ filterByModel(vertices, model).filter(searchFilter) }"> <a class="vertex { selected: parent.parent.opts.selection.mapBy(\'id\').contains(id) }" onclick="{ select }">{ id }</a> </li> <li each="{ filterByModel(edges, model).filter(searchFilter) }"> <a class="edge { selected: parent.parent.opts.selection.mapBy(\'id\').contains(id) }" onclick="{ select }">{ id }</a> </li> </ul> </li> </ul>', 'models-pane a, [riot-tag="models-pane"] a{ color: inherit; } models-pane a.active, [riot-tag="models-pane"] a.active{ color: #72b7d5; } models-pane a.selected, [riot-tag="models-pane"] a.selected{ background-color: rgba(55, 157, 200, 0.75); } models-pane li.active, [riot-tag="models-pane"] li.active{ background-color: rgba(98, 171, 130, 0.3); } models-pane ul.models, [riot-tag="models-pane"] ul.models{ background-color: rgba(98, 171, 130, 0.1); }', function(opts) {


  var VertexActions   = require('actions/VertexActions');
  var EdgeActions     = require('actions/EdgeActions');
  var ModelActions    = require('actions/ModelActions');
  var StudioConstants = require('constants/StudioConstants');

  var self = this;

  ARROW_RIGHT = '\u25b7';
  ARROW_DOWN = '\u25bd';

  self.models   = [];
  self.vertices = [];
  self.edges    = [];

  self.expanded = [];
  self.searchQuery = '';


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

  self.on('update', function() {
    if (!self.expanded.contains(opts.model.id)) self.expanded.push(opts.model.id);
  });

  this.filterByModel = function(elements, model) {
    return elements.filter(function(el) { return el.model.id == model.id });
  }.bind(this);

  this.toggleExpand = function(e) {
    var modelId = e.item.model.id;
    self.expanded.toggle(modelId);
  }.bind(this);

  this.expandAll = function() {
    self.expanded = self.models.mapBy('id');
  }.bind(this);

  this.hideAll = function() {
    self.expanded = [];
  }.bind(this);

  this.select = function(e) {
    e.preventUpdate = true; // Update is called by selection.update
    var element = e.item;
    self.opts.model.set(element.model);
    opts.selection.update(element);
  }.bind(this);

  this.openModel = function(e) {
    self.opts.model.set(e.item.model);
  }.bind(this);

  this.searchFilter = function(el) {
    return !self.searchQuery ? true : new RegExp(self.searchQuery).test(el.id);
  }.bind(this);

  this.search = function() {
    if (!self.expandedBeforeSearch) self.expandedBeforeSearch = self.expanded;
    self.searchQuery = self.searchInput.value;
    self.expandAll();
  }.bind(this);

  this.clearSearch = function() {
    self.searchQuery = self.searchInput.value = '';
    self.expanded = self.expandedBeforeSearch;
    delete self.expandedBeforeSearch;
  }.bind(this);


});
riot.tag('properties-pane', '<ul> <li if="{!isMultipleSelection}">ID: { element.id }</li> <li if="{isMultipleSelection}"> Selected { opts.selection.length } { isDifferentTypes ? \'elements\' : element.type.pluralize(isMultipleSelection) } </li> <li> <button onclick="{ removeElement }"> Remove { isDifferentTypes ? \'elements\' : element.type.pluralize(isMultipleSelection) } </button> </li> </ul>', function(opts) {

  var VertexActions    = require('actions/VertexActions');
  var EdgeActions      = require('actions/EdgeActions');
  var ModelActions     = require('actions/ModelActions');
  var StudioConstants  = require('constants/StudioConstants');

  var self = this;

  self.on('update', function() {
    self.element = opts.selection[0] || opts.model || {};
    self.isMultipleSelection = opts.selection.length > 1;
    self.isDifferentTypes = !self.isMultipleSelection ? false :
      !opts.selection.mapBy('type').every(function(el, i, array) {
        return i > 0 ? el == array[i-1] : true;
      });
  });

  this.removeElement = function() {

    switch (self.element.type) {
      case StudioConstants.types.T_VERTEX:
        VertexActions.remove(opts.selection.mapBy('id'));
        break;
      case StudioConstants.types.T_EDGE:
        EdgeActions.remove(self.element.id);
        break;
      case StudioConstants.types.T_MODEL:
        ModelActions.remove(self.element.id);
        break;
    }
  }.bind(this);

});
riot.tag('studio-sidebar', '<div id="sidebar"> <sidebar-pane heading="Properties" if="{ opts.model.id }"> <properties-pane model="{ parent.opts.model }" selection="{ parent.opts.selection }"></properties-pane> </sidebar-pane> <sidebar-pane heading="Models"> <models-pane model="{ parent.opts.model }" selection="{ parent.opts.selection }" tabs="{ parent.opts.tabs }"></models-pane> </sidebar-pane> <sidebar-pane heading="Settings"> <connection-pane ></connection-pane> </sidebar-pane> </div>', '#sidebar { float: right; width: 310px; height: 100%; background-color: #47866f; }', function(opts) {


});
riot.tag('sidebar-pane', '<h4 onclick="{ togglePane }">{ opts.heading }<span class="minimize">[{ expanded ? \'–\' : \'+\'}]</span></h4> <div class="pane-body" show="{ expanded }"> <yield></yield> </div>', 'sidebar-pane , [riot-tag="sidebar-pane"] { display: block; background-color: #01493a; color: white; margin: 10px; padding: 8px; } sidebar-pane .pane-body > * > ul, [riot-tag="sidebar-pane"] .pane-body > * > ul{ list-style: none; padding: 0; margin: 0 auto; } sidebar-pane .pane-body > * > ul > li, [riot-tag="sidebar-pane"] .pane-body > * > ul > li{ padding: 0 0 10px 0; } sidebar-pane textarea, [riot-tag="sidebar-pane"] textarea{ vertical-align: top; width: 255px; min-height: 100px; } sidebar-pane .minimize, [riot-tag="sidebar-pane"] .minimize{ float: right; }', function(opts) {

  this.expanded = true;

  this.togglePane = function() {
    this.expanded = !this.expanded;
  }.bind(this);

});
riot.tag('studio', '<p>Studio</p> <studio-tabs tabs="{ tabs }" model="{ model }"></studio-tabs> <studio-sidebar selection="{ selection }" model="{ model }"></studio-sidebar> <studio-canvas selection="{ selection }" model="{ model }" show="{ tabs.length }"></studio-canvas>', 'studio { height: 90%; display: block; }', function(opts) {

  var jsp               = require('jsplumb');
  var RiotControl       = require('app/RiotControl');
  var ModelActions      = require('actions/ModelActions');
  var VertexActions     = require('actions/VertexActions');
  var StudioConstants   = require('constants/StudioConstants');
  var ConnectionActions = require('actions/ConnectionActions');

  var self = this;


  self.selection = [];
  Object.defineProperty(self, 'selection', { writable: false }); // Prevent from overwriting object
  self.selection.clear = function(preventUpdate) {
    this.constructor.prototype.clear.apply(this);
    if (!preventUpdate) self.update();
  };
  self.selection.update = function(elements, toggle) {

    if (!elements || elements.length == 0) {

      if (this.length == 0) return;

      this.clear(true);
    } else {
      if (!Array.isArray(elements)) elements = [elements]; // Wrap single element into array

      if (toggle) {


        var _this = self;
        elements.forEach(function(element) {
          _this.selection.toggle(element);
        });
      } else {
        this.clear(true);
        this.push.apply(this, elements); // concatenates the array in place
      }

    }
    self.update();
  }.bind(self.selection);

  self.tabs = [];
  Object.defineProperty(self, 'tabs', { writable: false }); // Prevent from overwriting object
  self.tabs.open = function(model, preventUpdate) {
    if (!this.mapBy('id').contains(model.id)) {

      this.push(model);
      if (!preventUpdate) self.update();
    }
  }.bind(self.tabs);
  self.tabs.close = function(modelId) {
    var index = this.mapBy('id').indexOf(modelId);

    if (self.model.id == modelId) {

      var next = index - 1;
      next = next < 0 ? 1 : next;
      self.model = this[next];
    }
    this.splice(index, 1);
    self.update();
  }.bind(self.tabs);

  var _modelHelperFunctions = self._model = {

    set: function(model) {
      self.model = model;
    },

    new: function() {
      ModelActions.add({}, function(model) {
        self.model = model;
      });
    }
  };
  Object.defineProperty(self, 'model', {
    get: function() {
      return this._model;
    },
    set: function(model) {

      this._model = _modelHelperFunctions;
      this.update();

      if (model) {
        this._model = $.extend({}, model, _modelHelperFunctions);
        self.tabs.open(model, true);
        this.selection.clear();
      }
    }
  });

  self.on('mount', function() {
    if (opts.autoConnect && opts.autoConnect.enabled) {
      ConnectionActions.connect(opts.autoConnect.url);
    }
  });

  RiotControl.on(StudioConstants.calls.CLEAR_SELECTION, function() {
    self.selection.clear();
  });


});
riot.tag('studio-tabs', '<ul> <li each="{ opts.tabs }"><div onclick="{ selectTab }" class="{ selected: parent.opts.model.id == id}">{ name } <span onclick="{ parent.closeTab }">[X]</span></div></li> <li><div id="add">&nbsp;<span onclick="{ openTab }">[+]</span></div></li> </ul>', 'studio-tabs ul, [riot-tag="studio-tabs"] ul{ width: 100%; background-color: rgb(115, 112, 112); list-style: none; padding: 0; margin: 0; } studio-tabs li, [riot-tag="studio-tabs"] li{ display: inline-block; } studio-tabs div, [riot-tag="studio-tabs"] div{ height: 20px; width: 150px; border: 1px solid black; padding: 5px; text-align: left; vertical-align: middle; line-height: 20px; background-color: rgb(153, 153, 153); } studio-tabs span, [riot-tag="studio-tabs"] span{ float: right; color: rgba(0, 0, 0, 0.18) } studio-tabs span:hover, [riot-tag="studio-tabs"] span:hover{ color: black; cursor: default; } studio-tabs div#add, [riot-tag="studio-tabs"] div#add{ border: 0px; width: 100%; margin-left: -5px; } studio-tabs div.selected, [riot-tag="studio-tabs"] div.selected{ border: 1px solid #0e9c14; background-color: rgb(181, 181, 181); }', function(opts) {

  var ModelActions = require('actions/ModelActions');

  var self = this;

  ModelActions.addChangeListener(function(models) {

    opts.tabs.forEach(function(tab) {
      if (!models.contains(tab)) self.opts.tabs.close(tab.id);
    });
    self.update();
  });

  this.openTab = function(e) {
    self.opts.model.new();
    e.preventUpdate = true; // Update is called indirectly above
  }.bind(this);

  this.closeTab = function(e) {
    self.opts.tabs.close(e.item.id);
    e.preventUpdate = true; // Update is called indirectly above

    if (e) e.stopPropagation();
  }.bind(this);

  this.selectTab = function(e) {
    self.opts.model.set(e.item);
    e.preventUpdate = true; // Update is called indirectly above
  }.bind(this);

});
riot.tag('vertex', '<div class="label-div"> <p class="label">{ label }</p> </div>', 'vertex { background-clip: padding-box; border: 1px solid black; position: absolute !important; display: table !important; border-radius: 15px; } vertex:focus { outline: none; } vertex.selected { border: 1px solid #21cfdf; } vertex.rubberband-hover { border: 1px solid #21cfdf; } vertex.unverified { background-color: rgba(255, 163, 42, 0.85); } vertex.verified { background-color: rgba(20, 187, 107, 0.85); } vertex.error { background-color: rgba(221, 72, 72, 0.85); } .label-div { display: table-cell; vertical-align: middle; text-align: center; padding: 10px; } .label { margin: 0; display: inline-block; min-width: 20px; min-height: 10pt; } .label:hover, .label:focus { background-color: rgba(210, 245, 248, 0.75); background-clip: content-box; outline: none; } .label::selection { background-color: #00c7c0; } .jsplumb-drag-hover { border: 1px solid #21cfdf; }', 'id="{ view.domId }" class="{ selected: selected } { status.toLowerCase() }" tabindex="1" vertex-id="{ id }"', function(opts) {

  var $                = require('jquery');
  var jsp              = require('jsplumb');
  var Constants        = require('constants/VertexConstants');
  var StudioConstants  = require('constants/StudioConstants');
  var VertexActions    = require('actions/VertexActions');
  var ActionUtils      = require('actions/Utils');

  var self = this;
  var $root;

  self.defaults = {
    label: self.id,
    status: Constants.status.UNVERIFIED,
    view: {
      domId: 'd_'+self.id,
      width: 120,
      height: 80
    }
  };

  self.one('update', function() {


    var merged = $.extend(true, {}, self.defaults, self);
    $.extend(true, self, merged);

    if (!self.view.top || !self.view.left) {

      var position = {
        'top': self.view.centerY - (self.view.height / 2),
        'left': self.view.centerX - (self.view.width / 2)
      };
      $.extend(self.view, position);

      VertexActions.setProps(self.id, {view: self.view});
    }

    if (!self.view.css) {

      Object.defineProperty(self.view, 'css', {
        get: function() {
          return {
            'height': this.height,
            'width' : this.width,
            'top'   : this.top,
            'left'  : this.left
          };
        }
      });
    }
  });

  self.on('mount', function() {
    $root = $(self.root);

    $root.hide();

    jsp.makeSource(self.root);
    jsp.makeTarget(self.root);

    jsp.draggable(self.root, {
      containment: true,
      filter: ".ui-resizable-handle",
      start: function(params) {



        var isElementBeingDragged = params.e;
        if (!isElementBeingDragged) return;


        self.root.addEventListener('click', function handler(e) {
          e.stopPropagation();
          this.removeEventListener('click', handler, true);
        }, true);
      },
      stop: function(params) {
        var updatePositionInModel = function() {
          VertexActions.setProps(self.id, {view: {left: params.pos[0], top: params.pos[1]}});
        };
        ActionUtils.bufferedAction(updatePositionInModel, 'jsp.draggable.stop', params.selection.length);
      }
    });

    $root.resizable({
      resize: function(e, ui) {


        jsp.revalidate(ui.element.get(0));
      },
      stop: function(e, ui) {

        VertexActions.setProps(self.id, {view: ui.size});
      }
    });

    $root.on('focus click', function(e) {

      var toggle = e.type == 'click' ? e.metaKey : false;
      self.opts.selection.update(self, toggle);
    });


    self.handleEvent = function(evt) {
      switch(evt.type) {
        case 'mousedown':

          evt.stopPropagation();

          evt.preventDefault();
          self.root.addEventListener('mouseleave', self, true);
          self.root.addEventListener('mouseup', self, true);
          break;

        case 'mouseup':
          self.root.removeEventListener('mouseleave', self, true);
          self.root.removeEventListener('mouseup', self, true);
          break;

        case 'mouseleave':

          if (evt.target != self.root) break;

          self.root.removeEventListener('mouseleave', self, true);
          self.root.removeEventListener('mouseup', self, true);

          self.root.removeEventListener('mousedown', self, true);



          var vertexDimensions = evt.target.getBoundingClientRect();
          var _e = $.extend({}, evt, {
            clientY: (function() {
              if (evt.clientY > vertexDimensions.bottom) return vertexDimensions.bottom;
              if (evt.clientY < vertexDimensions.top) return vertexDimensions.top;
            })(),
            clientX: (function() {
              if (evt.clientX > vertexDimensions.right) return vertexDimensions.right;
              if (evt.clientX < vertexDimensions.left) return vertexDimensions.left;
            })()
          });

          self.root.dispatchEvent(new MouseEvent('mousedown', _e));

          self.root.addEventListener('mousedown', self, true);
          break;
      }
    };
    self.root.addEventListener('mousedown', self, true);

    setTimeout(function() {



      jsp.revalidate(self.root);
    }, 0);

    self.trigger('updated');
  });

  self.on('update', function() {
    self.selected = opts.selection.mapBy('id').contains(self.id);
    self.resizable = opts.selection.length == 1;
  });

  self.on('updated', function() {
    if ($root) {

      $root.show().css(self.view.css);

      self.root['_vertexObject'] = self;

      var selected = self.selected;
      var resizable = selected && self.resizable;

      

      jsp.setSourceEnabled(self.root, !selected);

      jsp.setDraggable(self.root, selected);

      $root.resizable(resizable ? 'enable' : 'disable');
      $root.children('.ui-resizable-handle').toggle(resizable);

      var modifyEventListener = selected ? self.root.removeEventListener : self.root.addEventListener;
      modifyEventListener.call(self.root, 'mousedown', self, true);
    }
  });

  self.on('unmount', function() {
    jsp.remove(self.root);
  });

});

});