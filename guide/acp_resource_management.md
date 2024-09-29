# ACP Resource Management

This section provides a detailed overview of managing ACP resources using Terraform. We offer three primary methods, each with its specific use cases and advantages. Users can choose the most suitable approach based on their requirements.

## Using Terraform ACP Modules

Our company has encapsulated Terraform modules for several ACP resources. We recommend users to prioritize these modules for managing ACP resources. Using ACP Modules offers the following advantages:

- **Simplified Configuration**: Modules encapsulate complex resource configurations, allowing users to manage ACP resources through simple parameter settings.
- **Best Practices**: These modules are designed according to ACP-recommended best practices, making IaC writing elegant and efficient.
- **Maintenance Support**: These modules are continuously maintained and updated by Alauda Cloud, ensuring compatibility with the ACP platform.

ACP Modules are hosted in the [alauda/terraform-acp-modules](https://github.com/alauda/terraform-acp-modules) repository. The [README document](https://github.com/alauda/terraform-acp-modules/blob/v3.16/README.md) in the repository introduces the basic usage of the modules to help users get started quickly. Additionally, the README document for each module in the repository provides detailed parameter descriptions and usage examples, allowing users to select appropriate modules based on their needs.

## Managing ACP Resources Using the Kubectl Provider

For users requiring greater flexibility, the `alekc/kubectl` provider can be used to directly manage ACP resources. This method allows users to precisely control all parameters of ACP resources and is particularly suitable for users familiar with ACP resource APIs. It serves as an effective complement, especially in scenarios not covered by our provided Terraform modules.

!!! tip ""
    If you find that certain scenarios are not covered by existing ACP modules, please feel free to contact us. We actively expand and improve ACP modules to meet more use cases.

ACP resources are provided through Kubernetes APIs. This means we can directly use the Kubectl Provider to operate these resources, just like operating regular Kubernetes resources. The following example demonstrates how to use the `alekc/kubectl` provider to manage ACP resources:

### Scenario Introduction

In this example, we assume there are two business clusters on the ACP platform:

- `dev`: Cluster for the development environment
- `prod`: Cluster for the production environment

We will deploy different versions of the same application in these two clusters, with specific configurations for each environment:

- Development environment: Uses a newer image version, single replica deployment, and configures specific development environment variables
- Production environment: Uses a stable image version, multi-replica deployment, and configures specific production environment variables

This example demonstrates how to use Terraform with ACP to manage applications across multiple clusters simultaneously, achieving environmental consistency and configuration differentiation.

### Example Code

```hcl
terraform {
  required_providers {
    acp = {
      source  = "alekc/kubectl"
      version = "~> 2.0"
    }
  }
}

variable "acp_endpoint" {
  type string
}

variable "acp_token" {
  type string
}

provider acp {
  alias = "dev"
  host = format("%s/kubernetes/dev", trimsuffix(var.acp_endpoint, "/"))
  token = var.acp_token
  load_config_file = false
}
provider acp {
  alias = "prod"
  host = format("%s/kubernetes/prod", trimsuffix(var.acp_endpoint, "/"))
  token = var.acp_token
  load_config_file = false
}

# application for dev environment
resource "kubectl_manifest" "dev_application" {
  provider = acp.dev
  yaml_body = <<YAML
apiVersion: app.k8s.io/v1beta1
kind: Application
metadata:
  name: my-app-dev
  namespace: default
spec:
  assemblyPhase: Succeeded
  componentKinds:
    - group: apps
      kind: Deployment
    - group: ""
      kind: Service
  descriptor: {}
  selector:
    matchLabels:
      app.cpaas.io/name: default/my-app-dev 
YAML
}

resource "kubectl_manifest" "dev_application_deployment" {
    provider = acp.dev
    yaml_body = <<YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app.cpaas.io/name: default/my-app-dev
  name: my-app-dev
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      service.cpaas.io/name: default/my-app-dev
  strategy:
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
    type: RollingUpdate
  template:
    metadata:
      labels:
        app.cpaas.io/name: default/my-app-dev
        service.cpaas.io/name: default/my-app-dev
    spec:
      containers:
        - image: my-app:latest
          name: app
YAML
}

resource "kubectl_manifest" "dev_application_service" {
    provider = acp.dev
    yaml_body = <<YAML
apiVersion: v1
kind: Service
metadata:
  name: my-app-dev
  namespace: default
spec:
  selector:
    app.cpaas.io/name: default/my-app-dev
  type: ClusterIP
  ports:
    - port: 80
      targetPort: 80
YAML
}

# application for prod environment
resource "kubectl_manifest" "prod_application" {
  provider = acp.prod
  yaml_body = <<YAML
apiVersion: app.k8s.io/v1beta1
kind: Application
metadata:
  name: my-app-prod
  namespace: default
spec:
  assemblyPhase: Succeeded
  componentKinds:
    - group: apps
      kind: Deployment
    - group: ""
      kind: Service
  descriptor: {}
  selector:
    matchLabels:
      app.cpaas.io/name: default/my-app-prod 
YAML
}

resource "kubectl_manifest" "prod_application_deployment" {
    provider = acp.prod
    yaml_body = <<YAML
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app.cpaas.io/name: default/my-app-prod
  name: my-app-prod
  namespace: default
spec:
  replicas: 3   
  selector:
    matchLabels:
      service.cpaas.io/name: default/my-app-prod
  strategy:
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
    type: RollingUpdate
  template:
    metadata:
      labels:
        app.cpaas.io/name: default/my-app-prod
        service.cpaas.io/name: default/my-app-prod
    spec:
      containers:
        - image: my-app:1.23.4
          name: app
YAML
}

resource "kubectl_manifest" "prod_application_service" {
    provider = acp.prod
    yaml_body = <<YAML
apiVersion: v1
kind: Service
metadata:
  name: my-app-prod
  namespace: default
spec:
  selector:
    app.cpaas.io/name: default/my-app-prod
  type: ClusterIP
  ports:
    - port: 80
      targetPort: 80
YAML
}

```

The usage of Provider declarations in the example can be referred to in the introduction of [Terraform and ACP Integration](./acp_terraform_integration.md).

## Encapsulating Custom Terraform Modules

For enterprise users with specific requirements, encapsulating custom Terraform Modules that fit the company's internal use cases is an ideal choice. This approach allows for module design completely based on the company's specific needs and best practices, providing a unified resource management standard for internal use, further improving team efficiency and reducing repetitive work.

We suggest users fork and modify the [alauda/terraform-acp-modules](https://github.com/alauda/terraform-acp-modules) repository, or create a new repository referencing the structure and recommended practices of [alauda/terraform-acp-modules](https://github.com/alauda/terraform-acp-modules) for development. This repository not only provides implementations of existing modules but also details how to develop ACP modules in the [Development document](https://github.com/alauda/terraform-acp-modules/blob/v3.16/Development.md), along with important principles and suggestions to follow during development. This can help you create high-quality, easily maintainable custom ACP modules.

!!! tip ""
    If you encounter any issues or need further guidance during development, please feel free to contact our support team. We are more than happy to assist you in fully leveraging the powerful features of the ACP platform and Terraform.