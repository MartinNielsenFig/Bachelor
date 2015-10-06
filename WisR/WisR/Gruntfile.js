module.exports = function (grunt) {
    'use strict';
    grunt.initConfig({
        // read in the project settings from the package.json file into the pkg property
        pkg: grunt.file.readJSON('package.json'),
        ngdocs: {
        options: {
                dest: 'docs',
                scripts: ['Scripts/angular.js',"Scripts/angular-animate.js"],
                title: 'API Documentation'
        },
        api: {
            src: ['Scripts/WisrScripts/*.js'],
                title: 'My Documentation'
        }
    }
    });

    //Add all plugins that your project needs here
    grunt.loadNpmTasks('grunt-ngdocs');
};