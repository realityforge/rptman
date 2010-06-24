module SSRS
  # Generator for "SQL Server Business Intelligence Development Studio" projects
  class BIDS
    def self.generate
      self.generate_data_sources
      self.generate_project_files
    end

    private
    
    def self.generate_project_files
      SSRS.report_dirs.each do |dir|
        project_name = SSRS.upload_path(dir).gsub('/', '_')
        filename = "#{SSRS.projects_dir}/#{project_name}.rptproj"
        SSRS.info("Generating Project #{project_name}")
        File.open(filename, 'w') do |f|
          SSRS::ReportProject.new(dir).write(f)
        end
      end
    end

    def self.generate_data_sources
      mkdir_p SSRS.projects_dir
      SSRS.datasources.each do |ds|
        filename = "#{SSRS.projects_dir}/#{ds.name}.rds"
        SSRS.info("Generating DataSource #{ds.name}")
        File.open(filename, 'w') do |f|
          ds.write(f)
        end
      end
    end
  end
end
