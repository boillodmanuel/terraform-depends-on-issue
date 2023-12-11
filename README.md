# Terraform `depends_on` issue

Terraform projects that shows issue on how terraform do the plan with the `depends_on` attribute.

When a module contains a datasource and is declared with a `depends_on`  to a known resource, the datasource will be `unknown` (cannot be determined until apply) which causes errors in a lot of situation.

In this showcase, the dependency is a `terraform_data` resource with a static value. This should not impact the plan as it is `known`!
But, here we get the following error:
```
The "count" value depends on resource attributes that cannot be determined until apply, so Terraform cannot predict how many instances will be created. To work around this, use the -target argument to first apply only
the resources that the count depends on.
```

# Terraform Plan output


## Terraform plan with `depends_on`

With the `depends_on`:

```terraform
# main.tf
module "docs" {
  source          = "./modules/docs"
  depends_on = [ terraform_data.known_data ]
}
```

We get the following output **with the `unkown` resource error**:

```
Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create
 <= read (data resources)

Terraform planned the following actions, but then encountered a problem:

  # terraform_data.known_data will be created
  + resource "terraform_data" "known_data" {
      + id     = (known after apply)
      + input  = "1"
      + output = (known after apply)
    }

  # module.docs.data.kubectl_file_documents.docs will be read during apply
  # (depends on a resource or a module with changes pending)
 <= data "kubectl_file_documents" "docs" {
      + content   = <<-EOT
            apiVersion: v1
            kind: docs
            metadata:
              name: doc1
            ---
            apiVersion: v1
            kind: docs
            metadata:
              name: doc2
        EOT
      + documents = (known after apply)
      + id        = (known after apply)
      + manifests = (known after apply)
    }

Plan: 1 to add, 0 to change, 0 to destroy.
╷
│ Error: Invalid count argument
│ 
│   on modules/docs/main.tf line 26, in resource "kubectl_manifest" "docs":
│   26:   count     = length(data.kubectl_file_documents.docs.documents)
│ 
│ The "count" value depends on resource attributes that cannot be determined until apply, so Terraform cannot predict how many instances will be created. To work around this, use the -target argument to first apply only
│ the resources that the count depends on.
╵
```

## Terraform plan without `depends_on`


Without the `depends_on`:

```terraform
# main.tf
module "docs" {
  source          = "./modules/docs"
}
```

The plan output works fine:

```
module.docs.data.kubectl_file_documents.docs: Reading...
module.docs.data.kubectl_file_documents.docs: Read complete after 0s [id=fec7d70476e63a50bf0be1e07a5de930dcacde17a90a1280f4aac58c75b3a29b]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # terraform_data.known_data will be created
  + resource "terraform_data" "known_data" {
      + id     = (known after apply)
      + input  = "1"
      + output = (known after apply)
    }

  # module.docs.kubectl_manifest.docs[0] will be created
  + resource "kubectl_manifest" "docs" {
      + api_version             = "v1"
      + apply_only              = false
      + field_manager           = "kubectl"
      + force_conflicts         = false
      + force_new               = false
      + id                      = (known after apply)
      + kind                    = "docs"
      + live_manifest_incluster = (sensitive value)
      + live_uid                = (known after apply)
      + name                    = "doc1"
      + namespace               = (known after apply)
      + server_side_apply       = false
      + uid                     = (known after apply)
      + validate_schema         = true
      + wait_for_rollout        = true
      + yaml_body               = (sensitive value)
      + yaml_body_parsed        = <<-EOT
            apiVersion: v1
            kind: docs
            metadata:
              name: doc1
        EOT
      + yaml_incluster          = (sensitive value)
    }

  # module.docs.kubectl_manifest.docs[1] will be created
  + resource "kubectl_manifest" "docs" {
      + api_version             = "v1"
      + apply_only              = false
      + field_manager           = "kubectl"
      + force_conflicts         = false
      + force_new               = false
      + id                      = (known after apply)
      + kind                    = "docs"
      + live_manifest_incluster = (sensitive value)
      + live_uid                = (known after apply)
      + name                    = "doc2"
      + namespace               = (known after apply)
      + server_side_apply       = false
      + uid                     = (known after apply)
      + validate_schema         = true
      + wait_for_rollout        = true
      + yaml_body               = (sensitive value)
      + yaml_body_parsed        = <<-EOT
            apiVersion: v1
            kind: docs
            metadata:
              name: doc2
        EOT
      + yaml_incluster          = (sensitive value)
    }

Plan: 3 to add, 0 to change, 0 to destroy.
```