$:.unshift File.join(File.dirname(__FILE__), 'lib')

require 'yaml'

require 'rake_terraform'
require 'rake_docker'

require 'configuration'
require 's3_version_file'
require 'terraform_output'

RakeTerraform.define_installation_tasks(
    path: File.join(Dir.pwd, 'vendor', 'terraform'),
    version: '0.10.3')

configuration = Configuration.new
version = S3VersionFile.new(
    configuration.region,
    configuration.components_bucket_name,
    configuration.image_version_key,
    'build/version')

task :default => [
    :'image_repository:plan',
    :'secrets_bucket:plan',
    :'service:plan'
]

namespace :version do
  task :bump do
    version.bump(:revision)
  end
end

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
      TerraformOutput.for(
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
        TerraformOutput.for(
            name: 'registry_id',
            source_directory: 'infra/image_repository',
            work_directory: 'build',
            backend_config:
                configuration
                    .for_scope(role: 'image-repository')
                    .backend_config)
      end
    end

    t.tags = lambda do
      [version.refresh.to_s, 'latest']
    end
  end

  task :publish => [
      'version:bump',
      'image:clean',
      'image:build',
      'image:tag',
      'image:push'
  ]
end

namespace :secrets_bucket do
  RakeTerraform.define_command_tasks do |t|
    t.argument_names = [:deployment_identifier]

    t.configuration_name = 'secrets bucket'
    t.source_directory = 'infra/secrets_bucket'
    t.work_directory = 'build'

    t.backend_config = lambda do |args|
      configuration
          .for_args(args)
          .for_scope(role: 'secrets-bucket')
          .backend_config
    end

    t.vars = lambda do |args|
      configuration
          .for_args(args)
          .for_scope(role: 'secrets-bucket')
          .vars
    end
  end
end

namespace :service do
  RakeTerraform.define_command_tasks do |t|
    t.argument_names = [:deployment_identifier]

    t.configuration_name = 'service'
    t.source_directory = 'infra/service'
    t.work_directory = 'build'

    t.backend_config = lambda do |args|
      configuration
          .for_args(args)
          .for_scope(role: 'service')
          .backend_config
    end

    t.vars = lambda do |args|
      deployment_identifier =
          configuration
              .for_args(args)
              .for_scope(role: 'service')
              .deployment_identifier

      nxt_node_config = YAML.load_file(
          'config/secrets/nxt/%s.yaml' % deployment_identifier)

      configuration
          .for_args(args.to_hash.merge(
              'version_number' => version.refresh.to_s,
              'admin_password' => nxt_node_config['admin_password']))
          .for_scope(role: 'service')
          .vars
    end
  end
end
