Vagrant, hypervisors, debian automated install and other rants
##############################################################

What is Vagrant?
----------------

* A person without a settled home or regular work who wanders from place to place and lives by begging.
* Vagrant is an Open-source software product for building and maintaining portable virtual development environments
* Vagrant provides easy to configure, reproducible, and portable work environments.

Why Vagrant is useful?
----------------------

* Vagrant provides fully virtualized OS environment that can be build in seconds
* You need to debug a script, and a vargrant is your os undo button

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
    ==> box: Loading metadata for box 'debian/jessie64'
        box: URL: https://atlas.hashicorp.com/debian/jessie64
    ==> box: Adding box 'debian/jessie64' (v8.6.1) for provider: virtualbox
        box: Downloading: https://atlas.hashicorp.com/debian/boxes/jessie64/versions/8.6.1/providers/virtualbox.box
    ==> box: Successfully added box 'debian/jessie64' (v8.6.1) for 'virtualbox'!


Starting up a Vagrant box
-------------------------

* Add file named *Vagrantfile* with the following content

.. code-block:: ruby

    Vagrant.configure("2") do |config|
        config.vm.box = "debian/jessie64"
    end

Starting up a Vagrant box
-------------------------

* From the directory where *Vagrant* file is located
* Bring up the box:

.. code-block:: bash

    $ vagrant up
    Bringing machine 'default' up with 'virtualbox' provider...
    ==> default: Importing base box 'debian/jessie64'...
    ==> default: Matching MAC address for NAT networking...
    ==> default: Checking if box 'debian/jessie64' is up to date...
    ==> default: Setting the name of the VM: vagrant_default_1475977923656_21896
    ==> default: Clearing any previously set network interfaces...
    ==> default: Preparing network interfaces based on configuration...
        default: Adapter 1: nat
    ==> default: Forwarding ports...
        default: 22 (guest) => 2222 (host) (adapter 1)
    ==> default: Running 'pre-boot' VM customizations...
    ==> default: Booting VM...
    ==> default: Waiting for machine to boot. This may take a few minutes...
        default: SSH address: 127.0.0.1:2222
        default: SSH username: vagrant
        default: SSH auth method: private key

        default:
        default: Vagrant insecure key detected. Vagrant will automatically replace
        default: this with a newly generated keypair for better security.
        default:
        default: Inserting generated public key within guest...
        default: Removing insecure key from the guest if it's present...
        default: Key inserted! Disconnecting and reconnecting using new SSH key...
    ==> default: Machine booted and ready!
    ==> default: Checking for guest additions in VM...
        default: No guest additions were detected on the base box for this VM! Guest
        default: additions are required for forwarded ports, shared folders, host only
        default: networking, and more. If SSH fails on this machine, please install
        default: the guest additions and repackage the box to continue.
        default:
        default: This is not an error message; everything may continue to work properly,
        default: in which case you may ignore this message.
    ==> default: Installing rsync to the VM...
    ==> default: Rsyncing folder: /home/alex/tmp/vagrant/ => /vagrant

    ==> default: Machine 'default' has a post `vagrant up` message. This is a message
    ==> default: from the creator of the Vagrantfile, and not from Vagrant itself:
    ==> default:
    ==> default: Vanilla Debian box. See https://atlas.hashicorp.com/debian/ for help and bug reports


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

Running ansible script agains vagrant box
-----------------------------------------

.. code-block:: bash

    $ ansible-playbook --ssh_port=2222 -ilocalhost, -vvv base_packages.yaml



Getting foot in the door
------------------------

* First run copy ssh pubkey and some other stuff

.. code-block:: bash

    $ ansible-playbook --ask-pass --ask-become-pass --ssh_port=2222 -i<hostname>, -vvv base_packages.yaml


* Backup command if script fails and you need to debug it

.. code-block:: bash

    $ ansible-playbook -i<hostname>, -vvv base_packages.yaml

Comma after hostname is important
-------------------

* http://stackoverflow.com/questions/18195142/safely-limiting-ansible-playbooks-to-a-single-machine
* http://stackoverflow.com/questions/17188147/how-to-run-ansible-without-specifying-the-inventory-but-the-host-directly

Installing OpenSource hypervisor providers
-------------------------------------------

.. code-block:: bash

    # apt-get install vagrant-lxc vagrant-libvirt vagrant-mutate

* vagrant-lxc, vagrant-libvirt -- lxc and libvirt available in stretch and newer
* vagrant-mutate -- convert original images to lxc/libvirt

If packages aren't available
----------------------------

.. code-block:: bash

    $ vagrant plugin install vagrant-lxc vagrant-libvirt vagrant-mutate


Loading Debian Preseed in USB/CD images
---------------------------------------

* using preseeding -- https://www.debian.org/releases/jessie/i386/apbs02.html.en
* edit iso -- https://wiki.debian.org/DebianInstaller/Preseed/EditIso
* Really fragile!


Loop mount ISO images and copy the content
-------------------------------------------

.. code-block:: bash

    # mkdir loopdir
    # mount -o loop debian-8.5.0-amd64-CD-1.iso loopdir
    # mkdir cd
    # rsync -a -H --exclude=TRANS.TBL loopdir/ cd
    # umount loopdir

Hack initrd
-----------

.. code-block:: bash

    # mkdir irmod
    # cd irmod
    # gzip -dc ../cd/install.amd/initrd.gz | \
        cpio --extract --verbose --make-directories --no-absolute-filenames


Copy config file to preseed.cfg and assemble initrd
---------------------------------------------------

.. code-block:: bash

    # cp ../mail-template-selections.conf preseed.cfg
    # find . | cpio -H newc --create --verbose | gzip -9 > ../cd/install.amd/initrd.gz
    # cd ../
    # rm -rf irmod


Generate an image
-----------------

.. code-block:: bash

    # genisoimage -o debian-amd64-preseed.iso -r -J -no-emul-boot -boot-load-size 4  \
        -boot-info-table -b isolinux/isolinux.bin -c isolinux/boot.cat ./cd

