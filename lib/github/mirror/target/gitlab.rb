require 'gitlab'

module Github
  module Mirror
    module Target
      # Create and edit a repo in Gitlab
      class Gitlab
        @@group = nil
        attr_accessor :name, :project

        def self.setup(hash)
          raise ArgumentError, 'You need to configure target group!' unless hash[:group]
          @@group = hash.delete(:group)

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

        def project
          @project ||= ::Gitlab.project("#{@@group}%2F#{@name}")
        end

        def create(options = {})
          options[:namespace_id] = options[:owner_id] = Gitlab.namespace_id
          @project = ::Gitlab.create_project(@name, options)
        end

        def edit(options = {})
          @project = ::Gitlab.edit_project(@project.id, options)
        end
      end
    end
  end
end
