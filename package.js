Package.describe({
  name: 'janmp:sdui-table',
  version: '0.0.1',
  // Brief, one-line summary of the package.
  summary: 'tables for SchemaDrivenUI',
  // URL to the Git repository containing the source code for this package.
  git: '',
  // By default, Meteor will default to using README.md for documentation.
  // To avoid submitting documentation, set this field to null.
  documentation: 'README.md'
});

Package.onUse(function (api) {
  api.versionsFrom('2.3');
  // api.addFiles('imports/ui/fixedReactVirtualized.css', 'client');
  api.use('ecmascript');
  api.use('coffeescript');
  api.use('typescript');
  api.use('janmp:sdui-forms');
  api.use('janmp:sdui-rolechecks');
  api.use('janmp:sdui-backend');
  api.mainModule('sdui-table-dynamic.coffee');
});

Package.onTest(function (api) {
  api.use('ecmascript');
  api.use('coffeescript');
  api.use('typescript');
  api.use('tinytest');
  api.use('janmp:sdui-forms');
  api.use('janmp:sdui-rolechecks');
  api.use('janmp:sdui-backend');
  api.use('sdui-table');
  api.mainModule('sdui-table-tests.js');
});
