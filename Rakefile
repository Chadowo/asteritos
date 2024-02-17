require 'gosu' # Version file will error out otherwise
require_relative 'src/version'

task default: :run

desc 'Run the game'
task :run do
  sh 'bundle exec ruby src/main.rb'
end

desc 'Profile the game'
task :profile do
  sh 'bundle exec ruby-prof src/main.rb'
end

desc 'Publish the game to itch.io (requires Butler)'
task :publish do
  sh "butler push . chadow/asteritos:source-code --userversion #{AsteritosWindow::VERSION}"
end
