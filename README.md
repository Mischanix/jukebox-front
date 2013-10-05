# Jukebox

Frontend is entirely Coffee/Jade/Stylus.  Backend is entirely Golang.

Interaction with the server is done over plain WebSockets, and the protocol
followed for a session is described in detail on the Readme for the backend.

Inter-module communication is done with EventEmitter instead of RequireJS or
similar.  This decision was made for no good reason other than it sounds
cool.  App-global data binds to `data.*` events.  Network events are namespaced
into `net.*`; network events are dispatched directly by their "type" field.
Templates are bound to `template.*` events which take two parameters: a context
and a callback.  This wrapping is performed inside the Brunch config,
`config.coffee`, and overall support for a global events object is built in
`global.coffee`.

Neither jQuery nor a framework is used; instead, the HTML library (for which I
am still trying to find a valid use outside of its querySelectorAll wrapper)
and a getComputedStyle wrapper (window.computedStyle) are used in combination
with plain DOM interaction.  Lodash is also used because _ makes me happy.

Target support is IE10+, iOS 6+, Chrome, Firefox, Opera whatever+.  The
CSS layout is meant to be fully functional down to iPhone 4S resolution with
gratuitously large click areas.

## Brunch

This is HTML5 application, built with [Brunch](http://brunch.io).

## Getting started
* Install [Brunch](http://brunch.io): `npm install -g brunch`.
* Install Brunch plugins: `npm install`.
* Install [Bower](http://bower.io) components: `bower install`
* Watch the project with continuous rebuild by
`brunch watch --server`. This will also launch HTTP server.
* Or build the minified project with `brunch build --optimize`.

Open the `public/` dir to see the result.
