resource "null_resource" "eks-cluster" {
  provisioner "local-exec" {
    command = "eksctl create cluster -f ${var.eks_config_path}"
  }

  provisioner "local-exec" {
    when    = "destroy"
    command = "eksctl delete cluster -f ${var.eks_config_path}"
  }
}
