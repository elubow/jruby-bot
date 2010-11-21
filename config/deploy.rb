set :application, "jruby-bot"

role :app, "dev1.simplereach.com"

# SSH Options
ssh_options[:forward_agent] = true
ssh_options[:compression] = "none"

# Git Options
set :scm, :git
set :repository,  "git@github.com:elubow/jruby-bot.git"
set :branch, "master"
set :deploy_via, :remote_cache


# System
set :user, 'jruby-bot'
set :use_sudo, false
set :runner, user
set :admin_runner, user
set :deploy_to, '/home/jruby-bot/jruby-bot'


namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do; end

  task :after_symlink do
    update_sqlite_symlink
  end

  desc "Update the symlink for the SQLite DB"
  task :update_sqlite_symlink, :roles => [:app] do
    run "ln -nfs #{shared_path}/db/jruby_jira_rss.db #{release_path}/db/jruby_jira_rss.db"
  end
end
