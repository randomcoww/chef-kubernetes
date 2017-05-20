class ChefKubernetes
  class Resource
    class AdminKey < ChefKubernetes::Resource::Cert
      resource_name :kubernetes_admin_key

      property :content, String, default: lazy { to_conf }

      private

      def to_conf
        generator.node_key(cn).private_key.to_pem
      end
    end
  end
end
