# Request a spot instance
resource "aws_spot_instance_request" "spot" {
  count                   = var.SPOT_INSTANCE_COUNT  # whenever you use count, you need to use element to pick form the list.
  ami                     = data.aws_ami.ami.id
  instance_type           = var.INSTANCE_TYPE
  wait_for_fulfillment    = true 
  vpc_security_group_ids  = [aws_security_group.allow_app.id]
  subnet_id               = element(data.terraform_remote_state.vpc.outputs.PRIVATE_SUBNET_IDS, count.index)
  iam_instance_profile    = "b49-iam-admin-role"
  tags = {
    Name = "${var.COMPONENT}-${var.ENV}"
  }
}

# Creates On Demand Instance
resource "aws_instance" "od" {
  count                   = var.OD_INSTANCE_COUNT
  ami                     = data.aws_ami.ami.id
  instance_type           =  var.INSTANCE_TYPE
  vpc_security_group_ids  = [aws_security_group.allow_app.id]
  subnet_id               = element(data.terraform_remote_state.vpc.outputs.PRIVATE_SUBNET_IDS, count.index)
  iam_instance_profile    = "b49-iam-admin-role"

  tags = {
    Name = "${var.COMPONENT}-${var.ENV}"
  }
}


# Creating tags for the spot instance, if not only request tags will be created.
resource "aws_ec2_tag" "name-tag" {
  count       = var.SPOT_INSTANCE_COUNT + var.OD_INSTANCE_COUNT
  resource_id = element(local.ALL_INSTANCE_IDS, count.index)
  key         = "Name"
  value       = "${var.COMPONENT}-${var.ENV}-${count.index}"
}

resource "aws_ec2_tag" "monitor-tag" {
  count       = var.SPOT_INSTANCE_COUNT + var.OD_INSTANCE_COUNT
  resource_id = element(local.ALL_INSTANCE_IDS, count.index )
  key         = "prometheus-monitor"
  value       = "yes"
}