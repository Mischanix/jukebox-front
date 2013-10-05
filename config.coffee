exports.config =
  files:
    javascripts:
      joinTo: 'jukebox.js'
    stylesheets:
      joinTo: 'jukebox.css'
    templates:
      joinTo: 'jukebox.js'
  modules:
    wrapper: (path, data, vendor) ->
      name = path.replace(/\\/g, '/').replace(/^app\//, '').replace(/\.\w+$/, '')
      templatesDir = 'templates/'
      if vendor
        data
      else if name is 'index'
        '\n' # don't include index.jade
      else if name.lastIndexOf(templatesDir, 0) is 0
        nameStr = JSON.stringify 'template.' + name.substring(templatesDir.length)
        # fake module.exports to hack around jade-brunch's umd definition
        """
jukebox.on(#{nameStr}, (function() {
  var module = {exports: {}};
#{data}
  return function(locals, cb) {
    var str = module.exports(locals);
    cb(str);
  };
})())
        """
      else
        nameStr = JSON.stringify name
        """
(function() {
#{data}
})()
        """
    definition: ->
      # Postpone jukebox.on until EventEmitter is ready;
      # calls are resumed in global.coffee
      """
jukebox = {
  on: function() {
    var _base;
    (_base = jukebox.on)._calls || (_base._calls = []);
    return jukebox.on._calls.push(arguments);
  }
};\n
      """
  plugins:
    jade:
      pretty: yes
    bower:
      extend:
        'styles': []
