module Github
  module Mirror
    class Repo
      attr_accessor :name, :target

      attr_reader :github, :api_data

      def initialize(name, github, api_data)
        @name = name
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
          puts "Creating repo #{@name} in target"
          @target.create
        end
        sync_settings
      end

      def sync_settings
        update = {}
        project = @target.project
        desc = "[GitHub Mirror] #{description}"

        update[:description] = desc if desc != project.description
        # ensure public
        update[:visibility_level] = 20 if project.visibility_level < 20

        # disable features
        %w(issues wiki builds snippets merge_requests).each do |feature|
          sym         = "#{feature}_enabled".to_sym
          update[sym] = false if project.public_send(sym)
        end

        return if update.empty?

        puts "Updating #{update}"
        @target.edit(update)
      end
    end
  end
end
