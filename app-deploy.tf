# Run the provisioner to configure the app 

resource "null_resource" "app_deploy" {
  triggers = {    
        a = timestamp()  # Everytime you run, when compared to the last time, the time changes, so it will be triggered all the time.
  }
  count = var.SPOT_INSTANCE_COUNT + var.OD_INSTANCE_COUNT
  provisioner "remote-exec" {
      connection {
        type     = "ssh"
        user     =  jsondecode(data.aws_secretsmanager_secret_version.secrets.secret_string)["SSH_USER"]
        password =  jsondecode(data.aws_secretsmanager_secret_version.secrets.secret_string)["SSH_PASS"]
        # host     = self.public_ip
        host     = element(local.ALL_INSTANCE_PRIVATE_IPS, count.index)
      } 
    inline = [
     "ansible-pull -U https://github.com/codesud/ansible.git -e COMPONENT=${var.COMPONENT} -e ENV=dev -e TAG_NAME=${var.APP_VERSION} -e DOCDB_ENDPOINT=${data.terraform_remote_state.db.outputs.MONGODB_ENDPOINT} roboshop.yml"
      ]
    }
}

# APP_VERSION is needed only for APP Components and not DB Components. And for DB , let's declare a null value, so that we don;t get the variable not found exception
