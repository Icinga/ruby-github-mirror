require 'gitlab'

module Github
  module Mirror
    module Target
      # Create and edit a repo in Gitlab
      class Gitlab
        @@group = nil
        @@visibility = :public
        @@visibility_level = {
            :public    => 20,
            :internal  => 10,
            :private   => 0
        }

        attr_accessor :name, :project

        def self.setup(hash)
          raise ArgumentError, 'You need to configure target group!' unless hash[:group]
          @@group = hash.delete(:group)

          if hash[:visibility]
            @@visibility = hash.delete(:visibility)
          end

          raise ArgumentError, 'Visibility must be one of public, private or internal!' unless @@visibility_level[@@visibility]

          ::Gitlab.configure do |config|
            hash.each_key do |key|
              config.public_send("#{key}=", hash[key])
            end
          end
        end

        def self.group_obj
          @@group_obj ||= ::Gitlab.group(@@group)
        end

        def self.namespace_id
          @@namespace_id ||= group_obj.id
        end

        def initialize(name)
          @name = name
        end

        def exists?
          !project.nil?
        rescue ::Gitlab::Error::NotFound
          false
        end

        def api_identifier
          "#{@@group}%2F#{@name}"
        end

        def project
          @project ||= ::Gitlab.project(api_identifier)
        end

        def branches
          @branches ||= ::Gitlab.branches(api_identifier)
        end

        def create(options = {})
          options[:namespace_id] = options[:owner_id] = Gitlab.namespace_id
          options[:visibility_level] = @@visibility_level[@@visibility]
          @project = ::Gitlab.create_project(@name, options)
        end

        def edit(options = {})
          options[:visibility_level] = @@visibility_level[@@visibility]
          @project = ::Gitlab.edit_project(@project.id, options)
        end

        def unprotect_branch(branch)
          @branches = nil
          ::Gitlab.unprotect_branch(api_identifier, branch)
        end
      end
    end
  end
end
