#!/bin/bash -ex

CFG="/etc/ssh/sshd_config"

# general
sed -ri 's/^#?Port\s+.*/Protocol 2/' $CFG
#sed -ri 's/^#?Banner\s+.*/Banner \/run\/ssh\/\/banner/' $CFG
sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin prohibit-password/' $CFG
sed -ri 's/^#?UseDNS\s+.*/UseDNS no/' $CFG

# client keys
sed -ri 's/^#?PubkeyAuthentication\s+.*/PubkeyAuthentication yes/' $CFG
sed -ri 's/^#?PermitEmptyPasswords\s+.*/PermitEmptyPasswords no/' $CFG
sed -ri 's/^#?PasswordAuthentication\s+.*/PasswordAuthentication no/' $CFG

# user allowances
sed -ri 's/^#?PermitTunnel\s+.*/PermitTunnel yes/' $CFG
sed -ri 's/^#?AllowTcpForwarding\s+.*/AllowTcpForwarding yes/' $CFG
sed -ri 's/^#?AllowAgentForwarding\s+.*/AllowAgentForwarding yes/' $CFG

# algorithm hardening
echo "" >>$CFG

echo "HostKeyAlgorithms \
    ecdsa-sha2-nistp256-cert-v01@openssh.com, \
    ecdsa-sha2-nistp256, \
    ecdsa-sha2-nistp384-cert-v01@openssh.com, \
    ecdsa-sha2-nistp384, \
    ecdsa-sha2-nistp521-cert-v01@openssh.com, \
    ecdsa-sha2-nistp521, \
    rsa-sha2-256-cert-v01@openssh.com, \
    rsa-sha2-256, \
    rsa-sha2-512-cert-v01@openssh.com, \
    rsa-sha2-512, \
    ssh-ed25519-cert-v01@openssh.com, \
    ssh-ed25519, \
    ssh-rsa-cert-v01@openssh.com \
" | sed 's/,\s*/,/g' >>$CFG

echo "KexAlgorithms \
    curve25519-sha256, \
    curve25519-sha256@libssh.org, \
    diffie-hellman-group-exchange-sha256, \
    diffie-hellman-group16-sha512, \
    diffie-hellman-group18-sha512 \
" | sed 's/,\s*/,/g' >>$CFG

echo "Ciphers \
    aes128-ctr, \
    aes192-ctr, \
    aes128-gcm@openssh.com, \
    aes256-ctr, \
    aes256-gcm@openssh.com, \
    chacha20-poly1305@openssh.com \
" | sed 's/,\s*/,/g' >>$CFG

echo "MACs \
    hmac-sha2-256-etm@openssh.com, \
    hmac-sha2-512-etm@openssh.com, \
    umac-128-etm@openssh.com \
" | sed 's/,\s*/,/g' >>$CFG

echo "" >>$CFG
echo "AllowUsers root@10.0.0.* server@10.0.0.* karl@10.0.0.* karl@192.168.*.*" >>$CFG

ufw allow ssh
