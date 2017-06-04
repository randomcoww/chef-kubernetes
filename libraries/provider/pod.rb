## Writing pod manifests using the file resource seems to occasionally
## disrupt their run state even if file contents are not changed.
## This is a wrapper to compare content before passing to file

class ChefKubernetes
  class Provider
    class Pod < Chef::Provider
      provides :kubernetes_pod, os: "linux"

      def load_current_resource
        @current_resource = ChefKubernetes::Resource::Pod.new(new_resource.name)

        if ::File.exist?(new_resource.path)
          current_resource.content(::File.read(new_resource.path))
        else
          current_resource.content(nil)
        end

        current_resource
      end

      ## "restart" trigger by force re-writing the static pod file
      def action_restart
        converge_by("Restart Kubernetes pod: #{new_resource}") do
          pod_manifest.run_action(:delete) if !current_resource.content.nil?
          pod_manifest.run_action(:create)
        end
      end

      def action_create
        converge_by("Create Kubernetes pod: #{new_resource}") do
          pod_manifest.run_action(:create)
        end if current_resource.content.nil? || current_resource.content != new_resource.content
      end

      def action_delete
        converge_by("Delete Kubernetes pod: #{new_resource}") do
          pod_manifest.run_action(:delete)
        end if !current_resource.content.nil?
      end

      private

      def pod_manifest
        @pod_manifest ||= Chef::Resource::File.new(new_resource.path, run_context).tap do |r|
          r.path new_resource.path
          r.content new_resource.content
        end
      end
    end
  end
end
