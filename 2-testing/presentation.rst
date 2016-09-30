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


Starting up vagrant
--------------------

* let's use a debian image


Vagrantfile pt. 1
------------------

* TODO



Vagrantfile pt. 5
-----------------

* TODO


Getting foot in the door
------------------------

* First run copy ssh pubkey and some other stuff

.. code-block:: bash

    $ ansible-playbook --ask-pass --ask-become-pass -i<hostname>, -vvv base_packages.yaml


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
* for older debian, other distros, use vagrant plugins

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

