class ChefKubernetes
  class Resource
    class AdminCert < ChefKubernetes::Resource::Cert
      resource_name :kubernetes_admin_cert

      property :generate_type, String, default: 'admin_cert'
    end
  end
end
