require "rubygems"
require "pathname"
require "rake"
require "rake/rdoctask"
require "rake/testtask"

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

# Gem
require "lib/fmeta/version"
require "rake/gempackagetask"

NAME = "fmeta"
SUMMARY = "Fmeta File Metadata"
GEM_VERSION = Fmeta::VERSION

spec = Gem::Specification.new do |s|
  s.name = NAME
  s.summary = s.description = SUMMARY
  s.author = "Scott Bauer"
  s.homepage = "http://bauerpauer.com"
  s.email = "bauer.mail@gmail.com"
  s.version = GEM_VERSION
  s.platform = Gem::Platform::RUBY
  s.require_path = 'lib'
  s.files = %w(Rakefile) + Dir.glob("lib/**/*")
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end

desc "Install Fmeta as a gem"
task :install => [:repackage] do
  sh %{gem install pkg/#{NAME}-#{GEM_VERSION}}
end