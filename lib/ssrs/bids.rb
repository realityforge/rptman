module SSRS
  # Generator for "SQL Server Business Intelligence Development Studio" projects
  class BIDS
    def self.generate
      self.generate_data_sources
      self.generate_project_files
    end

    private

    def self.generate_project_files
      SSRS::Config.upload_dirs.each do |upload_dir|
        SSRS.info("Generating Project for #{upload_dir}")
        actual_dir = File.expand_path("#{SSRS::Config.reports_dir}/#{upload_dir}")
        filename = File.expand_path("#{SSRS::Config.projects_dir}/#{upload_dir[1,upload_dir.size].gsub('/', '_')}.rptproj")
        project = SSRS::ReportProject.new(upload_dir, filename, actual_dir)
        File.open(filename, 'w') do |f|
          project.write(f)
        end
      end
    end

    def self.generate_data_sources
      FileUtils.rm_rf SSRS::Config.projects_dir
      FileUtils.mkdir_p SSRS::Config.projects_dir
      SSRS::Config.datasources.each do |ds|
        filename = "#{SSRS::Config.projects_dir}/#{ds.name}.rds"
        SSRS.info("Generating DataSource #{ds.name}")
        File.open(filename, 'w') do |f|
          ds.write(f)
        end
      end
    end
  end
end
