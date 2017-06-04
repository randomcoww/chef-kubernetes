class ChefKubernetes
  class Resource
    class Pod < Chef::Resource
      resource_name :kubernetes_pod

      default_action :create
      allowed_actions :create, :delete, :restart

      property :config, Hash, default: {}
      property :content, [String, NilClass], default: lazy { config.to_hash.to_yaml }
      property :path, String, default: lazy { name }
    end
  end
end
