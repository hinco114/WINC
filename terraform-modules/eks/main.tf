resource "null_resource" "eks-cluster" {
  provisioner "local-exec" {
    command = "eksctl create cluster -f ${var.eks_config_path}"
  }
}
