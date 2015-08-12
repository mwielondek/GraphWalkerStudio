<sidebar-pane>
  <h4 onclick={ toggle('expanded') }>
    <span if={ opts.icon } class="icon octicon octicon-{ opts.icon }"></span>
    { opts.heading }
    <span class="minimize octicon octicon-diff-{ expanded ? 'removed' : 'added'}"></span>
  </h4>
  <div class="pane-body" show={ expanded }>
    <yield/>
  </div>


  <style scoped>
    :scope {
      display: block;
      background-color: #325262;
      color: white;
      margin: 2px;
      padding: 8px;
    }
    h4 {
      background-color: #5b8590;
      margin: -5px;
      padding: 20px 15px;
      height: 20px;
    }
    .pane-body {
      margin-top: 15px;
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
