# Knife Azure

[![Gem Version](https://badge.fury.io/rb/knife-azure.svg)](https://rubygems.org/gems/knife-azure)
[![Build Status](https://travis-ci.org/chef/knife-azure.svg?branch=master)](https://travis-ci.org/chef/knife-azure)

## Description
A [knife] (http://docs.chef.io/knife.html) plugin to create, delete, and enumerate
[Microsoft Azure] (https://azure.microsoft.com) resources to be managed by Chef.

NOTE: You may also want to consider using the [azure-xplat-cli](https://github.com/Azure/azure-xplat-cli),
this application is written by the Azure team and has many other integrations with
Azure. If click [here](https://github.com/chef-partners/azure-chef-extension/blob/master/examples/azure-xplat-cli-examples.md)
you'll see deeper examples of using the Chef extension and Azure.

## Installation
Be sure you are running the latest version of Chef DK, which can be installed
via:

    https://downloads.chef.io/chef-dk/

This plugin is distributed as a Ruby Gem. To install it, run:

```bash
chef gem install knife-azure
```

Depending on your system's configuration, you may need to run this command
with root/administrator privileges.

## Modes
`knife-azure 1.6.0` onwards, we are adding support for Azure Resource Manager. You can easily switch between the

* Service management: commands using the Azure service management API
* Resource manager: commands using the Azure Resource Manager API

They are not designed to work together. Commands starting with `knife azure` use ASM mode, while commands starting with `knife azurerm` use ARM mode.

PLEASE NOTE that `Azuererm` subcommands are experimental and of alpha quality. Not suitable for production use. Please use ASM subcommands for production.

## Configuration
1. [ASM Mode] (docs/configuration.md)
2. [ARM Mode] (docs/configuration.md)

## Details Usage for ASM and ARM mode

1. [ASM Mode] (docs/ASM.md)
2. [ARM Mode] (docs/ARM.md)
