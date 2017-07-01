$:.unshift File.join(File.dirname(__FILE__), 'lib')

require 'securerandom'
require 'git'
require 'semantic'
require 'rake_terraform'

require 'configuration'

RakeTerraform.define_installation_tasks(
    path: File.join(Dir.pwd, 'vendor', 'terraform'),
    version: '0.9.8')

configuration = Configuration.new

task :default => [
    :'image_repository:plan'
]

namespace :image_repository do
  RakeTerraform.define_command_tasks do |t|
    t.configuration_name = 'image repository'
    t.source_directory = 'infra/image_repository'
    t.work_directory = 'build'

    t.backend_config = lambda do
      configuration
          .for_scope(role: 'image-repository')
          .backend_config
    end

    t.vars = lambda do
      configuration
          .for_scope(role: 'image-repository')
          .vars
    end
  end
end
