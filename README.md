# Roundsman

This is an attempt to combine the powers of [Capistrano](http://capify.org) and
[chef-solo](http://wiki.opscode.com/display/chef/Chef+Solo).

The only thing you need is SSH access and a supported OS. At this time only
Ubuntu is supported.

## Introduction

You can skip this if you already know about Capistrano and Chef.

Installing servers can be tedious work. Keeping your configuration in sync can
be hard too. Chef is an excellent tool for managing this. It can provision your
server from scratch. It can also be run again and again to check and update
your configuration if needed.

Capistrano is an excellent tool for deployment. It can deploy your code on
multiple machines, with clever defaults, limited downtime and the ability to
quickly roll back your deployment if something has gone wrong.

Roundsman aims to integrate Capistrano and Chef. This means that with every
deploy, it can check and update your configuration if needed. Are you using a
new version of Ruby in your next release? It will automatically install when
you deploy! Adding a new machine to your cluster? No problem! Roundsman will go
from a bare bones Linux machine to a working server in minutes!

Before you can use Roundsman, you need to know how to use Capistrano and how to
write Chef recipes. Here are some resources you might want to check out:

* [Capistrano's homepage](http://capify.org)
* [Opscode, the company behind Chef](http://www.opscode.com)
* [The wiki page on Chef Solo](http://wiki.opscode.com/display/chef/Chef+Solo)
* [The wiki page on creating Chef recipes](http://wiki.opscode.com/display/chef/Resources)
* [Railscast on Chef Solo](http://railscasts.com/episodes/339-chef-solo-basics) (paid)
* [Railscast on Capistrano Tasks](http://railscasts.com/episodes/133-capistrano-tasks-revised)
* [Railscast on digging deeper into Capistrano](http://railscasts.com/episodes/337-capistrano-recipes) (paid)

Feeling comfortable you can tackle deploying your application with Capistrano
and Chef? Now you can use Roundsman to combine them.

## Installing

Roundsman runs on Ruby 1.8.7 and above.

If you're using Bundler, you can add Roundsman to your Gemfile:

``` ruby
# Gemfile

gem 'roundsman', :require => false
```

Run `bundle install` to get it.

If you're not using Bundler, you can install Roundsman by hand:

``` bash
$ gem install roundsman
```

And "capify" your project:

``` bash
$ capify .
```

Next, load Roundsman in `Capfile`

``` ruby
# Capfile

require 'roundsman/capistrano'
```

## Usage

By default, Roundsman assumes you put your Chef cookbooks inside
`config/cookbooks`. If you don't like this, see the
[Configuration](#Configuration) chapter. But here we're going to use that.

I'm also going to assume that you put all Capistano configuration inside
`config/deploy.rb`. When you have a lot of configuration or use the multistage
extension, you might want to place it elsewhere.

After configuring Capistrano and writing and downloading Chef recipes, you can
hook them up, with a Capistrano hook. Simply provide provide a run list. Let's
say you want to run the default recipe of your own cookbook, called `main`.

``` ruby
# config/deploy.rb

before "deploy:update_code" do
  roundsman.run "recipe[main]"
end
```

I'm hooking it up before the `update_code` command, and not before `deploy` so
it will also run when running `cap deploy:migrations`.

Setting up a webserver usually requires that you have the code already there;
otherwise restarting nginx or Apache will fail, because it cannot find your
application yet. To remedy that you can make another recipe that will configure
your webserver and have it run after deploying your new code:

``` ruby
# config/deploy.rb

after "deploy:symlink" do
  roundsman.run "recipe[main::webserver]"
end
```

If you want a recipe to only run on a specific role, you can do so like this:

``` ruby
# config/deploy.rb

namespace :install do
  task :postgres, :roles => [:db] do
    roundsman.run "recipe[main::postgres]"
  end
end

before "deploy:update_code", "install:postgres"
```

## Configuration

By default, Roundsman will make a lot of Capistrano's configuration available to chef.

So, you might have these settings:

``` ruby
# config/deploy.rb

set :application, "my-awesome-blog"
set :rails_env, "production"
set :deploy_to, "/var/www/#{application}-#{rails_env}"
set :user, "deployer"
```

Here's how you can use them inside your recipes:

``` ruby
# config/cookbooks/main/recipes/default.rb

directory File.join(node[:deploy_to], "uploads") do
  owner node[:user]
  owner node[:user]
  recursive true
end
```

Every configuration option from Capistrano is available in Chef. If your using
the [passenger_apache2](https://github.com/opscode-cookbooks/passenger_apache2)
cookbook for example, you can set the attributes like this:

``` ruby
# config/deploy.rb

set :passenger, :version => "3.0.12", :max_pool_size => 4
```

There are also a set of configuration options for Roundsman itself. They all
have sensible defaults, but you can override them if needed. To read all the
default configuration:

``` bash
$ cap roundsman:configuration
```


You can also perform a lot of tasks by hand if you need to. Here's how to get
information:

``` bash
$ cap --tasks roundsman
```

To get more information, use the `--explain` flag and specify a task name, like
this:

``` bash
$ cap --explain roundsman:install_ruby
```

## How does it work?

What Roundsman does is this:

It will determine if you have the right version of Ruby installed. Your machine
might already have an older version of Ruby installed, so if it needs to, it
will use [ruby-build](https://github.com/sstephenson/ruby-build) to install the
version of Ruby you need for your application.

Then, it will install check the version of chef-solo and install or upgrade as
needed.

It will then copy over the cookbooks from your local machine to your deployment
machine. This means that you don't need to commit every change while your still
working on it.

It will create your node.json file based upon your Capistrano configuration and
run the recipes needed.

This is all done in Capistrano hooks, using Capistrano methods like `run`, so
you can determine when and how your recipes are run.

## Tips

### Colors

Capistrano and Chef both give a lot of output. Check out
[capistrano_colors](https://github.com/stjernstrom/capistrano_colors)
to colorize your output for better readability.

### Vagrant

If you want to test out your configuration locally, you should take a look at
[Vagrant](http://vagrantup.com). It makes managing a VirtualBox a breeze. You
can even create a stage just for Vagrant with the Capistrano multistage
extension.

### Contributing

If you want to help out, please! Create an issue or do a pull request and I
will take a look at it.

To get this project up and running:

``` bash
bundle install
rake
```
