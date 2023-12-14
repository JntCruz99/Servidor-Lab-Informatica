#!/bin/bash

# Adicione aqui as configurações do /etc/hosts
sudo tee /etc/hosts > /dev/null << EOL
127.0.0.1       localhost.localdomain           localhost
127.0.1.1       zer01ti.zer01ti.intra           z1tsp01sh01
192.168.18.10   z1tsp01sh01.zer01ti.intra       z1tsp01sh01
EOL

# Adicione aqui as configurações do /etc/hostname
echo "Z1TSP01SH01.ZER01TI.INTRA" | sudo tee /etc/hostname > /dev/null

# Instalar pacotes necessários
sudo apt-get update
sudo apt-get install -y autoconf bind9utils bison debhelper dnsutils docbook-xml docbook-xsl flex gdb libjansson-dev libacl1-dev libaio-dev libarchive-dev libattr1-dev libblkid-dev libbsd-dev libcap-dev libcups2-dev libgnutls28-dev libgpgme11-dev libjson-perl libldap2-dev libncurses5-dev libpam0g-dev libparse-yapp-perl libpopt-dev libreadline-dev nettle-dev perl perl-modules pkg-config python-all-dev python-crypto python-dbg python-dev python-dnspython python3-dnspython python-gpg python3-gpg python-markdown python3-markdown python3-dev xsltproc zlib1g-dev liblmdb-dev lmdb-utils libsystemd-dev

# Reiniciar o servidor
sudo reboot

# Instalar pacotes adicionais
sudo apt-get install -y samba krb5-user winbind libnss-winbind smbclient ldap-utils acl attr ntp

# Parar os serviços do Samba
sudo systemctl stop smbd.service
sudo systemctl stop nmbd.service
sudo systemctl stop winbind.service

# Fazer backup do smb.conf
sudo mv /etc/samba/smb.conf /etc/samba/smb.conf.bkp

# Provisionar o domínio interativamente
sudo samba-tool domain provision --use-rfc2307 --interactive

# Iniciar os serviços
sudo systemctl restart samba-ad-dc.service

# Ajustar scripts para inicialização correta
sudo systemctl unmask samba-ad-dc.service
sudo systemctl enable samba-ad-dc.service
sudo systemctl restart samba-ad-dc.service

# Verificar o status do serviço do Samba
sudo systemctl status samba-ad-dc.service

# Editar o arquivo /etc/resolv.conf
sudo systemctl disable systemd-resolved.service
sudo systemctl stop systemd-resolved.service
sudo tee /etc/resolv.conf > /dev/null << EOL
nameserver 127.0.0.1
search zer01ti.intra
EOL

# Copiar krb5.conf do Samba 4 para /etc
sudo cp -vb /var/lib/samba/private/krb5.conf /etc/krb5.conf

# Reboot do servidor
sudo reboot

# Realizar testes e verificações
sudo smbclient -L localhost -U Administrator
host -t A zer01ti.intra
host -t SRV _ldap._tcp.zer01ti.intra
host -t SRV _kerberos._udp.zer01ti.intra
kinit administrator@ZER01TI.INTRA
klist
sudo samba-tool domain level show
