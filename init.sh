#! /bin/bash -e
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add - ;\
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install boundary-enterprise -y

sudo mkdir -p /etc/boundary/worker

# create the boundary config
sudo cat <<EOF > /etc/boundary/config.hcl
hcp_boundary_cluster_id = "${cluster_id}"

listener "tcp" {
  address = "0.0.0.0:9202"
  purpose = "proxy"
}

worker {
  tags {
    type   = ["prod"]
    region = ["eu-west-1"]
  }

  controller_generated_activation_token = "${worker_token}"
  auth_storage_path = "/etc/boundary/worker"
}
EOF

# create the system d unit
sudo cat <<EOF > /etc/systemd/system/boundary_worker.service
[Unit]
Description=Boundary Worker

[Service]
ExecStart=/usr/bin/boundary server -config="/etc/boundary/config.hcl"

[Install]
WantedBy=multi-user.target
EOF

sudo sytemctl enable /etc/systemd/system/boundary_worker.service
sudo sytemctl daemon-reload
sudo systemctl start boundary_worker