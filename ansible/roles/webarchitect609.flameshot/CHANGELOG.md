Changelog
=========

2.0.2
-----

### Fixed:
    
- latest stable release version could be release-candidate like `v11.0.rc1` due to poor tag filtering;
- installed version check was broken since v11.0.0 `flameshot --version` output goes to stderr, not stdout.

2.0.1
-----

### Fixed

- version checking before apt and snap packages uninstallation led to skip compile when the same version is installed
  via snap or apt.

### Changed

- print the state of startup flag.

2.0.0
-----

### BREAKING CHANGES

- `Flameshot` will be compiled from the source at latest stable version and set to run at startup by default;
- any `apt` or `snap` versions of `Flameshot` will be uninstalled before compiling from the source;
- only `Flameshot > 0.6.0` at `Ubuntu 20.04 LTS Focal Fosa` is supported so far.

1.0.2
-----

### Fixed

- `Flameshot 0.6.0` is fixed for compiling and is the newest possible version this role can compile since it does not
  support `cmake`.

### BREAKING CHANGES

- `Ubuntu 16.04 LTS Xenial Xerus` support removed.
