require 'erb'
require 'yaml'
require 'optparse'

require File.expand_path("#{File.dirname(__FILE__)}/ssrs/ssrs-api.jar")
require File.expand_path("#{File.dirname(__FILE__)}/ssrs/UUID.rb")
require File.expand_path("#{File.dirname(__FILE__)}/ssrs/core.rb")
require File.expand_path("#{File.dirname(__FILE__)}/ssrs/config.rb")
require File.expand_path("#{File.dirname(__FILE__)}/ssrs/datasource.rb")
require File.expand_path("#{File.dirname(__FILE__)}/ssrs/report_project.rb")
require File.expand_path("#{File.dirname(__FILE__)}/ssrs/report.rb")
require File.expand_path("#{File.dirname(__FILE__)}/ssrs/uploader.rb")
require File.expand_path("#{File.dirname(__FILE__)}/ssrs/bids.rb")
require File.expand_path("#{File.dirname(__FILE__)}/ssrs/shell.rb")
