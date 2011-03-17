require "rubygems"
require "rake"
require "rake/rdoctask"
require "rake/testtask"

# Gem
def gemspec
  @gemspec ||= begin
    file = File.expand_path('../fmeta.gemspec', __FILE__)
    eval(File.read(file), binding, file)
  end
end

begin
  require 'rake/gempackagetask'

  Rake::GemPackageTask.new(gemspec) do |pkg|
    pkg.gem_spec = gemspec
  end
rescue LoadError
  task(:gem) { $stderr.puts 'failed to load rake/gempackagetask' }
end

desc 'install newsroom'
task :install => :package do
  sh %{gem install pkg/#{gemspec.full_name}}
end

desc 'validate gemspec'
task :gemspec do
  gemspec.validate
end

# Tests
task :default => [:test]

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList["test/**/*_test.rb"]
  t.verbose = true
end

task :rdoc do
  sh <<-EOS.strip
rdoc -T fmeta#{" --op " + ENV["OUTPUT_DIRECTORY"] if ENV["OUTPUT_DIRECTORY"]} --line-numbers --main README --title "Fmeta Documentation" --exclude lib/fmeta.rb lib/fmeta README
  EOS
end