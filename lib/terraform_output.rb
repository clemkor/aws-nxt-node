require 'ruby_terraform'

module TerraformOutput
  def self.for(opts)
    name = opts[:name]
    backend_config = opts[:backend_config]

    source_directory = opts[:source_directory]
    work_directory = opts[:work_directory]

    configuration_directory = File.join(work_directory, source_directory)

    RubyTerraform.clean(
        directory: configuration_directory)
    RubyTerraform.init(
        source: source_directory,
        path: configuration_directory,
        backend_config: backend_config)
    Dir.chdir(configuration_directory) do
      RubyTerraform.output(name: name)
    end
  end
end