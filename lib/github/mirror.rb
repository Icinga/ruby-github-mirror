require 'github_api'
require 'optparse'

require 'github/mirror/utility'
require 'github/mirror/repo'

module Github
  # Mirror helper to mirror a whole GitHub organization into another Git environment
  module Mirror
    @arguments = nil
    @config = nil
    @config_default = {
      github: {
        auto_pagination: true
      }
    }
    @github = nil
    @target = nil
    @logger = nil

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

      raise ArgumentError, 'github / user must be configured!' unless @config[:github][:user]
      @config
    end

    def self.target
      return @target if @target

      t = @config[:target]
      raise ArgumentError, 'target not configured' unless t

      raise ArgumentError, "target #{t} is not implemented" unless t == 'gitlab'

      require 'github/mirror/target/gitlab'
      @target = Target::Gitlab
      @target.setup(@config[t.to_sym])
      @target
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
        opts.on('sync') do
          @arguments[:action] = 'sync'
        end
      end.parse!
    end

    def self.main(argv)
      parse_arguments(argv)

      action = @arguments[:action] || 'list'

      return repo_list if action == 'list'
      return repo_sync if action == 'sync'

      raise ArgumentError, "action #{action} is invalid!"
    end

    def self.repo_list
      github.repos.list.each do |repo|
        r = Repo.new(repo.name, github, repo)
        puts "#{r.name} -> #{r.clone_url}"
      end
    end

    def self.repo_sync
      github.repos.list.each do |repo|
        logger.info "Syncing #{repo.name}..."

        r = Repo.new(repo.name, github, repo)
        r.target = target.new(repo.name)

        r.sync
      end
    end

    def self.work_dir
      return config[:work_dir] if config[:work_dir]

      dir = File.dirname(File.dirname(File.dirname(__FILE__))) + '/tmp'
      Dir.mkdir(dir) unless File.exist?(dir)
      dir
    end

    def self.logger
      @logger ||= Logger.new(STDOUT)
    end
  end
end
