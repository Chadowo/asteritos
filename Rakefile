
task :default => :run

desc 'Run the game'
task :run do
  sh 'bundle exec ruby src/main.rb'
end

desc 'Profile the game'
task :profile do
  sh 'bundle exec ruby-prof src/main.rb'
end
