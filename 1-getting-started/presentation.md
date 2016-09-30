footer: Myles Braithwaite | [mylesb.ca](https://mylesb.ca/) | [me@mylesb.ca](mailto:me@mylesb.ca) | [@mylesb](https://twitter.com/mylesb)
slidenumbers: true

# [fit] Ansible

# [fit] Orchestrate your infustrature like **Gustav Mahler**[^1]

[^1]: Gustav Mahler is the first result when you Google _famous conductors_.

---

![left](media/001-gustav-mahler.jpg)

> If a developer could say what they had to say in words they would not bother tyring to say it in code.
>
> -- Gustav Mahler *(paraphrasing)*

---

# Turn your infrastructure administration into a codebase.

^ Ansible is a configuration management and provision tool for *Infrastructure as Code*.
Which means it automates the job of manual configuration and setting up of computers.
Similar to Chef, Puppet, CFEngine, or Salt.

---

![inline](media/002-ansible-network-diagram.png)

^ Ansible uses the push method for provisioning.
Orchestration begins on the controling machine though an Ansible *playbook*.
Deployment happens over SSH where Ansible modules are temporarily stored on the nodes and communicate with the controlling machine though a JSON protocol over the standard output.
Because Ansible uses the push method it does not consume resources because no daemons or programs are running in the backgroud.
This is the major difference between Ansible and toher provisioning tools like Puppet.

---

```python
>>> import this
The Zen of Python, by Tim Peters

Beautiful is better than ugly.
Explicit is better than implicit.
Simple is better than complex.
Complex is better than complicated.
Flat is better than nested.
Sparse is better than dense.
Readability counts.
Special cases aren't special enough to break the rules.
Although practicality beats purity.
Errors should never pass silently.
Unless explicitly silenced.
In the face of ambiguity, refuse the temptation to guess.
There should be one-- and preferably only one --obvious way to do it.
Although that way may not be obvious at first unless you're Dutch.
Now is better than never.
Although never is often better than *right* now.
If the implementation is hard to explain, it's a bad idea.
If the implementation is easy to explain, it may be a good idea.
Namespaces are one honking great idea -- let's do more of those!
>>>
```

^ I perfer Ansible because I feel it's the only provisioning system that follows *The Zen of Python*.
Ansible five design goals are:

---

# Minimal in nature.

^ A provisioning system should not impose additional dependencies on the environment. The only requirement is SSH.
This is my second favorite thing about Ansible.

---

# Consistent.

^ Everytime you run an Ansible playbook it should not contain any logical contradictions.

---

# Secure.

^ Ansible doesn't deploy agents to the nodes. Only OpenSSH is required, which is thoroughly tested.

---

# High reliable.

^ When carefully written, an Ansible playbook will not have unexpected side-effects on the managed systems.

---

# Low learning curve.

^ Playbooks use an easy and descriptive language based on YAML and Jinja templates.
This is why I think Ansible is far better than Puppet.

---

```yaml
- hosts: all
  become: yes
  become_user: root
  
  tasks:
    - name: update apt cache
      apt:
        update_cache: yes
    
    - name: upgrade all safe packages
      apt:
        upgrade: safe
```

^ Here is an example of an Ansible playbook, let's break it down:

---

```yaml
- hosts: all
  become: yes
  become_user: root
```

^ The first line we are saying we want all the hosts in our Inventory file to be provisioned *(more on the Inventory file later)*.
The next two lines we are using the `become` module to use the existing privilege escalation tool on our distro to become root.
Any module referenced here will run global though the process.

---

```yaml
tasks:
  - name: update apt cache
    apt:
      update_cache: yes
  
  - name: upgrade all safe packages
    apt:
      upgrade: safe
```

^ The last bit we are is the tasks we want to run on the nodes.
Here we are updating the aptitude cache and then running a safe upgrade on all the packages.

---

# First Ten Minutes on a Server Playbook[^2]

## A simple *Ansible Playbook* for setting up an Ubuntu server.

[^2]: If you want to follow along the playbook is here: <https://git.io/vPLE3>.

^ Let's go though a simple Ansible Playbook I though together.

---

![fill](media/003-directory-layout.png)

^ Here is the directory structure of the of the Playbook.
`ansible.cfg` is basically the configuration of the `ansible-playbook` command.
`hosts` is our inventory file (where we store where in the world the nodes are lcoated).
`playbook.yml` is the our Playbook tasks are stored.
`vars.yml` is where we store the variables for our Playbook.

---

```yaml
- name: create the user accounts
  user:
    name: "{{ item.username }}"
    password: "{{ item.password }}"
    state: present
    shell: /bin/bash
    groups: sudo
    generate_ssh_key: yes
  with_items:
    - username: myles
      password: password
    - username: alex
      password: drowssap
  tags: users
```

^ Let's take a look at an interesting task in this Playbook.
Here we are creating a user on the node and settings a their password, making sure they are using the bash shell, adding them to the group sudo, and generating a SSH key.
At the bottom of the task you'll notice the `tags` variable. This is used to group tasks.
We are using the `with_items` so we don't have to create two tasks for both of our users.
Our Playbook is going to grow over time so it's probably not a good idea to store the user's meta data in the Playbook itself.

---

# `vars.yml`

```yaml
users:
  - username: myles
    password: password
    atuhorized_key: ~/Downloads/myles-id_rsa.pub
  - username: alex
    password: drowssap
    public_keys: ~/Downloads/alex-id_rsa.pub
```

^ So let's use the variables file to store that meta data.
Will just copy over the info to the `vars.yml` file and we are also going to add some more information on where these uses are storing their SSH public keys (as they don't seem to have very strong passwords).

---

```yaml
- name: create the user accounts
  user:
    name: "{{ item.username }}"
    password: "{{ item.password }}"
    state: present
    shell: /bin/bash
    groups: sudo
    generate_ssh_key: yes
  with_items:
    - "{{ users }}"
  tags: users
```

^ Now let's update the `with_items` info pointing to the variables file.

---

# Tags are Important

^ Just a side note you tags are really important to do right away.
They are useful because Ansible will run the entire playbook everytime and if you have a large one it will take a while to run.

---

```yaml
- name: disallow password authentication
  lineinfile:
    dest: /etc/ssh/sshd_config
    regexp: "^PasswordAuthentication"
    line: "PasswordAuthentication no"
    state: present
  notify: restart ssh
  tags: acl
```

^ Also because the uses have such bad passwords we are going to disable login by password in the sshd config file.
Here we are using hte `lineinfile` module to find the option `PasswordAuthentication` and making sure it reads `PasswordAuthentication no`.
The second last directive here is the notifying the handler to restart ssh.

---

```yaml
handlers:
  - name: restart ssh
    service:
      name: ssh
      state: restarted
```

^ You might be asking what a handler.
A handler is just like an Ansible Task but is only run when the a Task contains a `notify` directive.
This is useful for when a configuration file is updated and you want to reload/restart the service.
Handlers can also be used to do an inital import of a database.

---

# `hosts`

```
[servers]
127.0.0.1
```

^ This is the Playbooks inventory file.
Here is where we say where the nodes are located.
This is a basic one where the node is the localhost in the servers group.

---

```
$ ansible-playbook ./playbook.yml \
                   --inventory-file=./hosts \
                   --user=root \
                   --ask-pass
```

^ This is the command for running the playbook.
We speify the playbook file, where the inventory file is located, the remote user we are connecting to the server with, and that we wont to be prompt for a password.
