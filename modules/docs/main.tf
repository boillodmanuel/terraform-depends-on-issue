terraform {
  required_providers {
    kubectl = {
      source  = "alekc/kubectl"
      version = "~> 2.0"
    }
  }
}

# Split YAML Manifest into 2 YAML Documents
data "kubectl_file_documents" "docs" {
  content = <<EOF
apiVersion: v1
kind: docs
metadata:
  name: doc1
---
apiVersion: v1
kind: docs
metadata:
  name: doc2
EOF
}

resource "kubectl_manifest" "docs" {
  count     = length(data.kubectl_file_documents.docs.documents)
  yaml_body = data.kubectl_file_documents.docs.documents[count.index]
}
