module SSRS
  class ReportProject
    attr_reader :name
    attr_accessor :project_filename
    attr_accessor :dir

    def initialize(name, project_filename, dir)
      @name, @project_filename, @dir = name, project_filename, dir
    end

    def write(file)
      file.write <<XML
<?xml version="1.0" encoding="utf-8"?>
<Project xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
  <State>$base64$PFNvdXJjZUNvbnRyb2xJbmZvIHhtbG5zOnhzZD0iaHR0cDovL3d3dy53My5vcmcvMjAwMS9YTUxTY2hlbWEiIHhtbG5zOnhzaT0iaHR0cDovL3d3dy53My5vcmcvMjAwMS9YTUxTY2hlbWEtaW5zdGFuY2UiIHhtbG5zOmRkbDI9Imh0dHA6Ly9zY2hlbWFzLm1pY3Jvc29mdC5jb20vYW5hbHlzaXNzZXJ2aWNlcy8yMDAzL2VuZ2luZS8yIiB4bWxuczpkZGwyXzI9Imh0dHA6Ly9zY2hlbWFzLm1pY3Jvc29mdC5jb20vYW5hbHlzaXNzZXJ2aWNlcy8yMDAzL2VuZ2luZS8yLzIiIHhtbG5zOmRkbDEwMF8xMDA9Imh0dHA6Ly9zY2hlbWFzLm1pY3Jvc29mdC5jb20vYW5hbHlzaXNzZXJ2aWNlcy8yMDA4L2VuZ2luZS8xMDAvMTAwIiB4bWxuczpkd2Q9Imh0dHA6Ly9zY2hlbWFzLm1pY3Jvc29mdC5jb20vRGF0YVdhcmVob3VzZS9EZXNpZ25lci8xLjAiPg0KICA8RW5hYmxlZD5mYWxzZTwvRW5hYmxlZD4NCiAgPFByb2plY3ROYW1lPjwvUHJvamVjdE5hbWU+DQogIDxBdXhQYXRoPjwvQXV4UGF0aD4NCiAgPExvY2FsUGF0aD48L0xvY2FsUGF0aD4NCiAgPFByb3ZpZGVyPjwvUHJvdmlkZXI+DQo8L1NvdXJjZUNvbnRyb2xJbmZvPg==</State>
  <DataSources>
XML
      SSRS::Config.datasources.each do |ds|
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
      <FullPath>#{relativepath(File.expand_path(f), project_filename)}</FullPath>
    </ProjectItem>
XML
      end

      prefix = SSRS::Config.upload_prefix
      file.write <<XML
  </Reports>
  <Configurations>
    <Configuration>
      <Name>Debug</Name>
      <Platform>Win32</Platform>
      <Options>
        <TargetServerURL>#{SSRS::Config.report_target}</TargetServerURL>
        <TargetFolder>#{prefix}#{self.name}</TargetFolder>
        <TargetDataSourceFolder>#{prefix}/#{DataSource::BASE_PATH}</TargetDataSourceFolder>
      </Options>
    </Configuration>
    <Configuration>
      <Name>DebugLocal</Name>
      <Platform>Win32</Platform>
      <Options>
        <TargetServerURL>#{SSRS::Config.report_target}</TargetServerURL>
        <TargetFolder>#{prefix}/#{self.name}</TargetFolder>
        <TargetDataSourceFolder>#{prefix}/#{DataSource::BASE_PATH}</TargetDataSourceFolder>
      </Options>
    </Configuration>
  </Configurations>
</Project>
XML
    end

    private

    # Convert the given absolute path into a path
    # relative to the second given absolute path.
    def relativepath(abspath, relativeto)
      path = abspath.split(File::SEPARATOR)
      rel = relativeto.split(File::SEPARATOR)
      while (path.length > 0) && (path.first == rel.first)
        path.shift
        rel.shift
      end
      ('..' + File::SEPARATOR) * (rel.length - 1) + path.join(File::SEPARATOR)
    end
  end
end