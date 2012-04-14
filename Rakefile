#!/usr/bin/env rake
require "bundler/gem_tasks"


namespace :test do

  desc "Run integration test for Ubuntu 10.04 LTE"
  task :lucid do
    result = system "cd test/ubuntu-lucid && ./test.sh"
    exit 1 unless result
  end

  task :all => [ :lucid ]

end
task :test => "test:all"

task :default => :test
