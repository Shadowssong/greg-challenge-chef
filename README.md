Kitchen for setting up instance for Web Ops Challenge

----------------

Steps:

1) Install knife-solo gem  

    `gem install knife-solo`

2) Clone the repo  

    `git clone https://github.com/Shadowssong/greg-challenge-chef.git`

3) Install chef on the the target node  

    `knife solo prepare username@hostname -i ~/.ssh/identityfile`

4) Apply run list to the target node

	Update run list for node_name inside of nodes/
	`knife solo cook username@hostname -N node_name -V -i ~/.ssh/id_rsa`

To clean:

    `knife solo clean username@hostname`
