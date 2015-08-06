<sidebar-pane>
  <h4 onclick={ toggle('expanded') }>{ opts.heading }<span class="minimize">[{ expanded ? '–' : '+'}]</span></h4>
  <div class="pane-body" show={ expanded }>
    <yield/>
  </div>


  <style scoped>
    :scope {
      display: block;
      background-color: #01493a;
      color: white;
      margin: 10px;
      padding: 8px;
    }
    .pane-body > * > ul {
      list-style: none;
      padding: 0;
      margin: 0 auto;
    }
    .pane-body > * > ul > li {
      padding: 0 0 10px 0;
    }
    .pane-body textarea {
      vertical-align: top;
      width: 255px;
      min-height: 100px;
    }
    .pane-body a {
      color: inherit;
    }
    .minimize {
      float: right;
    }
  </style>

  this.mixin('tagUtils');

  this.expanded = true;

  this.one('update', function() {
    this.expanded = !this.opts.collapsed;
  });
</sidebar-pane>
