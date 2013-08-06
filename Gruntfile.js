module.exports = function (grunt) {
  grunt.initConfig({
    pkg: grunt.file.readJSON("package.json"),

    uglify: {
      plugin: {
        files: [{
          "js/jquery.cv.standalone.min.js": ["js/jquery.cv.js"],
          "js/jquery.cv.min.js": ["js/libs/jquery.csv-0.71.min.js", "js/libs/underscore-min.js", "js/jquery.cv.js"]
        }]
      }
    },

    coffee: {
      plugin: {
        files: [{
          "js/jquery.cv.js": ["js/jquery.cv.coffee"]
        }]
      }
    },

    watch: {
      files: ["js/jquery.cv.coffee"],
      tasks: ["coffee", "growl:coffee"]
    },

    growl: {
      coffee: {
        title: "CoffeeScript",
        message: "Compiled successfully"
      }
    }
  });

  grunt.loadNpmTasks("grunt-growl");
  grunt.loadNpmTasks("grunt-contrib-coffee");
  grunt.loadNpmTasks("grunt-contrib-watch");
  grunt.loadNpmTasks("grunt-contrib-uglify");

  mainTasks = ["coffee", "growl:coffee"]
  grunt.registerTask("default", mainTasks);
  grunt.registerTask("build", mainTasks.concat(["uglify"]));
};
