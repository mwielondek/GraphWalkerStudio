# GraphWalker Studio

A studio suite for creating, validating and running test models using [GraphWalker](http://graphwalker.org).

![Screenshot of GraphWalker Studio](http://i.imgur.com/yD3SSeD.png)

## Dependencies
* [Riot](https://muut.com/riotjs/) compiler
* GNU sed aliased to `gsed`
* (DEV) golang for running the mock server

## Running
* Get the riot compiler using `npm install riot -g`
* Get GNU sed and alias it to `gsed` (`brew install gnu-sed` will do both for you if you're on OS X)
* Run `build.sh`
* Serve the files in root directory using server of your choice, e.g. `python -m SimpleHTTPServer`
* Launch the GraphWalker mock by running `go run websocket/gwmock.go <SIMULATED DELAY IN MILLISECONDS>`
* Navigate to `index.html`

## Using the studio without GraphWalker
It is possible to use the studio without connecting to a GraphWalker service, even for goals completely different than creating test models. The studio has full editing capabilities you would expect from a graph editor, including:

* Node creating, renaming, dragging and resizing
* Connecting nodes using directed edges
* Element tree view with regex search
* Working on multiple models using tabs
* Saving/loading models to/from file
* Gridded canvas with pan, zoom, minimap, snap-to-grid and rubberband selection functionality

## TODO
* [x] Create TODO list
* [ ] Add build tools to automatically bundle and minify the app


