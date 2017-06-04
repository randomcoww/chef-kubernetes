class ChefKubernetes
  class Resource
    class Ca < Chef::Resource
      resource_name :kubernetes_ca

      default_action :create
      allowed_actions :create, :create_if_missing

      property :data_bag, String
      property :data_bag_item, String

      property :cert_path, String, desired_state: false,
                              default: lazy { ::File.join(KubernetesHelper::BASE_PATH , "#{name}.crt") }

      property :cert, [String,NilClass], default: lazy { generator.root_ca.to_pem }


      private

      def generator
        KubernetesHelper::CertGenerator.new(data_bag, data_bag_item)
      end
    end
  end
end
