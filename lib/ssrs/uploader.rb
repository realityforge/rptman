module SSRS
  class Uploader
    def initialize
      wsdl_url = Java::JavaNet.URL.new(SSRS.ssrs_config[SSRS::WSDL_KEY])
      prefix = SSRS.ssrs_config[SSRS::PREFIX_KEY] 
      @ssrs = Java::IrisSSRS::SSRS.new(wsdl_url, prefix)
    end

    def upload
      self.upload_datasources
      self.upload_reports
    end

    private

    def upload_datasources
      @ssrs.mkdir( SSRS::DataSource::BASE_PATH )
      SSRS.datasources.each do |ds|
        SSRS.info("Creating DataSource #{ds.name}")
        @ssrs.delete( ds.symbolic_name )
        @ssrs.createSQLDataSource( ds.symbolic_name, ds.connection_string )
      end
    end

    def upload_reports
      SSRS.report_dirs.each do |report_dir|
        upload_dir = SSRS.upload_path(report_dir).split('/').delete_if{|path| path == ""}.first
        @ssrs.delete( upload_dir )
      end
      SSRS.reports.each do |report|
        upload_path = SSRS.upload_path(report.filename)
        SSRS.info("Uploading #{upload_path} from #{report.filename}")
        @ssrs.mkdir( File.dirname(upload_path) )
        @ssrs.createReport( "#{File.dirname(upload_path)}/#{File.basename(upload_path,'.rdl')}",
                            Java::JavaIo.File.new(report.generate_upload_version) )
      end
    end
  end
end
