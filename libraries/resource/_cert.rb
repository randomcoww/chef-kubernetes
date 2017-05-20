class ChefKubernetes
  class Resource
    class Cert < Chef::Resource
      resource_name :kubernetes_cert

      default_action :create
      allowed_actions :create, :create_if_missing, :delete

      property :exists, [TrueClass, FalseClass]

      property :data_bag, String
      property :data_bag_item, String

      property :root_cn, String, default: 'kube-ca'
      property :cn, String
      property :content, String
      property :path, String, desired_state: false,
                              default: lazy { ::File.join(KubernetesCert::BASE_PATH, name) }


      def provider
        ChefKubernetes::Provider::Cert
      end

      private

      def generator
        Generator.new(data_bag, data_bag_item, root_cn)
      end
    end
  end
end
