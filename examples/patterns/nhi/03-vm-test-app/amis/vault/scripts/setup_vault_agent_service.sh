# Sets up the vault agent as a service for systemd on linux

sudo tee /etc/systemd/system/vault-agent.service <<EOF
[Unit]
Description=HashiCorp Vault Agent
Documentation="https://developer.hashicorp.com/vault/docs/agent-and-proxy/agent"
ConditionFileNotEmpty="/etc/vault.d/agent-config.hcl"

[Service]
User=vault
Group=vault
SecureBits=keep-caps
AmbientCapabilities=CAP_IPC_LOCK
CapabilityBoundingSet=CAP_SYSLOG CAP_IPC_LOCK
NoNewPrivileges=yes
ExecStart=/usr/bin/vault agent -config=/etc/vault.d/agent-config.hcl
ExecReload=/bin/kill --signal HUP
KillMode=process
KillSignal=SIGINT

[Install]
WantedBy=multi-user.target
EOF

sudo chmod 664 /etc/systemd/system/vault-agent.service
sudo systemctl daemon-reload
sudo systemctl enable vault-agent

sudo touch /var/log/vault-agent.log
sudo chown vault:vault /var/log/vault-agent.log
