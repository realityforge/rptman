require File.expand_path("#{File.dirname(__FILE__)}/../rptman.rb")

namespace :rptman do
  namespace :vs_projects do
    desc "Generate MS VS projects for each report dir"
    task :generate do
      SSRS::BIDS.generate
    end

    desc "Clean generated projects"
    task :clean do
      rm_rf SSRS::Config.projects_dir
    end
  end

  namespace :ssrs do
    desc "Upload reports to SSRS server"
    task :upload do
      SSRS::Uploader.upload
    end
  end
end
