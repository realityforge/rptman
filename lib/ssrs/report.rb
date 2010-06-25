module SSRS
  class Report
    attr_reader :name
    attr_reader :filename

    def initialize(name, filename)
      @name, @filename = name, filename
    end

    def generate_upload_version
      require 'tempfile'
      file = Tempfile.new("ssrs_report")
      xformed_document.write file
      xformed_filename = file.path
      file.close
      xformed_filename
    end

    protected

    def xformed_document
      document = self.document
      REXML::XPath.each(document.root, "//Report/DataSources/DataSource/DataSourceReference") do |element|
        text_node = element.get_text
        text_node.value = "#{SSRS::Config.upload_prefix}/#{DataSource::BASE_PATH}/#{text_node.value}"
      end
      document
    end

    def document
      require 'rexml/document'
      REXML::Document.new(File.read(self.filename))
    end
  end
end
