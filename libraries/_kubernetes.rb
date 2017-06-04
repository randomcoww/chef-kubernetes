module KubernetesHelper
  BASE_PATH ||= '/srv/kubernetes'
  ROOT_SUBJECT ||= [['CN', 'kube-ca']]
end
