set :application, "my-awesome-blog"

set :repository, "."
set :scm,        :none # not recommended in production
set :deploy_via, :copy

server "192.168.33.10", :web, :app, :db, :primary => true

set :user,     "vagrant"
set :password, "vagrant" # not recommended in production

set :deploy_to, "/home/#{user}/#{application}"

set :use_sudo, false
default_run_options[:pty] = true

before "deploy:cold" do
  deploy.setup
  roundsman.run_list "recipe[main::cold]"
end
