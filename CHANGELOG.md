# Changelog

- Fix#66: Added CHANGELOG.md to repository
- Added gemspec in Gemfile to enable bundler packaging
- Fix#67: OS is not a module (TypeError) on Windows
- Update ADB box Atls namespace to projectatomic/adb
- Update README to reflect latest code and project goals
- Update Vagrantfile for QuickStart guide

## v0.0.9 Nov 25, 2015

- Fix: Prevents TLS certs generation on every run of plugin


## v0.0.8  Nov 24, 2015

- Fix#40: Handle private networking for different providers and generate Docker daemon TLS certs accordingly
- Support backward compatibility with older versions of ADB boxes
- lib/command.rb : Fixes bash file check command
- Restart Docker daemon after generating correct TLS certs
- 
