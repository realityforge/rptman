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

    @@defined_init_tasks = false

    def self.define_basic_tasks
      unless @@defined_init_tasks

        task "#{SSRS::Config.task_prefix}:setup" do
          a = Buildr.artifact('org.realityforge.sqlserver.ssrs:ssrs:jar:1.0')
          a.invoke
          Java.classpath << a.to_s
        end

        desc 'Generate MS VS projects for each report dir'
        task "#{SSRS::Config.task_prefix}:vs_projects:generate" => ["#{SSRS::Config.task_prefix}:setup"] do
          SSRS::BIDS.generate
        end

        desc 'Clean generated Visual Studio/BIDS projects'
        task "#{SSRS::Config.task_prefix}:vs_projects:clean" do
          projects_dir = File.expand_path(SSRS::Config.projects_dir, SSRS::Config.base_directory)
          rm_rf projects_dir
          FileUtils.rm_rf(Dir["#{projects_dir}/**/*.rdl.data"])
        end

        task '::clean' => "#{SSRS::Config.task_prefix}:vs_projects:clean"

        desc 'Upload reports to SSRS server'
        task "#{SSRS::Config.task_prefix}:ssrs:upload" => ["#{SSRS::Config.task_prefix}:setup"] do
          SSRS::Uploader.upload
        end

        desc 'Delete reports from the SSRS server'
        task "#{SSRS::Config.task_prefix}:ssrs:delete" => ["#{SSRS::Config.task_prefix}:setup"] do
          SSRS::Uploader.delete
        end

        @@defined_init_tasks = true
      end
    end
  end
end
