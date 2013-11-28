module SSRS
  # Generator for "SQL Server Business Intelligence Development Studio" projects
  class Shell
    class << self
      attr_writer :generate_projects

      def generate_projects?
        @generate_projects ||= false
      end

      attr_writer :upload_reports

      def upload_reports?
        @upload_reports ||= false
      end
    end

    def self.run
      parse_args
      banner
      SSRS::BIDS.generate if generate_projects?
      SSRS::Uploader.upload if upload_reports?
    end

    private

    def self.banner
      SSRS.info("Rptman:")
      SSRS.info("\tEnvironment: #{SSRS::Config.environment}")
      SSRS.info("\tDataSource Count: #{SSRS::Config.datasources.size}")
      SSRS.info("\tReport Count: #{SSRS::Config.reports.size}")
      SSRS.info("\tReport Dir Count: #{SSRS::Config.upload_dirs.size}")
      SSRS.info("\tUpload Prefix: #{SSRS::Config.upload_prefix}")
      SSRS.info("\tReport Target: #{SSRS::Config.report_target}")
      SSRS.info("")
      if !generate_projects? && !upload_reports?
        SSRS.info("Run with -h for help")
      end
    end

    def self.parse_args
      SSRS::Config.environment = "development"

      Java.iris.ssrs.SSRS.setupLogger(false)
      optparse = OptionParser.new do |opts|
        opts.on('-v', '--verbose', 'Output more information') do
          Java.iris.ssrs.SSRS.setupLogger(true)
        end

        opts.on('-e', '--environment environment', 'Database environment to use') do |environment|
          SSRS::Config.environment = environment
        end

        opts.on('-u', '--upload', 'Upload the reports') do
          SSRS::Shell.upload_reports = true
        end

        opts.on('-p', '--generate-projects', 'Generate the Buisness Intelligence Studio projects') do
          SSRS::Shell.generate_projects = true
        end

        # This displays the help screen, all programs are
        # assumed to have this option.
        opts.on('-h', '--help', 'Display this screen') do
          puts opts
          exit
        end
      end

      # Parse the command-line. Remember there are two forms
      # of the parse method. The 'parse' method simply parses
      # ARGV, while the 'parse!' method parses ARGV and removes
      # any options found there, as well as any parameters for
      # the options. What's left is the list of files to resize.
      optparse.parse!
    end
  end
end
