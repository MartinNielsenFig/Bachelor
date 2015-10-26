// Karma configuration
// Generated on Tue Oct 06 2015 13:43:53 GMT+0200 (Rom, sommertid)

module.exports = function(config) {
  config.set({

    // base path that will be used to resolve all patterns (eg. files, exclude)
    basePath: '',


    // frameworks to use
    // available frameworks: https://npmjs.org/browse/keyword/karma-adapter
    frameworks: ['jasmine'],


    // list of files / patterns to load in the browser
    files: [
      'WisR.Tests/Scripts/jasmine/jasmine.js',
      'WisR.Tests/Scripts/ResoursesForTest/en-GB.js',
      'WisR/Scripts/CryptoJS/rollups/sha512.js',
      'WisR/Scripts/jquery-1.11.3.js',
      'WisR/Scripts/jquery.signalR-2.2.0.js',
      'WisR/Scripts/angular.js',
      'WisR/Scripts/angular-mocks.js',
      'WisR/Scripts/angular-base64-upload.js',
      'WisR/Scripts/scrollglue.js',
      'WisR/Scripts/Chart.js',
      'WisR/Scripts/angular-chart.js',
      'WisR.Tests/Scripts/SignalRForTest/server.js',
      'WisR/Scripts/WisRScripts/AngularModule.js',
      'WisR/Scripts/WisRScripts/**.js',
      'WisR.Tests/Scripts/Test/AngularHomeTest.js'
    ],

    
    // list of files to exclude
    exclude: [
        'WisR/Scripts/WisRScripts/geolocationScripts.js'
    ],

    
    // preprocess matching files before serving them to the browser
    // available preprocessors: https://npmjs.org/browse/keyword/karma-preprocessor
    preprocessors: {
        'WisR/Scripts/WisRScripts/**.js': 'coverage'
    },


    // test results reporter to use
    // possible values: 'dots', 'progress'
    // available reporters: https://npmjs.org/browse/keyword/karma-reporter
    reporters: ['progress','coverage'],


    // web server port
    port: 9876,


    // enable / disable colors in the output (reporters and logs)
    colors: true,


    // level of logging
    // possible values: config.LOG_DISABLE || config.LOG_ERROR || config.LOG_WARN || config.LOG_INFO || config.LOG_DEBUG
    logLevel: config.LOG_INFO,


    // enable / disable watching file and executing tests whenever any file changes
    autoWatch: true,


    // start these browsers
    // available browser launchers: https://npmjs.org/browse/keyword/karma-launcher
    browsers: ['Chrome'],


    // Continuous Integration mode
    // if true, Karma captures browsers, runs the tests and exits
    singleRun: false
  })
}
