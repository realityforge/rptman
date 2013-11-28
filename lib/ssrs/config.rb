module SSRS
  class Config
    class Server
      attr_reader :report_target
      attr_reader :upload_prefix
      attr_reader :domain
      attr_reader :username
      attr_reader :password

      def initialize(report_target, upload_prefix, domain, username, password)
        @report_target = report_target
        @upload_prefix = upload_prefix
        @domain = domain
        @username = username
        @password = password
      end
    end

    class << self
      attr_writer :environment

      def environment
        return 'development' unless @environment
        @environment
      end

      # config_file is where the yaml config file is located
      attr_writer :config_filename

      def config_filename
        raise "config_filename not specified" unless @config_filename
        @config_filename
      end

      # reports_dir is where the report hierarchy is located
      attr_writer :reports_dir

      def reports_dir
        raise "reports_dir not specified" unless @reports_dir
        @reports_dir
      end

      # projects_dir is where the VS projects are generated
      attr_writer :projects_dir

      def projects_dir
        return "#{self.reports_dir}/projects" unless @projects_dir
        return @projects_dir
      end

      def datasources
        datasources_map.each_pair do |k,datasource|
          if datasource.is_a? Proc
            datasources_map[k] = datasource.call
          end
        end
        datasources_map.values
      end

      def define_datasource(name, database_key)
        datasources_map[name] = Proc.new do
          data_source = SSRS::DataSource.new(name)
          configure_datasource(data_source, database_key)
          data_source
        end
      end

      def reports
        unless @reports
          @reports = Dir.glob("#{self.reports_dir}/**/*.rdl").collect do |filename|
            SSRS::Report.new(upload_path(filename), filename)
          end
        end
        return @reports
      end

      # Return list of dirs uploaded
      def upload_dirs
        self.reports.collect {|report| File.dirname(report.name)}.sort.uniq
      end

      def domain
        current_ssrs_config.domain
      end

      def username
        current_ssrs_config.username
      end

      def password
        current_ssrs_config.password
      end

      def upload_prefix
        current_ssrs_config.upload_prefix
      end

      def wsdl_path
        "#{report_target}/ReportService2005.asmx"
      end

      def report_target
        current_ssrs_config.report_target
      end

      def server_config(env_key)
        load_ssrs_config(env_key)
      end

      private
      
      def upload_path(filename)
        symbolic_path = filename.gsub(Regexp.new(Regexp.escape(reports_dir)), '')
        return "#{File.dirname(symbolic_path)}/#{File.basename(symbolic_path,'.rdl')}"
      end

      def current_ssrs_config
        @server ||= load_ssrs_config(environment)
      end

      def load_ssrs_config(env_key)
        config_key = "ssrs_#{env_key}"
        config = config_for_key(config_key)
        report_target = expect_config_element(config_key, config, 'report_target').to_s
        upload_prefix = expect_config_element(config_key, config, 'prefix').to_s
        SSRS::Config::Server.new(report_target, upload_prefix, config['domain'], config['username'], config['password'])
      end

      def configure_datasource(data_source, database_key)
        config_key = database_key.nil? ? environment : "#{database_key}_#{environment}"
        config = config_for_key(config_key)

        data_source.host = expect_config_element(config_key, config, 'host')
        data_source.database = expect_config_element(config_key, config, 'database')
        data_source.instance = config['instance']
        data_source.username = config['username']
        data_source.password = config['password']
      end

      def expect_config_element(config_key, config, element_key)
        raise "Missing #{element_key} for #{config_key} database config" unless config[element_key]
        config[element_key]
      end

      def config_for_key(config_key)
        c = config_data[config_key]
        raise "Missing configuration #{config_key} in #{self.config_filename}" unless c
        c
      end

      def config_data
        unless @config_data
          raise "Unable to locate config file #{self.config_filename}" unless File.exist?(self.config_filename)
          @config_data = ::YAML::load(ERB.new(IO.read(self.config_filename)).result)
        end
        @config_data
      end

      def datasources_map
        @datasources ||= {}
      end
    end
  end
end
