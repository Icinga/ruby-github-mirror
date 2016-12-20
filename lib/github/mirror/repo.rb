require 'git'

module Github
  module Mirror
    class Repo
      attr_accessor :name, :target

      attr_reader :github, :api_data

      def initialize(name, github, api_data)
        @name   = name
        @github = github

        @api_data = api_data
      end

      def clone_url
        @api_data.clone_url
      end

      def description
        @api_data.description
      end

      def sync
        unless @target.exists?
          Mirror.logger.info "Creating repo #{@name} in target"
          @target.create
        end

        sync_settings
        sync_data
        sync_data_to_target
      end

      def target_url
        @target.project.ssh_url_to_repo
      end

      def sync_settings
        update                    = {}
        project                   = @target.project
        desc                      = "[GitHub Mirror] #{description}"

        update[:description]      = desc if desc != project.description
        # ensure public
        update[:visibility_level] = 20 if project.visibility_level < 20

        # disable features
        %w(issues wiki builds snippets merge_requests).each do |feature|
          sym         = "#{feature}_enabled".to_sym
          update[sym] = false if project.public_send(sym)
        end

        return if update.empty?

        Mirror.logger.info "Updating settings for #{@name}: #{update}"
        @target.edit(update)
      end

      def git
        work_dir = Github::Mirror.work_dir
        repo     = "#{work_dir}/#{@name}.git"

        unless File.exist?(repo)
          Git.init(repo,
                   bare:       true,
                   repository: repo)
        end

        Git.bare(repo)
      end

      def sync_data(fetch_opts = '+refs/*:refs/*')
        origin = git.remote('origin')
        origin = git.add_remote('origin', clone_url) unless origin.url
        git.lib.config_set('remote.origin.url', clone_url) unless origin.url == clone_url
        git.lib.config_set('remote.origin.fetch', fetch_opts) unless origin.fetch_opts == fetch_opts

        Mirror.logger.info 'Fetching data from origin'
        git.fetch('origin', mirror: true)
      end

      def sync_data_to_target
        target = git.remote('target')
        target = git.add_remote('target', target_url) unless target.url
        git.lib.config_set('remote.target.url', target_url) unless target.url == target_url

        Mirror.logger.info 'Pushing data to target'
        # TODO: improve this, we need to access a private function
        # git.lib.command('push', %w(target --mirror))
        git.lib.instance_eval('command(\'push\', %w(target --mirror))')
      end
    end
  end
end
