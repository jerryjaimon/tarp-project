var Wastemanagement = artifacts.require("./Wastemanagement.sol");

module.exports = function(deployer) {
  deployer.deploy(Wastemanagement);
};

