# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib/', __FILE__)
$:.unshift lib unless $:.include?(lib)

require "lib/fmeta/version"
require "rake/gempackagetask"

NAME = "fmeta"
SUMMARY = "Fmeta File Metadata"
GEM_VERSION = Fmeta::VERSION

Gem::Specification.new do |s|
  s.name = NAME
  s.summary = s.description = SUMMARY
  s.author = "Scott Bauer"
  s.homepage = "http://bauerpauer.com"
  s.email = "bauer.mail@gmail.com"
  s.version = GEM_VERSION
  s.platform = Gem::Platform::RUBY
  s.require_path = 'lib'
  # s.files = %w(Rakefile) + Dir.glob("lib/**/*")
  s.files = `git ls-files`.split("\n")
  
  # s.name = 'newsroom'
  # s.summary = s.description = 'Wieck Newsroom'
  # s.author = 'Wieck Media'
  # s.homepage = 'http://wiecklabs.com'
  # s.email = 'dev@wieck.com'
  # s.version = NEWSROOM_VERSION
  # s.platform = Gem::Platform::RUBY
end
