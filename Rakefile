require 'rake'
require 'rake/gempackagetask'

gem_spec = Gem::Specification.load(File.expand_path('rptman.gemspec', File.dirname(__FILE__)))

SSRS_API_JAR='lib/ssrs/ssrs-api.jar'

file SSRS_API_JAR => (Dir['ssrs-api/src/java/**/*'] + ['ssrs-api/src/resources/ReportService2005.wsdl']) do
  system 'ant -f ssrs-api/build.xml rebuild'
end

gem_task = Rake::GemPackageTask.new(gem_spec).define
gem_task.enhance [SSRS_API_JAR]
