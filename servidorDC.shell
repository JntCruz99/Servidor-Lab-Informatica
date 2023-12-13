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
echo "[global]
   workgroup = $DOMINIO
   netbios name = $NOME_SERVIDOR
   server role = active directory domain controller
   dns forwarder = 8.8.8.8
   idmap_ldb:use rfc2307 = yes" >> /etc/samba/smb.conf

# Reinicia o serviço Samba
systemctl restart smbd

# Configura as interfaces de rede (substitua eth0 e eth1 pelos nomes de suas interfaces)
echo "auto eth0
iface eth0 inet dhcp" > /etc/network/interfaces

echo "auto eth1
iface eth1 inet static
    address 192.168.1.1
    netmask 255.255.255.0" >> /etc/network/interfaces

# Reinicia as interfaces de rede
systemctl restart networking

# Adiciona o usuário "suporte" como administrador do domínio
samba-tool user add $USUARIO_ADMIN $SENHA_USUARIO_ADMIN --given-name="Suporte" --surname="Administrador"
samba-tool group addmembers "Domain Admins" $USUARIO_ADMIN

# Adiciona o usuário "aluno" ao domínio sem privilégios de administrador
samba-tool user add $USUARIO_ALUNO $SENHA_ALUNO --given-name="Aluno" --surname="Sobrenome"

# Reinicia o serviço Samba após adicionar usuários
systemctl restart smbd

echo "Configuração concluída. O controlador de domínio Samba está pronto para uso. Usuários adicionados."
