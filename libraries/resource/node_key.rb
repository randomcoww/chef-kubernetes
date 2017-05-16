class ChefKubernetes
  class Resource
    class NodeKey < ChefKubernetes::Resource::Cert
      resource_name :kubernetes_node_key

      property :content, String, default: lazy { to_conf }

      private

      def to_conf
        generator.node_key(name).to_pem
      end
    end
  end
end
