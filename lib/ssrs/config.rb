module SSRS
  class Config
    class << self
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
        datasources_map.values
      end

      def define_datasource(name, database_key)
        data_source = SSRS::DataSource.new(name)
        configure_datasource(data_source, database_key)
        datasources_map[name] = data_source
      end

      def reports
        unless @reports
          @reports = Dir.glob("#{self.reports_dir}/**/*.rdl").collect do |filename|
            SSRS::Report.new(upload_path(filename), filename)
          end
        end
        return @reports
      end

      def report_dirs
        self.reports.collect {|report| File.dirname(report.filename)}.sort.uniq
      end

      def upload_prefix
        load_ssrs_config
        @upload_prefix
      end

      def wsdl_path
        load_ssrs_config
        @wsdl_path
      end

      private
      
      def upload_path(filename)
        symbolic_path = filename.gsub(Regexp.escape(reports_dir), '')
        return "#{File.dirname(symbolic_path)}/#{File.basename(symbolic_path,'.rdl')}"
      end

      def load_ssrs_config
        unless @upload_prefix
          config_key = "ssrs_#{DB_ENV}"
          config = config_for_key(config_key)
          @wsdl_path = expect_config_element(config_key, config, 'wsdl_path').to_s
          @upload_prefix = expect_config_element(config_key, config, 'prefix').to_s
        end
      end

      def configure_datasource(data_source, database_key)
        config_key = "#{database_key}_#{DB_ENV}"
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