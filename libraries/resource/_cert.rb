class ChefKubernetes
  class Resource
    class Cert < Chef::Resource
      resource_name :kubernetes_cert

      default_action :create_if_missing
      allowed_actions :create_if_missing

      property :data_bag, String
      property :data_bag_item, String

      property :cn, String
      property :alt_names, Hash, default: {}
      property :extensions, Hash, default: {}

      property :key_path, String, desired_state: false,
                              default: lazy { ::File.join(KubernetesCert::BASE_PATH, "#{name}.key") }
      property :cert_path, String, desired_state: false,
                              default: lazy { ::File.join(KubernetesCert::BASE_PATH, "#{name}.crt") }

      def provider
        ChefKubernetes::Provider::Cert
      end

    end
  end
end
