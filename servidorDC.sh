#!/bin/bash

# Instale o Samba
sudo apt install samba

# Configure a placa de rede da Internet
sudo ifconfig eth0 192.168.1.1 netmask 255.255.255.0

# Configure a placa de rede da rede local
sudo ifconfig eth1 10.0.0.1 netmask 255.255.255.0

# Edite o arquivo de configuração do Samba
sudo nano /etc/samba/smb.conf

# Adicione as seguintes linhas:

[global]
workgroup = labfesvip
netbios name = servidorcd
server string = Servidor Samba

security = user

realm = labfesvip

interfaces = lo eth0 eth1

domain master = yes
preferred master = yes
local master = yes
domain logons = yes
logon script = netlogon

# Salve e feche o arquivo

# Reinicie o Samba
sudo service smbd restart

# Crie um usuário administrador
sudo smbpasswd -a administrador

# Acesse o domínio

net use \\servidorcd\c$ /u:administrador
