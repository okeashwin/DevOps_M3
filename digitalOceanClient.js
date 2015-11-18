var needle = require("needle");
var os = require("os");

var config = {};

config.token = "0f1b2054da477bc9e67080cb2e554cb8fb42595da2bbbe99bf9830306ae7c3f9";

var headers = {
        'Content-Type':'application/json',
        Authorization: 'Bearer ' + config.token
};

var dropletId = "";

var client = 
{
        createDroplet: function (dropletName, region, imageName, onResponse)
        {
                var data =
                {
                        "name": dropletName,
                        "region":region,
                        "size":"512mb",
                        "image":imageName,
                        // Id to ssh_key already associated with account.
                        "ssh_keys":["57:e6:f8:ce:7a:18:d1:64:da:ce:d7:94:9b:be:2c:d5"],
                        //"ssh_keys":null,
                        "backups":false,
                        "ipv6":false,
                        "user_data":null,
                        "private_networking":null
                };

                needle.post("https://api.digitalocean.com/v2/droplets", data, {headers:headers,json:true}, onResponse );
        },

	     getDropletIp: function(dropletId, onResponse)
	     {
		        needle.get("https://api.digitalocean.com/v2/droplets/"+dropletId, {headers:headers}, onResponse);
	     }
};

var name = "aboke" + os.hostname();
var region = "nyc1";
var image = "ubuntu-14-04-x64";
client.createDroplet(name, region, image, function(err, response, body)
{
      // StatusCode 202 - Means server accepted request
      if(!err && response.statusCode == 202)
      {
              var data = response.body;
              if(data.droplet)
              {
                  dropletId = data.droplet.id;
                  //console.log("Droplet ID received : "+ dropletId);
		  console.log("Waiting for a minute for the instance to spin up");

                  setTimeout(function() {
                  // Get Droplet IP code goes here as we want to execute this once we have waited for a minute
                  client.getDropletIp(dropletId, function(err, response, body) {
                    //console.log("Into getDropletIp with dropletId : "+dropletId);
                    var data = response.body;
                    if(data.droplet)
                    {
                      var dropletIP = data.droplet.networks.v4[0].ip_address;
                      // Write this into the Ansible inventory file
		      console.log("Provisioned a server on Digital Ocean with IP :"+dropletIP);
                      fs = require('fs');
                      fs.appendFile('inventory', 
                                    'node0 ansible_ssh_host='+dropletIP+' ansible_ssh_user=root ansible_ssh_private_key_file=/home/ashwin_oke/ConfManagementWorkshop/.vagrant/machines/default/virtualbox/private_key\n', 
                                    function (err) {
                        if (err) 
                        {
                          return console.log(err);
                        }

                        fs.appendFile('inventory_IPs', dropletIP+'\n', function(err){
                          if(err)
                          {
                            return console.log(err);
                          }
                        })
                        
                        console.log('Instance successfully spun up. Added entry for this server in the inventory file');
                      });
                    }
                  });
                  }, 60000);
              }
      }
});
