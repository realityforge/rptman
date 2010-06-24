namespace :rptman do
  namespace :vs_projects do
    desc "Generate MS VS projects for each report dir"
    task :generate => [:datasources] do
      SSRS::BIDS.generate
    end

    desc "Clean generated projects"
    task :clean do
      rm_rf SSRS.projects_dir
    end
  end

  namespace :ssrs do
    desc "Upload reports to SSRS server"
    task :upload do
      SSRS::Uploader.new.upload
    end
  end
end

