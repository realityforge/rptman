SSRS_API_JAR='lib/ssrs/ssrs-api.jar'

file SSRS_API_JAR => (Dir['ssrs-api/src/java/**/*'] + ['ssrs-api/src/resources/ReportService2005.wsdl']) do
  system 'ant -f ssrs-api/build.xml rebuild'
end

task 'build' => [SSRS_API_JAR] do
  system 'gem build rptman.gemspec'
end
