class ChefKubernetes
  class Resource
    class Ca < ChefKubernetes::Resource::Cert
      resource_name :kubernetes_cert

      property :content, String, default: lazy { to_conf }

      private

      def to_conf
        generator.root_ca.to_pem
      end
    end
  end
end
