module SSRS
  class Uploader
    def self.upload
      ssrs_soap_port = create_port
      self.upload_datasources(ssrs_soap_port)
      self.upload_reports(ssrs_soap_port)
    end

    def self.delete
      ssrs_soap_port = create_port
      self.delete_datasources(ssrs_soap_port)
      self.delete_reports(ssrs_soap_port)
    end

    private

    def self.create_port
      # If domain has been specified then assume NTLM
      if SSRS::Config.username
        Java.org.realityforge.sqlserver.ssrs.NTLMAuthenticator.install(SSRS::Config.domain,
                                                                       SSRS::Config.username,
                                                                       SSRS::Config.password)
      end
      Java.org.realityforge.sqlserver.ssrs.SSRS.new(Java.java.net.URL.new(SSRS::Config.wsdl_path), SSRS::Config.upload_prefix)
    end

    def self.delete_datasources(ssrs_soap_port)
      SSRS::Config.datasources.each do |ds|
        ssrs_soap_port.delete(ds.symbolic_name)
      end
    end

    def self.upload_datasources(ssrs_soap_port)
      ssrs_soap_port.mkdir(SSRS::DataSource::BASE_PATH)
      SSRS::Config.datasources.each do |ds|
        ssrs_soap_port.delete(ds.symbolic_name)
        ssrs_soap_port.createSQLDataSource(ds.symbolic_name, ds.connection_string)
      end
    end

    def self.delete_reports(ssrs_soap_port)
      top_level_upload_dirs =
        SSRS::Config.upload_dirs.collect { |d| d.split('/').delete_if { |p| p == '' }.first }.sort.uniq
      top_level_upload_dirs.each do |upload_dir|
        ssrs_soap_port.delete(upload_dir)
      end
    end

    def self.upload_reports(ssrs_soap_port)
      top_level_upload_dirs =
        SSRS::Config.upload_dirs.collect { |d| d.split('/').delete_if { |p| p == '' }.first }.sort.uniq
      top_level_upload_dirs.each do |upload_dir|
        ssrs_soap_port.delete(upload_dir)
      end
      SSRS::Config.reports.each do |report|
        ssrs_soap_port.mkdir(File.dirname(report.name))
        ssrs_soap_port.createReport(report.name, report.generate_upload_version)
      end
    end
  end
end
