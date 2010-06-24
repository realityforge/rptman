module SSRS
  class ReportProject
    attr_accessor :dir

    def initialize(dir)
      @dir = dir
    end

    def write(file)
      file.write <<XML
<?xml version="1.0" encoding="utf-8"?>
<Project xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
  <State>$base64$PFNvdXJjZUNvbnRyb2xJbmZvIHhtbG5zOnhzZD0iaHR0cDovL3d3dy53My5vcmcvMjAwMS9YTUxTY2hlbWEiIHhtbG5zOnhzaT0iaHR0cDovL3d3dy53My5vcmcvMjAwMS9YTUxTY2hlbWEtaW5zdGFuY2UiIHhtbG5zOmRkbDI9Imh0dHA6Ly9zY2hlbWFzLm1pY3Jvc29mdC5jb20vYW5hbHlzaXNzZXJ2aWNlcy8yMDAzL2VuZ2luZS8yIiB4bWxuczpkZGwyXzI9Imh0dHA6Ly9zY2hlbWFzLm1pY3Jvc29mdC5jb20vYW5hbHlzaXNzZXJ2aWNlcy8yMDAzL2VuZ2luZS8yLzIiIHhtbG5zOmRkbDEwMF8xMDA9Imh0dHA6Ly9zY2hlbWFzLm1pY3Jvc29mdC5jb20vYW5hbHlzaXNzZXJ2aWNlcy8yMDA4L2VuZ2luZS8xMDAvMTAwIiB4bWxuczpkd2Q9Imh0dHA6Ly9zY2hlbWFzLm1pY3Jvc29mdC5jb20vRGF0YVdhcmVob3VzZS9EZXNpZ25lci8xLjAiPg0KICA8RW5hYmxlZD5mYWxzZTwvRW5hYmxlZD4NCiAgPFByb2plY3ROYW1lPjwvUHJvamVjdE5hbWU+DQogIDxBdXhQYXRoPjwvQXV4UGF0aD4NCiAgPExvY2FsUGF0aD48L0xvY2FsUGF0aD4NCiAgPFByb3ZpZGVyPjwvUHJvdmlkZXI+DQo8L1NvdXJjZUNvbnRyb2xJbmZvPg==</State>
  <DataSources>
XML
      SSRS.datasources.each do |ds|
        file.write <<XML
    <ProjectItem>
      <Name>#{ds.name}.rds</Name>
      <FullPath>#{ds.name}.rds</FullPath>
    </ProjectItem>
XML
      end
      file.write <<XML
  </DataSources>
  <Reports>
XML

      Dir["#{self.dir}/*.rdl"].each do |f|
        file.write <<XML
    <ProjectItem>
      <Name>#{File.basename(f)}</Name>
      <FullPath>..#{SSRS.upload_path(self.dir)}/#{File.basename(f)}</FullPath>
    </ProjectItem>
XML
      end

      debug_config = SSRS.ssrs_config
      debug_target = "http://#{debug_config["host"]}/#{debug_config["report_server"]}"
      debug_prefix = SSRS.upload_prefix
      file.write <<XML
  </Reports>
  <Configurations>
    <Configuration>
      <Name>Debug</Name>
      <Platform>Win32</Platform>
      <Options>
        <TargetServerURL>#{debug_target}</TargetServerURL>
        <TargetFolder>#{debug_prefix}#{SSRS.upload_path(self.dir)}</TargetFolder>
        <TargetDataSourceFolder>#{debug_prefix}/#{DataSource::BASE_PATH}</TargetDataSourceFolder>
      </Options>
    </Configuration>
    <Configuration>
      <Name>DebugLocal</Name>
      <Platform>Win32</Platform>
      <Options>
        <TargetServerURL>#{debug_target}</TargetServerURL>
        <TargetFolder>#{debug_prefix}/#{self.dir}</TargetFolder>
        <TargetDataSourceFolder>#{debug_prefix}/#{DataSource::BASE_PATH}</TargetDataSourceFolder>
      </Options>
    </Configuration>
  </Configurations>
</Project>
XML
    end
  end
end