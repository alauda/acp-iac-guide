## Why choose alekc/kubectl as the Provider?

We recommend using the [alekc/kubectl provider](https://registry.terraform.io/providers/alekc/kubectl/latest) instead of the [hashicorp/kubernetes provider](https://registry.terraform.io/providers/hashicorp/kubernetes/latest). This recommendation is based on the following considerations:

- **Broader Compatibility**: The alekc/kubectl Provider manages resources by directly executing kubectl commands. This approach supports all types of Kubernetes resources, including those provided through aggregated API servers. In contrast, the official Kubernetes Provider relies on server-side apply capabilities, which may be limited in certain situations.

- **More Flexible Deployment Process**: During the `terraform plan` phase, the official Kubernetes provider requires that the CRDs (Custom Resource Definitions) for all resources being used already exist in the target cluster. This means users cannot deploy resource CRDs and resource instances simultaneously within the same Terraform repository. The alekc/kubectl provider, however, does not need to verify the existence of CRDs during the plan phase, offering greater flexibility.

- **Simplified Resource Management**: The alekc/kubectl provider allows direct use of native Kubernetes YAML definitions to manage resources. For users familiar with Kubernetes, this can significantly reduce the learning curve and simplify the resource management process.

- **Better Version Compatibility**: Since the alekc/kubectl provider relies on the kubectl command-line tool, it typically adapts better to different versions of Kubernetes clusters, reducing the occurrence of version compatibility issues.
