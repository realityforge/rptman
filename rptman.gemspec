Gem::Specification.new do |spec|
  spec.name           = 'rptman'
  spec.version        = `git describe`.strip.split('-').first
  spec.authors        = ['Peter Donald']
  spec.email          = ["peter@realityforge.org"]
  spec.homepage       = "http://github.com/realityforge/buildr-bnd"
  spec.summary        = "Buildr extension for packaging OSGi bundles using bnd"
  spec.description    = <<-TEXT
This is a buildr extension for packaging OSGi bundles using Bnd. 
  TEXT
  spec.files          = Dir['{lib,spec}/**/*', '*.gemspec'] +
                        ['LICENSE', 'README.rdoc', 'CHANGELOG', 'Rakefile']

  spec.homepage       = "http://github.com/stocksoftware/rptman"
  spec.summary        = "Tool for managing SSRS reports"
  spec.description    = <<-TEXT
Tool for managing SSRS reports
  TEXT
  spec.files          = Dir['{lib}/**/*', '*.gemspec'] + ['LICENSE', 'README.rdoc', 'CHANGELOG']
  spec.require_paths  = ['lib']

  spec.has_rdoc         = false
end
