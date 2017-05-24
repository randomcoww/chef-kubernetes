class ChefKubernetes
  class Provider
    class Ca < Chef::Provider
      provides :kubernetes_ca, os: "linux"

      def load_current_resource
        @current_resource = ChefKubernetes::Resource::Ca.new(new_resource.name)

        if ::File.exist?(new_resource.cert_path)
          current_resource.cert(::File.read(new_resource.cert_path))
        else
          current_resource.cert(nil)
        end

        current_resource
      end


      def action_create_if_missing
        if !current_resource.cert.nil?

          converge_by("Create Kubernetes cert file: #{new_resource}") do
            create_base_path
            cert_file.run_action(:create_if_missing)
          end
        end
      end

      def action_create
        if current_resource.cert != new_resource.cert.chomp

          converge_by("Create Kubernetes cert file: #{new_resource}") do
            create_base_path
            cert_file.run_action(:create)
          end
        end
      end


      private

      def create_base_path
        Chef::Resource::Directory.new(::File.dirname(new_resource.cert_path), run_context).tap do |r|
          r.recursive true
        end.run_action(:create)
      end

      def cert_file
        @cert_file ||= Chef::Resource::File.new(new_resource.cert_path, run_context).tap do |r|
          r.path new_resource.cert_path
          r.sensitive true
          r.content new_resource.cert.chomp
        end
      end
    end
  end
end
