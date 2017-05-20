class ChefKubernetes
  class Resource
    class AdminCert < ChefKubernetes::Resource::Cert
      resource_name :kubernetes_admin_cert

      property :content, String, default: lazy { to_conf }

      private

      def to_conf
        generator.admin_cert(cn).to_pem
      end
    end
  end
end
