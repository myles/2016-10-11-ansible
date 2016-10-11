Vagrant, hypervisors, debian automated install and other rants
##############################################################

What is Vagrant?
----------------

* Vagrant provides easy to configure, reproducible, and portable work environments.

Why Vagrant is useful?
----------------------

* Drafting and testing ansible scripts

Installing Vagrant
------------------

.. code-block:: bash

    # apt-get install vagrant

* This command will also pull virtualbox


Getting a Vagrant box
---------------------

* let's use a debian image
* Go to https://atlas.hashicorp.com/boxes/search
* https://atlas.hashicorp.com/debian/boxes/jessie64
* Box name is debian/jessie64

Downloading a box on the system
-------------------------------

.. code-block:: bash

    $ vagrant box add debian/jessie64



Starting up a Vagrant box
-------------------------

* Add file named *Vagrantfile* with the following content

.. code-block:: ruby

    VAGRANTFILE_API_VERSION = "2"
    Vagrant.configure("2") do |config|
        config.vm.box = "debian/jessie64"
    end

Starting up a Vagrant box
-------------------------

* From the directory where *Vagrant* file is located
* Bring up the box:

.. code-block:: bash

    $ vagrant up


.. image:: media/01-vagrant-vbox.png


Display vagrant machine ssh configuration
-----------------------------------------

.. code-block:: bash

    $ vagrant ssh-config
    Host default
        HostName 127.0.0.1
        User vagrant
        Port 2222
        UserKnownHostsFile /dev/null
        StrictHostKeyChecking no
        PasswordAuthentication no
        IdentityFile /home/alex/git/gtalug/2016-10-11-ansible/2-testing/01-base/.vagrant/machines/default/virtualbox/private_key
        IdentitiesOnly yes
        LogLevel FATAL


Log into vagrant box
--------------------

.. code-block:: bash

    $ vagrant ssh


Ansible machine configuration ansible.cfg
-----------------------------------------

.. code-block:: ini

    [defaults]
    hostfile = hosts
    remote_user = vagrant
    private_key_file = .vagrant/machines/default/virtualbox/private_key
    host_key_checking = False


Ansible hosts file
------------------

.. code-block:: ini

    [test]
    testserver ansible_ssh_host=127.0.0.1 ansible_ssh_port=2222

Testing SSH connectivity
-----------------------

.. code-block:: bash

    $ ansible test -m ping
    testserver | SUCCESS => {
        "changed": false,
        "ping": "pong"
    }


Running script on vagrant box
-----------------------------

.. code-block:: bash

    $ ansible-playbook -vvv base-packages.yaml


Using different hypervisors
---------------------------

* This works however virtualbox is not a preferred hypervisor.
* It is not possible to run more than one hypervisor at a time.

Installing OpenSource hypervisor providers
-------------------------------------------

.. code-block:: bash

    # apt-get install vagrant-libvirt vagrant-mutate

* vagrant-libvirt -- libvirt available in stretch and newer
* vagrant-mutate -- convert original images to libvirt

If packages aren't available
----------------------------

.. code-block:: bash

    $ vagrant plugin install vagrant-libvirt vagrant-mutate


Download vagrant libvirt box
---------------------------

Install *libvirt* version of the machine

.. code-block:: bash

    # apt-get install vagrant-libvirt
    $ vagrant box add debian/jessie64 --provider=libvirt


libvirt Vagrantfile configuration
---------------------------------


.. code-block:: ruby

    VAGRANTFILE_API_VERSION = "2"
    Vagrant.configure("2") do |config|
        config.vm.provider :libvirt do |libvirt|
            libvirt.host = 'localhost'
            libvirt.username = 'alex'
            libvirt.connect_via_ssh = true
        end
        config.vm.define :libvirt_vm do |machine|
            machine.vm.box = "debian/jessie64"
        end
    end


Start up vagrant libvirt box
----------------------------

.. code-block:: bash

    $vagrant up --provider=libvirt


.. image:: media/02-vagrant-libvirt.png

Vagrant ssh config for virtualbox is different
----------------------------------------------

.. code-block:: bash

    $ vagrant ssh-config
    Host libvirt_vm
      HostName 192.168.121.237
      User vagrant
      Port 22
      UserKnownHostsFile /dev/null
      StrictHostKeyChecking no
      PasswordAuthentication no
      IdentityFile /home/alex/git/gtalug/2016-10-11-ansible/2-testing/02-vagrant-libvirt/.vagrant/machines/libvirt_vm/libvirt/private_key
      IdentitiesOnly yes
      LogLevel FATAL
      ProxyCommand ssh 'localhost' -l 'alex' -i '/home/alex/.ssh/id_rsa' nc %h %p


Update ansible.cfg settings
---------------------------

* Set a new path to private_key_file

.. code-block::

    private_key_file = .vagrant/machines/libvirt_vm/libvirt/private_key

Update hosts settings
---------------------

.. code-block::

    vagrant_libvirt ansible_ssh_host=192.168.121.237 ansible_ssh_port=22

Run ansible ping command
------------------------

.. code-block:: bash

    $ ansible test -m ping
    testserver | SUCCESS => {
        "changed": false,
        "ping": "pong"
    }

Creating preseed file
---------------------

* Install debian system answering all the install questions
* Install debian-installer package on the system
* Extract the answers

Preseed Answers extraction
--------------------------

.. code-block:: bash

    # debconf-get-selections --installer > ${HOME}/preseed.cfg
    # debconf-get-selections >> ${HOME}/preseed.cfg



Getting from bare metal to Ansible with Debian automated install
----------------------------------------------------------------

* Ugly shell script in *gen_iso.sh
* Creates iso with preseed file based on debian-8.6.0-amd64-CD-1.iso


Running an installation with preseed.cfg
----------------------------------------

    * See the video.


Getting foot in the door
------------------------

* First run copy ssh pubkey and some other things on a new system

.. code-block:: bash

    $ ansible-playbook --ask-pass --ask-become-pass --ssh_port=2222 -i<hostname>, -vvv base_packages.yaml


* Backup command if script fails and you need to debug it

.. code-block:: bash

    $ ansible-playbook -i<hostname>, -vvv base_packages.yaml

Comma after hostname is important
-------------------

* http://stackoverflow.com/questions/18195142/safely-limiting-ansible-playbooks-to-a-single-machine
* http://stackoverflow.com/questions/17188147/how-to-run-ansible-without-specifying-the-inventory-but-the-host-directly


Loading Debian Preseed in USB/CD images
---------------------------------------

* using preseeding -- https://www.debian.org/releases/jessie/i386/apbs02.html.en
* edit iso -- https://wiki.debian.org/DebianInstaller/Preseed/EditIso
* Really fragile!

