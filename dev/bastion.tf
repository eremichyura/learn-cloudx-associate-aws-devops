#                              BASTION                                  #

resource "aws_instance" "cloudx_bastion_ec2" {
  ami                         = var.bastion_ec2.image_id
  instance_type               = var.bastion_ec2.instance_type
  key_name                    = aws_key_pair.cloudx_ghost-ec2-pool.key_name
  monitoring                  = var.bastion_ec2.monitoring
  associate_public_ip_address = var.bastion_ec2.associate_public_ip_address
  subnet_id                   = aws_subnet.cloudx_subnet_public_a.id
  vpc_security_group_ids = ([
    [for x in aws_security_group.cloudx_security_groups :
    x.id if x.name == var.bastion_ec2.bastion_sg_name && x.vpc_id == aws_vpc.cloudx_vpc.id][0]
  ])
  tags = merge(var.common_project_tags, var.bastion_ec2.tags)
}
