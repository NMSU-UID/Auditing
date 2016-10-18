# config valid only for current version of Capistrano
lock '3.6.1'

load 'config/deploy/notify/cap_mailer.rb'
yaml_config = File.read("config/deploy.yml")
deploy_config = YAML.load(yaml_config)

set :application, 'site_locator'
set :human_readable_application_name, 'Site Locator'
# You can set this but have to retrieve it yourself to use it; capistrano won't automatically grab it for you.
# http://stackoverflow.com/questions/20455922/capistrano-3-discards-user-variable-when-executing-remote-ssh-command
set :user, deploy_config['user']
set :shared_dir, 'shared'
set :repo_url, "#{deploy_config['repo']}:#{fetch(:user)}/#{fetch(:application)}.git"
set :repo_tree, 'site_locator'
set :tmp_dir, "/home/#{fetch(:user)}/tmp"

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp
#set :branch, 'dev'
set :branch, $1 if `git branch` =~ /\* (\S+)\s/m

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, "/opt/rails/#{fetch(:application)}"

# Default value for :scm is :git
set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
set :pty, true

# Default value for :linked_files is []
# set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')

# Default value for linked_dirs is []
# set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')
# For 3.6.1
set :linked_dirs, %w{log}

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for keep_releases is 5
set :keep_releases, 50

desc <<-TMDESC
Send test email from Capistrano.

Sample usage:
  $ cap staging test_email --trace
TMDESC
task :test_email do
  puts "  * Sending test notification email"
  CapMailer.test_email.deliver_now
  #end
end



namespace :deploy do
  task :update_git_repo do
    puts "  * Pushing code to git repo."
    run_locally do
      execute "git push #{fetch(:user)} #{fetch(:branch)}"
    end
    puts "  * Pushed #{fetch(:user)}'s code to #{fetch(:branch)} branch."
  end

  task :copy_live_config_files do
    on roles(:app) do
      database_config = 'database.yml'
      email_config = 'email.yml'
      secrets_config = 'secrets.yml'
      execute "cp #{shared_path}/config/#{database_config} #{release_path}/config/#{database_config} && chmod 0600 #{release_path}/config/#{database_config}"
      execute "cp #{shared_path}/config/#{email_config} #{release_path}/config/#{email_config} && chmod 0600 #{release_path}/config/#{email_config}"
      execute "cp #{shared_path}/config/#{secrets_config} #{release_path}/config/#{secrets_config} && chmod 0600 #{release_path}/config/#{secrets_config}"
    end
  end

  desc "Restart Passenger app"
  task :restart do
    on roles(:app) do
#      execute "mkdir #{ File.join(current_path, 'tmp') }"
      execute "touch #{ File.join(current_path, 'tmp', 'restart.txt') }"
    end
  end

  desc "Email recipients of deployment"
  task :notify do
    on roles(:app) do
      unless ENV['no_email']
        puts "  * Sending notification email"
        CapMailer.deploy_notification(self).deliver_now
      end
    end
  end

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      # within release_path do
      #   execute :rake, 'cache:clear'
      # end
    end
  end

  before 'deploy:updating', 'deploy:update_git_repo'
  after 'deploy:updating', 'deploy:copy_live_config_files'
  after 'deploy:publishing', 'deploy:restart'
  after :deploy, 'deploy:notify'

end
