jQuery ->
  class CV
    constructor: (key) ->
      @key = key

    fetch: ->
      $.ajax(
        url: "https://spreadsheets.google.com/pub?key=#{@key}&hl=en&output=csv"
        method: "get"
      ).done (response) =>
        objects = $.csv.toObjects(response)

        @rows = $.map objects, (object) ->
          new CV.Row(object)

        @categories = _.chain(@rows)
          .groupBy("type")
          .map((category) -> new CV.Category(category))
          .value()

  class CV.Row
    constructor: (object) ->
      for k, v of object
        @[k.toLowerCase()] = v.trim()

  class CV.Category
    constructor: (entries) ->
      @name = entries[0].category
      @years = _.chain(entries)
        .groupBy("year")
        .sortBy((row) -> parseInt(row.year))
        .map((row) -> new CV.Category.Year(row))
        .value().reverse()

  class CV.Category.Year
    constructor: (entries) ->
      @name = entries[0].year
      @entries = entries

  $.cv = (el, options) ->
    @$el = $(el)

    @init = =>
      @settings = $.extend({}, @defaults, options)

      throw "Missing key" if @settings["key"] is undefined

      cv = new CV(@settings["key"])

      @$el.html "Loading"

      $.when(cv.fetch()).then =>
        renders = _.map cv.categories, (category) =>
          @settings["templates"].category(category: category)

        @$el.html renders

    @init()

  $.cv::defaults =
    templates:
      category: _.template """
        <div class="category">
          <h3><%= category.name %></h3>

          <% _.each(category.years, function(year) { %>
            <div class="year">
              <h4><%= year.name %></h4>

              <% _.each(year.entries, function(entry) { %>
                <%= $.cv.prototype.defaults.templates.entry({ entry: entry }) %>
              <% }) %>
            </div>
          <% }); %>
        </div>
      """

      entry: _.template """
        <div class="entry">
          <% if (entry.url) { %>
            <a href="<%= entry.url %>" target="_blank"><%= entry.title %></a>,
          <% } else { %>
            <u><%= entry.title %></u>,
          <% } %>

          <%= entry.venue %>

          <% if (entry.city && entry.country) { %>
            (<%= entry.city %>, <%= entry.country %>)
          <% } %>

          <% if (entry.notes) { %>
            - <%= entry.notes %>
          <% } %>
        </div>
      """

  $.fn.cv = (options) ->
    @each ->
      if $(this).data("CV") is undefined
        plugin = new $.cv(this, options)

        $(this).data("CV", plugin)
