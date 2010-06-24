module SSRS
  AUTO_UPLOAD_PATH='/Auto'
  PREFIX_KEY='prefix'
  WSDL_KEY='wsdl_path'

  @@reports_dir = BASE_APP_DIR + '/reports'

  def self.reports_dir
    @@reports_dir
  end

  def self.reports_dir=(reports_dir)
    @@reports_dir = reports_dir
  end

  def self.projects_dir
    "#{self.reports_dir}/projects"
  end

  @@datasources = nil

  def self.datasources
    @@datasources
  end

  def self.datasources=(datasources)
    @@datasources = datasources
  end

  @@reports = nil

  def self.reports
    @@reports
  end

  def self.reports=(reports)
    @@reports = reports
  end

  def self.report_dirs
    self.reports.collect {|report| File.dirname(report.filename)}.sort.uniq
  end

  def self.upload_path(filename)
    filename.gsub(Regexp.escape( self.reports_dir ), '')
  end

  def self.config_for_env( database_key, env )
    filename = File.join(File.dirname(__FILE__), '..', 'config', 'database.yml')
    config = ::YAML::load(ERB.new(IO.read(filename)).result)
    c = config["#{database_key}_#{env}"]
    raise "Missing configuration #{database_key}_#{env} in #{filename}" unless c
    c
  end

  def self.ssrs_config
    config = SSRS.config_for_env("ssrs", DB_ENV)
    raise "Missing prefix for ssrs_development database config" unless config[PREFIX_KEY] || DB_ENV == 'production'
    raise "Missing wsdl location for ssrs_development database config" unless config[WSDL_KEY]
    config[PREFIX_KEY] ||= ''
    config
  end

  def self.upload_prefix
    "#{AUTO_UPLOAD_PATH}#{ssrs_config[PREFIX_KEY]}"
  end

  def self.info(message)
    Java::IrisSSRS::SSRS::LOG.info(message)
  end
end