resource "kubernetes_namespace" "vault" {
  metadata {
    name = "vault"
  }
}

# kube service account for vso-auth
resource "kubernetes_service_account" "vso-auth" {
  metadata {
    name = "vso-auth"
    namespace = "vault"
  }
}

# allows vso-auth service account token to query tokenreview api
resource "kubernetes_cluster_role_binding" "vso-auth" {
  metadata {
    name = "role-tokenreview-binding"
  }
  role_ref {
    kind = "ClusterRole"
    name = "system:auth-delegator"
    api_group = "rbac.authorization.k8s.io"
  }
  subject {
    kind = "ServiceAccount"
    name = "vso-auth"
    namespace = "vault"
  }
}

# used to output token_reviewer_jwt for vault kubernetes auth backend config
resource "kubernetes_secret" "vso-auth" {
  metadata {
    name      = "vso-auth"
    namespace = "vault"
    annotations = {
      "kubernetes.io/service-account.name" = "vso-auth"
    }
  }
  type = "kubernetes.io/service-account-token"
}