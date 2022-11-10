# Locals helps you in reducing the code repetitiveness
locals {
    ALL_INSTANCE_IDS = concat(aws_instance.od.*.id, aws_spot_instance_request.spot.*.spot_instance_id)
    ALL_INSTANCE_PRIVATE_IPS = concat(aws_instance.od.*.private_ip, aws_spot_instance_request.spot.*.private_ip)
}