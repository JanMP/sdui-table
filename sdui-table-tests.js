// Import Tinytest from the tinytest Meteor package.
import { Tinytest } from "meteor/tinytest";

// Import and rename a variable exported by sdui-table.js.
import { name as packageName } from "meteor/sdui-table";

// Write your tests here!
// Here is an example.
Tinytest.add('sdui-table - example', function (test) {
  test.equal(packageName, "sdui-table");
});
