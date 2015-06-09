require 'rptman'

namespace :rptman do
  namespace :vs_projects do
    desc 'Generate MS VS projects for each report dir'
    task :generate do
      SSRS::BIDS.generate
    end

    desc 'Clean generated projects'
    task :clean do
      rm_rf SSRS::Config.projects_dir
      FileUtils.rm_rf(Dir["#{SSRS::Config.reports_dir}/**/*.rdl.data"])
    end
  end

  namespace :ssrs do
    desc 'Upload reports to SSRS server'
    task :upload do
      SSRS::Uploader.upload
    end
  end
end
