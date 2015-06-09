Gem::Specification.new do |spec|
  spec.name           = 'rptman'
  spec.version        = '0.5.0'
  spec.authors        = ['Peter Donald']
  spec.email          = ["peter@realityforge.org"]

  spec.homepage       = "http://github.com/stocksoftware/rptman"
  spec.summary        = "Tool for managing SSRS reports"
  spec.description    = <<-TEXT
This tool includes code and a suite of rake tasks for uploading SSRS
reports to a server. The tool can also generate project files for
the "SQL Server Business Intelligence Development Studio". 
  TEXT
  spec.files          = Dir['{lib}/**/*', '*.gemspec'] +
                        ['lib/ssrs/ssrs-api.jar','LICENSE', 'README.rdoc', 'CHANGELOG']
  spec.require_paths  = ['lib']
  spec.platform       = RUBY_PLATFORM[/java/]

  spec.has_rdoc         = false
end
