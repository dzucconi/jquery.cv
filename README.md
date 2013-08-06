A jQuery plugin that uses a Google Docs Spreadsheet as input in constructing a relatively normative CV-style output. Documents require "Type", "Category", and "Year" columns to group content. "Type" and "Category" columns are related to one another. Requires jQuery, jQuery.csv, and Underscore.

## Documenation

Basic usage:

```
https://docs.google.com/spreadsheet/pub?key=0AsxYR5Y3N6DjdHJWZDNNcjhmZ0ZSb2hFTjU0MDBjZ2c
```

```javascript
$("#element").cv({
  key: "0AsxYR5Y3N6DjdHJWZDNNcjhmZ0ZSb2hFTjU0MDBjZ2c"
});
```

Use your own templates:

```javascript
$("#element").cv({
  key: "0AsxYR5Y3N6DjdHJWZDNNcjhmZ0ZSb2hFTjU0MDBjZ2c",
  templates: {
    category: _.template("<p><%= category.name %></p>")
  }
});
```
