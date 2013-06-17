# Name    : CV
# Author  : Damon Zucconi, http://www.damonzucconi.com, @dzucconi
# Version : 0.01
# Repo    : http://github.com/dzucconi/jquery.CV

_.groupByMulti = (obj, values, context) ->
  return obj unless values.length

  byFirst = _.groupBy(obj, values[0], context)
  rest = values.slice(1)

  for prop of byFirst
    byFirst[prop] = _.groupByMulti(byFirst[prop], rest, context)

  byFirst

jQuery ->
  class CV
    constructor: (key) ->
      @key = key

    fetch: ->
      $.ajax(
        url: "https://spreadsheets.google.com/pub?key=#{@key}&hl=en&output=csv"
        method: "get"
      ).done((response) =>
        objects = $.csv.toObjects(response)

        @rows = $.map(objects, (object) -> new CV.Row(object))

        @categories = _.chain(@rows)
          .groupBy("type")
          .map((category) -> new CV.Group(category, "category"))
          .value()

      ).error((response) ->
        console.log "Error"

      ).complete ->
        console.log "Complete"

  class CV.Row
    constructor: (object) ->
      for k, v of object
        @[k.toLowerCase()] = v.trim()

  class CV.Group
    constructor: (rows, attribute) ->
      @name = rows[0][attribute]
      @rows = rows

  $.CV = (el, options) ->
    state = ""
    @setState = (_state) -> state = _state
    @getState = -> state

    @settings = {}
    @$el = $(el)

    @init = =>
      @settings = $.extend({}, @defaults, options)

      @setState("ready")

      cv = new CV(@settings["key"])

      $.when(cv.fetch()).then =>
        renders = _.map cv.categories, (category) =>
          @settings["templates"].category(category: category)

        @$el.html renders

    @init()

    this # Chainable

  # Defaults
  $.CV::defaults =
    key: "0AsxYR5Y3N6DjdHJWZDNNcjhmZ0ZSb2hFTjU0MDBjZ2c"
    templates:
      category: _.template """
        <div class="category">
          <h3><%= category.name %></h3>

          <% _.each(category.rows, function(row) { %>
            <%= $.CV.prototype.defaults.templates.row({ row: row }) %>
          <% }); %>
        </div>
      """

      row: _.template """
        <div class="row">
          <% if (row.url) { %>
            <a href="<%= row.url %>" target="_blank"><%= row.title %></a>,
          <% } else { %>
            <u><%= row.title %></u>,
          <% } %>

          <%= row.venue %>

          <% if (row.city && row.country) { %>
            (<%= row.city %>, <%= row.country %>)
          <% } %>

          <% if (row.notes) { %>
            - <%= row.notes %>
          <% } %>
        </div>
      """

  $.fn.CV = (options) ->
    this.each ->
      if $(this).data("CV") is undefined
        plugin = new $.CV(this, options)

        $(this).data("CV", plugin)
