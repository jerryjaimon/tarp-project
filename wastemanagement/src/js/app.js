App = {
  web3Provider: null,
  contracts: {},
  account: '0x0',

  init: function() {
    return App.initWeb3();
  },

  initWeb3: function() {
    if (typeof web3 !== 'undefined') {
      App.web3Provider = web3.currentProvider;
      web3 = new Web3(web3.currentProvider);
    } else {
      App.web3Provider = new Web3.providers.HttpProvider('http://localhost:8545');
      web3 = new Web3(App.web3Provider);
    }
    return App.initContract();
  },

  initContract: function() {
    $.getJSON("wastemanagement.json", function(wastemanagement) {

      App.contracts.Wastemanagement = TruffleContract(wastemanagement);
      App.contracts.Wastemanagement.setProvider(App.web3Provider);

      return App.render();
    });
  },

  render: function() {
    var wastemanagementInstance;
    var loader = $("#loader");
    var content = $("#content");

    loader.show();
    content.hide();

    // Load account data
    const accounts = web3.eth.accounts;
    
    web3.eth.getCoinbase(function(err, account) {
      if (err === null) {
        App.account = account;
        $("#accountAddress").html("Your Account: " + account);
      }
    });

    // Load contract data
    App.contracts.Wastemanagement.deployed().then(function(instance) {
      wastemanagementInstance = instance;
      return wastemanagementInstance.wasteBagId();
    }).then(function(wasteBagId) {
      var candidatesResults = $("#candidatesResults");
      candidatesResults.empty();
      console.log(wasteBagId);
      for (var i = 0; i < wasteBagId; i++) {
        wastemanagementInstance.wastebags(i).then(function(waste) {
          var user = waste[0];
          var weight = waste[1];
          var recyType = waste[2];
          var timestamp = waste[3];
          var status = waste[4];
          var locationtracking = waste[5];
          var candidateTemplate = "<tr><th>" + user + "</th><td>" + weight + "</td><td>" + recyType + "</td><td>" + timestamp+"</td><td>" + status+"</td><td>" + locationtracking+"</td></tr>"
          candidatesResults.append(candidateTemplate);
        });
      }

      loader.hide();
      content.show();
    }).catch(function(error) {
      console.warn(error);
    });
  }
};

$(function() {
  $(window).load(function() {
    App.init();
  });
});