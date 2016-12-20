require 'github_api'
require 'optparse'

require 'github/mirror/utility'

module Github
  module Mirror
    @arguments = nil
    @config = nil
    @config_default = {
      github: {
        auto_pagination: true
      }
    }
    @github = nil

    def self.config_file
      file = nil
      file = @arguments[:config] if @arguments && @arguments[:config]

      unless file
        local_file = "#{Dir.pwd}/settings.yml"
        file = local_file if File.exist?(local_file)
      end

      raise ArgumentError, 'Could not find config file!' unless file
      file
    end

    def self.config
      return @config if @config
      @config = @config_default
      data = YAML.load(File.read(config_file))
      @config.deep_merge!(Utility.hash_deep_symbolize(data))
      puts @config
      @config
    end

    def self.github
      return @github if @github
      opts = nil
      opts = config[:github] if config[:github]
      @github = Github.new(opts)
      @github
    end

    def self.parse_arguments(argv)
      @arguments = {}
      OptionParser.new(argv) do |opts|
        opts.banner = 'Usage: github-mirror [-c settings.yml]'

        opts.on('-c', '--config', 'Specify config file') do |v|
          @arguments[:config] = v
        end

        opts.on('list') do
          @arguments[:action] = 'list'
        end
      end.parse!
    end

    def self.main(argv)
      parse_arguments(argv)

      action = @arguments[:action] || 'list'

      return repo_list if action == 'list'

      raise ArgumentError, "action #{action} is invalid!"
    end

    def self.repo_list
      repos = github.repos.list

      repos.each do |repo|
        p repo.class
        p repo
      end
    end
  end
end
