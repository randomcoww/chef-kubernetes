class ChefKubernetes
  class Provider
    class Cert < Chef::Provider
      provides :kubernetes_cert, os: "linux"

      def load_current_resource
        @current_resource = ChefKubernetes::Resource::Cert.new(new_resource.name)

        current_resource.exists(::File.exist?(new_resource.path))

        if current_resource.exists
          current_resource.content(::File.read(new_resource.path))
        else
          current_resource.content('')
        end

        current_resource
      end

      def action_create_if_missing
        converge_by("Create Kubernetes cert file: #{new_resource}") do
          create_base_path
          cert_file.run_action(:create_if_missing)
        end if !current_resource.exists
      end

      def action_create
        converge_by("Create  Kubernetes cert file: #{new_resource}") do
          create_base_path
          cert_file.run_action(:create)
        end if !current_resource.exists || current_resource.content != new_resource.content.chomp
      end

      def action_delete
        converge_by("Delete Kubernetes cert file: #{new_resource}") do
          cert_file.run_action(:delete)
        end if current_resource.exists
      end

      private

      def create_base_path
        Chef::Resource::Directory.new(::File.dirname(new_resource.path), run_context).tap do |r|
          r.recursive true
        end.run_action(:create)
      end

      def cert_file
        @cert_file ||= Chef::Resource::File.new(new_resource.path, run_context).tap do |r|
          r.path new_resource.path
          r.sensitive true
          r.content new_resource.content.chomp
        end
      end
    end
  end
end
