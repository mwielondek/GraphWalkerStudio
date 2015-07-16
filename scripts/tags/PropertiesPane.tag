<properties-pane class="panecontainer">
  <h4>Properties</h4>
  <ul>
    <li>ID: { opts.selection }</li>
    <li><button onclick={ removeVertex }>Remove vertex</button></li>
  </ul>

  var VertexActions = require('actions/VertexActions');

  removeVertex() {
    console.assert(opts.selection.length == 1, 'empty selection');
    VertexActions.remove(opts.selection[0]);
  }
</properties-pane>
