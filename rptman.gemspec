# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'ssrs/version'

Gem::Specification.new do |s|
  s.name           = 'rptman'
  s.version        = SSRS::VERSION
  s.platform       = Gem::Platform::RUBY

  s.authors        = ['Peter Donald']
  s.email          = %q{peter@realityforge.org}
  s.license        = 'Apache-2.0'

  s.homepage       = 'http://github.com/stocksoftware/rptman'
  s.summary        = 'Tool for managing SSRS reports'
  s.description    = <<-TEXT
This tool includes code and a suite of rake tasks for uploading SSRS
reports to a server. The tool can also generate project files for
the "SQL Server Business Intelligence Development Studio".
  TEXT
  s.files              = `git ls-files`.split("\n")
  s.test_files         = `git ls-files -- {spec}/*`.split("\n")
  s.require_paths  = %w(lib)


  s.rdoc_options       = %w(--line-numbers --inline-source --title rptman)
end
