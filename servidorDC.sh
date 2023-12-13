#!/bin/bash

# Verifica se o script está sendo executado com permissões de superusuário
if [ "$EUID" -ne 0 ]; then
    echo "Este script precisa ser executado como superusuário (root)."
    exit 1
fi

# Instala o Samba
apt-get update
apt-get install -y samba

# Define variáveis de configuração
DOMINIO="labinformatica.fesvip"
NOME_SERVIDOR="servidorLab"
SENHA_ADMIN="jonatafesvip"
USUARIO_ADMIN="suporte"
SENHA_USUARIO_ADMIN="jonatafesvip"
USUARIO_ALUNO="aluno"
SENHA_ALUNO="senhaaluno"

# Configuração do Samba
cat <<EOL >> /etc/samba/smb.conf
[global]
   workgroup = $DOMINIO
   netbios name = $NOME_SERVIDOR
   server role = active directory domain controller
   dns forwarder = 8.8.8.8
   idmap_ldb:use rfc2307 = yes
EOL

# Reinicia o serviço Samba
systemctl restart samba-ad-dc

# Configura as interfaces de rede usando Netplan
cat <<EOL > /etc/netplan/01-netcfg.yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    eth0:
      dhcp4: yes
    eth1:
      addresses: [192.168.1.1/24]
EOL

# Aplica as configurações de rede
netplan apply

# Adiciona o usuário "suporte" como administrador do domínio
samba-tool group add "Domain Admins"
samba-tool user add $USUARIO_ADMIN $SENHA_USUARIO_ADMIN --given-name="Suporte" --surname="Administrador"
samba-tool group addmembers "Domain Admins" $USUARIO_ADMIN

# Adiciona o usuário "aluno" ao domínio sem privilégios de administrador
samba-tool user add $USUARIO_ALUNO $SENHA_ALUNO --given-name="Aluno" --surname="Sobrenome"

# Reinicia o serviço Samba após adicionar usuários
systemctl restart samba-ad-dc

echo "Configuração concluída. O controlador de domínio Samba está pronto para uso. Usuários adicionados."
