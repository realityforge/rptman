#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

module SSRS #nodoc
  module Build #nodoc

    class << self
      def ssrs_tool(action, options = {})
        filename = generate_config_file

        args = []
        args << '--report-target' << SSRS::Config.report_target
        args << '--upload-prefix' << SSRS::Config.upload_prefix
        args << '--config-filename' << filename
        args << '--domain' << SSRS::Config.domain
        args << '--username' << SSRS::Config.username
        args << '--password' << SSRS::Config.password
        args << action.to_s

        Java::Commands.java 'org.realityforge.sqlserver.ssrs.Main', *(args + [{ :classpath => Buildr.artifacts(['org.realityforge.sqlserver.ssrs:ssrs:jar:all:1.2']), :properties => options[:properties], :java_args => options[:java_args] }])
      end

      private

      def generate_config_file
        config = { dataSources: [], reports: [] }

        SSRS::Config.datasources.each do |ds|
          config[:dataSources] << { name: ds.symbolic_name, connectionString: ds.connection_string }
        end
        SSRS::Config.reports.each do |report|
          config[:reports] << { name: report.name, filename: report.generate_upload_version }
        end

        filename = "#{SSRS::Config.temp_directory}/upload_config.json"
        FileUtils.mkdir_p File.dirname(filename)
        IO.write(filename, config.to_json)
        filename
      end
    end

    @@defined_init_tasks = false

    def self.define_basic_tasks
      unless @@defined_init_tasks

        desc 'Generate MS VS projects for each report dir'
        task "#{SSRS::Config.task_prefix}:vs_projects:generate" do
          SSRS::BIDS.generate
        end

        desc 'Clean generated Visual Studio/BIDS projects'
        task "#{SSRS::Config.task_prefix}:vs_projects:clean" do
          projects_dir = File.expand_path(SSRS::Config.projects_dir, SSRS::Config.base_directory)
          rm_rf projects_dir
          FileUtils.rm_rf(Dir["#{projects_dir}/**/*.rdl.data"])
        end

        task '::clean' => "#{SSRS::Config.task_prefix}:vs_projects:clean"

        desc 'Upload reports and datasources to SSRS server'
        task "#{SSRS::Config.task_prefix}:ssrs:upload" do
          SSRS::Build.ssrs_tool('upload')
        end

        desc 'Upload just reports to SSRS server'
        task "#{SSRS::Config.task_prefix}:ssrs:upload_reports" do
          SSRS::Build.ssrs_tool('upload_reports')
        end

        desc 'Delete reports from the SSRS server'
        task "#{SSRS::Config.task_prefix}:ssrs:delete" do
          SSRS::Build.ssrs_tool('delete')
        end

        @@defined_init_tasks = true
      end
    end
  end
end
