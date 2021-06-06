var Wastemanagement = artifacts.require("./Wastemanagement.sol");

contract("Wastemanagement", function(accounts) {
  var wastebagInstance;

  it("initializes with two wastebags", function() {
    return Wastemanagement.deployed().then(function(instance) {
      return instance.wasteBagId();
    }).then(function(count) {
      assert.equal(count, 2);
    });
  });
  it("it initializes the wastebags with the correct values", function() {
    return Wastemanagement.deployed().then(function(instance) {
      wastebagInstance = instance;
      return wastebagInstance.wastebags(1);
    }).then(function(wastebag) {
      assert.equal(wastebag[0], 1, "contains the correct id");
      assert.equal(wastebag[1], "wastebag 1", "contains the correct name");
      assert.equal(wastebag[2], 0, "contains the correct votes count");
      return wastebagInstance.wastebags(2);
    }).then(function(wastebag) {
      assert.equal(wastebag[0], 2, "contains the correct id");
      assert.equal(wastebag[1], "wastebag 2", "contains the correct name");
      assert.equal(wastebag[2], 0, "contains the correct votes count");
    });
  });
});