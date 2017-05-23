class ChefKubernetes
  class Resource
    class NodeCert < ChefKubernetes::Resource::Cert
      resource_name :kubernetes_node_cert

      property :extensions, Hash, default: {
        "basicConstraints" => "CA:FALSE",
        "keyUsage" => 'nonRepudiation, digitalSignature, keyEncipherment',
        "subjectAltName" => '@alt_names'
      }

      property :generate_type, String, default: 'node_cert'
    end
  end
end
