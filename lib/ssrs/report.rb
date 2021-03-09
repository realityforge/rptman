# Need to explicitly set the encoding as we know all
# the reports are in UTF-8. This is global and not
# goodness.
if RUBY_VERSION =~ /1.9/
  Encoding.default_external = Encoding::UTF_8
  Encoding.default_internal = Encoding::UTF_8
end
module SSRS
  class Report
    attr_reader :name
    attr_reader :filename

    def initialize(name, filename)
      @name, @filename = name, filename
    end

    def generate_upload_version
      filename = "#{SSRS::Config.temp_directory}/#{name}.rdl"
      FileUtils.mkdir_p File.dirname(filename)

      content = IO.read(self.filename).
        gsub(/<DataSourceReference>(.*)<\/DataSourceReference>/,
             "<DataSourceReference>#{SSRS::Config.upload_prefix}/#{DataSource::BASE_PATH}/\\1</DataSourceReference>")
      IO.write(filename, content)
      filename
    end
  end
end
