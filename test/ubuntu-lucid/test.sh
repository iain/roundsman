set -e

bundle exec vagrant up
bundle exec cap deploy:cold
