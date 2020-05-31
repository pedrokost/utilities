# Ansible Role: joplin

This is an Ansible role to install the [Joplin](https://joplinapp.org/) open
source note taking and to-do application with synchronization capabilities.

This happens to be what I am ***currently*** using in an effort to replace
Evernote.  I am syncing via a [Nextcloud](https://nextcloud.com/) instance
hosted freely at [hostiso](https://hostiso.com/)

## Overview

At a very high level, this role will:

* I have attempted to Ansiblize the developer's installation/update script and
  it is working sufficiently at this point to "install" the AppImage
* [*optional*] if settings are provided, the CLI version will be installed and
  used to create a database, which will be configured via the command line and
  then copied to the desktop directory...seems to work

This role is currently passing my pretty rudimentary tests for the following
operating systems:

* centos7
* fedora27
* fedora28
* fedora29
* ubuntu16
* ubuntu18
* debian8
* debian9

The testing of this role is very specific to the role I've set up in molecule,
but I think I'm ok with that.

## Important Notes

* because of the way that AppImage's are designed, it cannot be done system-wide
  and instead needs to go into a user's home directory, so a user and username
  *MUST* be specified or nothing happens
* I put some effort into finding the type of desktop so I could send it in the
  command like: `XDG_CURRENT_DESKTOP={{ desktop.stdout }}
  /tmp/Joplin_install_and_update.sh` but it is just not worth the effort.
  Instead, I just blindly put a file in `~/.local/share/applications` and if
  your desktop uses it, GREAT!
* I do ZERO checking of settings if passed.  I found the best way to determine
  what settings were set was to configure Joplin as I wanted it, then to do a
  silly command to find out what was set how:
  `sqlite3 ~/.config/joplin-desktop/database.sqlite .dump | grep '^INSERT INTO
  settings'`  ***UPDATE:*** check out
  [the terminal config page](https://joplinapp.org/terminal/)
* testing the configuration in a container *might not be possible*:
  <https://github.com/AppImage/AppImageKit/wiki/FUSE>

## Requirements

Any package or additional repository requirements will be addressed in the role.

## Role Variables

All of these variables should be considered **optional** however, be aware that
sanity checking is minimal (if at all).  Also, if a user is not passed, nothing
will be done:

* `users` *an AppImage is used per user, and this nested list of users allows
  for the specification of numerous users*
  * `username`
    * this is the username on the OS **NOTE: this role will not create the
      user!**
  * `settings`
    * this is a list of settings with key/value pairs.  I really do not know the
      best way to determine what is a valid key or value so no sanity checking
      is done.  This is because it is simply put into a "settings" table in a
      sqlite database in the users's home directory **please see example**

## Example Playbook

Playbook with various options specified:

```yaml
- hosts: localhost
  connection: local
  roles:
    - role: ansible-role-joplin
      users:
        - username: test_usr1
          settings:
            - { key: "sidebarVisibility", val: "1" }
            - { key: "dateFormat", val: "YYYY-MM-DD" }
            - { key: "sync.target", val: "5" }
```

## Inclusion

I envision this role being included in a larger project through the use of a
`requirements.yml` file.  So here is an example of what you would need in your
file:

```yaml
# get the joplin role from github
- src: https://github.com/thisdwhitley/ansible-role-joplin.git
  scm: git
  name: joplin
```

Have the above in a `requirements.yml` file for your project would then allow
you to "install" it (prior to use in some sort of setup script?) with:

```bash
ansible-galaxy install -p ./roles -r requirements.yml
```

## Testing

Testing is not working as well as I'd like at this point.

I am relying heavily on the work by Jeff Geerling in using molecule for testing
this role.  I have, however, modified the tests to make them specific to what I
am attempting to accomplish but this could still use some work.

Please review those files, but here is a list of OSes currently being tested 
(using geerlingguy's container images):

* centos7
* fedora27
* fedora28
* fedora29
* ubuntu16
* ubuntu18
* debian8
* debian9

## To-do

* figure out an appropriate test.  Using AppImages does not work in containers
  [because of FUSE](https://github.com/AppImage/AppImageKit/wiki/FUSE#docker)

## References

* [How I test Ansible configuration on 7 different OSes with Docker](https://www.jeffgeerling.com/blog/2018/how-i-test-ansible-configuration-on-7-different-oses-docker)

## License

All parts of this project are made available under the terms of the [MIT
License](LICENSE).
