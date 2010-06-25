module SSRS
  class Uploader
    def self.upload
      ssrs_soap_port = Java::IrisSSRS::SSRS.new(Java::JavaNet.URL.new(SSRS::Config.wsdl_path),
                                                SSRS::Config.upload_prefix)
      self.upload_datasources(ssrs_soap_port)
      self.upload_reports(ssrs_soap_port)
    end

    private

    def self.upload_datasources(ssrs_soap_port)
      ssrs_soap_port.mkdir(SSRS::DataSource::BASE_PATH)
      SSRS::Config.datasources.each do |ds|
        SSRS.info("Creating DataSource #{ds.name}")
        ssrs_soap_port.delete(ds.symbolic_name)
        ssrs_soap_port.createSQLDataSource(ds.symbolic_name, ds.connection_string)
      end
    end

    def self.upload_reports(ssrs_soap_port)
      top_level_upload_dirs =
        SSRS::Config.upload_dirs.collect { |d| d.split('/').delete_if { |p| p == "" }.first }.sort.uniq
      top_level_upload_dirs.each do |upload_dir|
        ssrs_soap_port.delete(upload_dir)
      end
      SSRS::Config.reports.each do |report|
        SSRS.info("Uploading #{report.name} from #{report.filename}")
        ssrs_soap_port.mkdir(File.dirname(report.name))
        ssrs_soap_port.createReport(report.name, Java::JavaIo.File.new(report.generate_upload_version))
      end
    end
  end
end
