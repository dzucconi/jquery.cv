(function() {
  jQuery(function() {
    var CV;
    CV = (function() {
      function CV(key) {
        this.key = key;
      }

      CV.prototype.fetch = function() {
        var _this = this;
        return $.ajax({
          url: "https://spreadsheets.google.com/pub?key=" + this.key + "&hl=en&output=csv",
          method: "get"
        }).done(function(response) {
          var objects;
          objects = $.csv.toObjects(response);
          _this.rows = $.map(objects, function(object) {
            return new CV.Row(object);
          });
          return _this.categories = _.chain(_this.rows).groupBy("type").map(function(category) {
            return new CV.Category(category);
          }).value();
        });
      };

      return CV;

    })();
    CV.Row = (function() {
      function Row(object) {
        var k, v;
        for (k in object) {
          v = object[k];
          this[k.toLowerCase()] = v.trim();
        }
      }

      return Row;

    })();
    CV.Category = (function() {
      function Category(entries) {
        this.name = entries[0].category;
        this.years = _.chain(entries).groupBy("year").map(function(year) {
          return new CV.Category.Year(year);
        }).value().reverse();
      }

      return Category;

    })();
    CV.Category.Year = (function() {
      function Year(entries) {
        this.name = entries[0].year;
        this.entries = entries;
      }

      return Year;

    })();
    $.cv = function(el, options) {
      var _this = this;
      this.$el = $(el);
      this.init = function() {
        var cv;
        _this.settings = $.extend({}, _this.defaults, options);
        if (_this.settings["key"] === void 0) {
          throw "Missing key";
        }
        cv = new CV(_this.settings["key"]);
        _this.$el.html("Loading");
        return $.when(cv.fetch()).then(function() {
          var renders;
          renders = _.map(cv.categories, function(category) {
            return _this.settings["templates"].category({
              category: category
            });
          });
          return _this.$el.html(renders);
        });
      };
      return this.init();
    };
    $.cv.prototype.defaults = {
      templates: {
        category: _.template("<div class=\"category\">\n  <h3><%= category.name %></h3>\n\n  <% _.each(category.years, function(year) { %>\n    <div class=\"year\">\n      <h4><%= year.name %></h4>\n\n      <% _.each(year.entries, function(entry) { %>\n        <%= $.cv.prototype.defaults.templates.entry({ entry: entry }) %>\n      <% }) %>\n    </div>\n  <% }); %>\n</div>"),
        entry: _.template("<div class=\"entry\">\n  <% if (entry.url) { %>\n    <a href=\"<%= entry.url %>\" target=\"_blank\"><%= entry.title %></a>,\n  <% } else { %>\n    <u><%= entry.title %></u>,\n  <% } %>\n\n  <%= entry.venue %>\n\n  <% if (entry.city && entry.country) { %>\n    (<%= entry.city %>, <%= entry.country %>)\n  <% } %>\n\n  <% if (entry.notes) { %>\n    - <%= entry.notes %>\n  <% } %>\n</div>")
      }
    };
    return $.fn.cv = function(options) {
      return this.each(function() {
        var plugin;
        if ($(this).data("CV") === void 0) {
          plugin = new $.cv(this, options);
          return $(this).data("CV", plugin);
        }
      });
    };
  });

}).call(this);
