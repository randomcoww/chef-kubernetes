class ChefKubernetes
  class Resource
    class NodeCert < ChefKubernetes::Resource::Cert
      resource_name :kubernetes_node_cert

      property :content, String, default: lazy { to_conf }
      property :alt_names, Hash

      private

      def to_conf
        generator.node_cert(name, alt_names).to_pem
      end
    end
  end
end
