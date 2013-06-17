# Name    : CV
# Author  : Damon Zucconi, http://www.damonzucconi.com, @dzucconi
# Version : 0.01
# Repo    : http://github.com/dzucconi/jquery.CV

jQuery ->
  $.CV = (el, options) ->
    state = ""

    @settings = {}

    @$el = $(el)

    @setState = (_state) -> state = _state
    @getState = -> state

    @getSetting = (key) -> @settings[key]

    # Call one of the plugin setting functions
    @callSettingFunction = (name, args = []) ->
      @settings[name].apply(this, args)

    @init = ->
      @settings = $.extend({}, @defaults, options)

      @setState "ready"

      @$el.html @getSetting("key")

    @init()

    this # Chainable

  # Defaults
  $.CV::defaults =
      key: "0AsxYR5Y3N6DjdHJWZDNNcjhmZ0ZSb2hFTjU0MDBjZ2c"

  $.fn.CV = (options) ->
    this.each ->
      if $(this).data("CV") is undefined
        plugin = new $.CV(this, options)
        $(this).data("CV", plugin)
