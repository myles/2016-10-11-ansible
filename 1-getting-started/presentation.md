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