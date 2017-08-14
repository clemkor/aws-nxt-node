$:.unshift File.join(File.dirname(__FILE__), 'lib')

require 'securerandom'
require 'git'
require 'semantic'
require 'rake_terraform'
require 'rake_docker'

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

namespace :image do
  RakeDocker.define_image_tasks do |t|
    t.image_name = 'aws-nxt'
    t.work_directory = 'build/images'

    t.copy_spec = [
        {from: 'src/nxt/Dockerfile', to: 'Dockerfile'},
        {from: 'src/nxt/nxt.sh', to: 'nxt.sh'},
        {from: 'src/nxt/nxt.properties.template',
         to: 'nxt.properties.template'},
        {from: 'src/nxt/nxt-default.env', to: 'nxt-default.env'}
    ]

    t.repository_name = 'eth-quest/aws-nxt'
    t.repository_url = lambda do
      configuration.terraform.output_for(
          name: 'repository_url',
          source_directory: 'infra/image_repository',
          work_directory: 'build',
          backend_config:
              configuration
                  .for_scope(role: 'image-repository')
                  .backend_config)
    end
    t.credentials = RakeDocker::Authentication::ECR.new do |c|
      c.region = configuration.region
      c.registry_id = lambda do
        configuration.terraform.output_for(
            name: 'registry_id',
            source_directory: 'infra/image_repository',
            work_directory: 'build',
            backend_config:
                configuration
                    .for_scope(role: 'image-repository')
                    .backend_config)
      end
    end

    t.tags = ['latest']
  end
end
