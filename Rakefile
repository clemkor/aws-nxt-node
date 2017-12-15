$:.unshift File.join(File.dirname(__FILE__), 'lib')

require 'yaml'

require 'rake_terraform'
require 'rake_docker'
require 'confidante'

require 's3_version_file'
require 'terraform_output'

RakeTerraform.define_installation_tasks(
    path: File.join(Dir.pwd, 'vendor', 'terraform'),
    version: '0.10.8')

configuration = Confidante.configuration
version = S3VersionFile.new(
    configuration.region,
    configuration.components_bucket_name,
    configuration.image_version_key,
    'build/version')

task :default => [
    :'image_repository:plan',
    :'secrets_bucket:plan',
    :'blockchain_archive_lambda:plan',
    :'service:plan'
]

namespace :version do
  task :bump do
    version.bump(:revision)
  end
end

namespace :virtualenv do
  task :create do
    mkdir_p 'vendor'
    sh 'virtualenv vendor/virtualenv --always-copy'
  end

  task :destroy do
    rm_rf 'vendor/virtualenv'
  end

  task :ensure do
    unless File.exists?('vendor/virtualenv')
      Rake::Task['virtualenv:create'].invoke
    end
  end
end

namespace :dependencies do
  namespace :install do
    task :blockchain_archive_lambda => ['virtualenv:ensure'] do
      puts 'Installing dependencies for blockchain_archive lambda'

      sh_in_virtualenv(
          'pip', 'install -r ' +
              'infra/blockchain_archive_lambda/' +
              'lambda_definitions/blockchain_archive/requirements.txt')
    end

    task :all => ['dependencies:install:blockchain_archive_lambda']
  end
end

namespace :test do
  namespace :unit do
    task :blockchain_archive_lambda => [
        'dependencies:install:blockchain_archive_lambda'
    ] do
      puts 'Running unit tests for blockchain_archive lambda'

      sh_in_virtualenv(
          'python', '-m unittest discover -s ' +
              'infra/blockchain_archive_lambda/' +
              'lambda_definitions/blockchain_archive')
    end

    task :all => ['test:unit:blockchain_archive_lambda']
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
          .for_overrides(args)
          .for_scope(role: 'secrets-bucket')
          .backend_config
    end

    t.vars = lambda do |args|
      configuration
          .for_overrides(args)
          .for_scope(role: 'secrets-bucket')
          .vars
    end
  end
end

namespace :blockchain_archive_lambda do
  task :prepare => [
      'terraform:ensure',
      'dependencies:install:blockchain_archive_lambda'
  ] do
    rm_rf('build/lambda_definitions/blockchain_archive')
    mkdir_p('build/lambda_definitions/blockchain_archive')
    cp_r(
        'infra/blockchain_archive_lambda/lambda_definitions/blockchain_archive/.',
        'build/lambda_definitions/blockchain_archive')
    cp_r(
        'vendor/virtualenv/lib/python3.6/site-packages/.',
        'build/lambda_definitions/blockchain_archive')
  end

  RakeTerraform.define_command_tasks do |t|
    t.argument_names = [:deployment_identifier]
    t.ensure_task = 'blockchain_archive_lambda:prepare'

    t.configuration_name = 'blockchain archive lambda'
    t.source_directory = 'infra/blockchain_archive_lambda'
    t.work_directory = 'build'

    t.backend_config = lambda do |args|
      configuration
          .for_overrides(args)
          .for_scope(role: 'blockchain-archive-lambda')
          .backend_config
    end

    t.vars = lambda do |args|
      configuration
          .for_overrides(args)
          .for_scope(role: 'blockchain-archive-lambda')
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
          .for_overrides(args)
          .for_scope(role: 'service')
          .backend_config
    end

    t.vars = lambda do |args|
      deployment_identifier =
          configuration
              .for_overrides(args)
              .for_scope(role: 'service')
              .deployment_identifier

      nxt_node_config = YAML.load_file(
          'config/secrets/nxt/%s.yaml' % deployment_identifier)

      configuration
          .for_overrides(args.to_hash.merge(
              'version_number' => version.refresh.to_s,
              'admin_password' => nxt_node_config['admin_password']))
          .for_scope(role: 'service')
          .vars
    end
  end
end

def sh_in_virtualenv command, argument_string
  sh "#{File.expand_path('vendor/virtualenv/bin')}/#{command} " +
         "#{argument_string}"
end
