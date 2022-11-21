source "null" "example1" {
    communicator         = "none"
}

build {
    sources = [
        "source.null.example1"
    ]   

    provisioner "shell-local" {
        inline = ["sleep 10"]
    }
   
    // provisioner "ansible" {
    //     playbook_file   = "../../ansible/prep-gamingvm.yml"
    //     use_proxy       = false
    //     ansible_env_vars = [
    //         "no_proxy=\"*\""
    //     ]
    //     extra_arguments = [
    //         "-i",
    //         "${var.winrm_host},",
    //         "-e",
    //         "ansible_user=ansible ansible_password=ansible ansible_connection=winrm ansible_winrm_transport=credssp ansible_winrm_server_cert_validation=ignore"
    //     ]
    // }
}