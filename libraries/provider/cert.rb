class ChefKubernetes
  class Provider
    class Cert < Chef::Provider
      provides :kubernetes_cert, os: "linux"

      def load_current_resource
        @current_resource = ChefKubernetes::Resource::Cert.new(new_resource.name)
        current_resource
      end


      def action_create_if_missing
        if !::File.exist?(new_resource.key_path) ||
          !::File.exist?(new_resource.cert_path)

          converge_by("Create Kubernetes cert file: #{new_resource}") do
            create_base_path

            key = generator.key
            cert = generator.node_cert(
              new_resource.cn,
              key,
              new_resource.extensions,
              new_resource.alt_names)

            write_files(key.to_pem, cert.to_pem)
          end
        end
      end


      private

      def generator
        KubernetesCert::CertGenerator.new(new_resource.data_bag, new_resource.data_bag_item)
      end

      def create_base_path
        Chef::Resource::Directory.new(::File.dirname(new_resource.key_path), run_context).tap do |r|
          r.recursive true
        end.run_action(:create)

        Chef::Resource::Directory.new(::File.dirname(new_resource.cert_path), run_context).tap do |r|
          r.recursive true
        end.run_action(:create)
      end

      def write_files(key, cert)
        Chef::Resource::File.new(new_resource.key_path, run_context).tap do |r|
          r.sensitive true
          r.content key.chomp
        end.run_action(:create)

        Chef::Resource::File.new(new_resource.cert_path, run_context).tap do |r|
          r.sensitive true
          r.content cert.chomp
        end.run_action(:create)
      end
    end
  end
end
