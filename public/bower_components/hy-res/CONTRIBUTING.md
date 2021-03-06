# Contributing

### Code style
Regarding code style like indentation and whitespace, **follow the conventions you see used in the source already.**

### PhantomJS
While Gulp can run the included unit tests via [PhantomJS](http://phantomjs.org/), this shouldn't be considered a substitute for the real thing. Please be sure to test the unit test file(s) in _actual_ browsers. Test using [Karma](http://karma-runner.github.io/0.12/index.html) with the following steps:

* `$ gulp karma:watch`
* Load the karma server URL [http://localhost:9876/](http://localhost:9876/) in your browser.

## Modifying the code
First, ensure that you have the latest [Node.js](http://nodejs.org/) and [npm](http://npmjs.org/) installed.

Test that Gulp's CLI and Bower are installed by running `gulp --version` and `bower --version`.  If the commands aren't found, run `npm install -g gulp bower`.  For more information about installing the tools, see the [Getting Started with Gulp guide](https://github.com/gulpjs/gulp/blob/master/docs/getting-started.md#getting-started) or [bower.io](http://bower.io/) respectively.

1. Fork and clone the repo.
1. Run `npm install` to install all build dependencies (including Gulp).
1. Run `bower install` to install the front-end dependencies.
1. Run `gulp` to gulp this project.

Assuming that you don't see any red, you're ready to go. Just be sure to run `gulp test build` after making any changes, to ensure that nothing is broken.

## Submitting pull requests

1. Create a new branch, please don't work in your `master` branch directly.
1. Add failing tests for the change you want to make. Run `gulp test` to see the tests fail.
1. Fix stuff.
1. Run `gulp test` to see if the tests pass. Repeat steps 2-4 until done.
1. Open `test/*.html` unit test file(s) in actual browser to ensure tests pass everywhere.
1. Update the documentation to reflect any changes.
1. Push to your fork and submit a pull request.
