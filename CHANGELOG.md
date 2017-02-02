# Redmine2 CHANGELOG

This file is used to list changes made in each version of the redmine2 cookbook.

## 0.5.0

- Add support for Chef 12
- Drop support for Chef 11
- Drop restriction on mysql cookbook version (with breaking changes to mysql attributes)
- Add documentation for all support redmine attributes
- Add upstart and systemd service scripts. Use upstart by default
- Remove runit service script
- Add attribute `['redmine']['environment']` to set application environment
- Use redmine 3.3.2 and ruby 2.3.1 by default
- Change depend from nginx to chef_nginx cookbook

## 0.4.2

Changes up to 0.4.2 not recorded

## 0.1.0

- [Anton Minin] - Initial release of redmine2

- - -
Check the [Markdown Syntax Guide](http://daringfireball.net/projects/markdown/syntax) for help with Markdown.

The [Github Flavored Markdown page](http://github.github.com/github-flavored-markdown/) describes the differences between markdown on github and standard markdown.
