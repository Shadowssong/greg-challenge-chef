Kitchen for setting up instance for Web Ops Challenge

----------------

Steps:

1) Install knife-solo gem  

    `gem install knife-solo`

2) Clone the repo  

    `git clone https://github.com/Shadowssong/greg-challenge-chef.git`


3) Install chef on the the target node  

    `knife solo prepare username@hostname -i ~/.ssh/identityfile`

4) Update your public key in `cookbooks/challenge-rails-server/templates/default/authorized_keys.erb`

5) Update the run list for the node_name inside of `nodes/` to show:

    `{"run_list":["recipe[challenge-rails-server]"]}`

6) Apply run list to the target node

	`knife solo cook username@hostname -N node_name -V -i ~/.ssh/identityfile`

The server will now be configured for the capistrano deployment of greg-challenge-rails:
https://github.com/Shadowssong/greg-challenge-rails
