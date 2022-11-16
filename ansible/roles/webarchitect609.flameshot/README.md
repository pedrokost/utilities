Ansible Role: Flameshot
=======================
[![Build Status](https://github.com/webarchitect609/ansible-role-flameshot/workflows/build/badge.svg?branch=master)](https://github.com/webarchitect609/ansible-role-flameshot/actions?query=workflow%3Abuild)
[![Latest version](https://img.shields.io/github/v/tag/webarchitect609/ansible-role-flameshot?sort=semver)](https://github.com/webarchitect609/ansible-role-flameshot/releases)
[![Downloads](https://img.shields.io/ansible/role/d/47127)](https://galaxy.ansible.com/webarchitect609/flameshot)
[![License](https://img.shields.io/github/license/webarchitect609/ansible-role-flameshot)](LICENSE.md)
[![More stuff from me](https://img.shields.io/badge/galaxy-webarchitect609-000)](https://galaxy.ansible.com/webarchitect609)

Compiles [Flameshot](https://flameshot.org/) ≥ `0.8.0`
from [the source code](https://github.com/lupoDharkael/flameshot) and installs it. Or just installs apt package.

Requirements
------------

[Flameshot dependencies for runtime and compilation](https://github.com/lupoDharkael/flameshot#dependencies) can be
found in the README file of the corresponding source repo.

Role Variables
--------------

None of the variables need to be altered for compiling and installing the latest stable version of the application or
updating it. However, all available variables are listed below, along with default values (see `defaults/main.yml`):

    flameshot_compile: true

If `true` Flameshot will be compiled from the source.

    flameshot_compile_version: "latest-stable"

Which version(git tag) or branch to compile or special value `latest-stable` to always install the latest stable
version.

    flameshot_source_repo: "https://github.com/lupoDharkael/flameshot.git"

Which git repo use to compile from. Active only when `flameshot_compile: true`.

    flameshot_enable_autostart: true

Run flameshot at startup.

Dependencies
------------

None.

Example Playbook
----------------

    - hosts: servers
      roles:
         - { role: webarchitect609.flameshot }

License & Author Information
-------
[BSD-3-Clause](LICENSE.md)
