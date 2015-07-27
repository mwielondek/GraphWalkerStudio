<studio-tabs>
  <ul>
    <li><div>HardTab1<span>[X]</span></div></li>
    <li><div>HardTab2<span>[X]</span></div></li>
    <li><div id="add">&nbsp;<span>[+]</span></div></li>
  </ul>

  <style scoped>
    ul {
      width: 100%;
      background-color: rgb(130, 130, 130);
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
    }
    span {
      float: right;
      color: rgba(0, 0, 0, 0.18)
    }
    span:hover {
      color: black;
    }
    div#add {
      border: 0px;
      width: 100%;
    }
  </style>
</studio-tabs>
