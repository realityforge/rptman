Gem::Specification.new do |spec|
  spec.name           = 'rptman'
  spec.version        = `git describe`.strip.split('-').first
  spec.authors        = ['Peter Donald']
  spec.email          = ["peter@realityforge.org"]

  spec.homepage       = "http://github.com/stocksoftware/rptman"
  spec.summary        = "Tool for managing SSRS reports"
  spec.description    = <<-TEXT
Tool for managing SSRS reports
  TEXT
  spec.files          = Dir['{lib}/**/*', '*.gemspec'] +
                        ['lib/ssrs/ssrs-api.jar','LICENSE', 'README.rdoc', 'CHANGELOG']
  spec.require_paths  = ['lib']
  spec.platform       = RUBY_PLATFORM[/java/]
  spec.bindir         = 'bin'
  spec.executable     = 'rptman'

  spec.has_rdoc         = false
end
