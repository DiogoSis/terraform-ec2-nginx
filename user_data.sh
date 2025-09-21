#!/bin/bash
# Registrar todos os comandos e suas saídas em um arquivo de log
exec > >(tee /var/log/user-data.log) 2>&1

echo "=== INICIANDO CONFIGURAÇÃO DA INSTÂNCIA $(date) ==="

# Aguarda 10 segundos para garantir que a rede esteja disponível
sleep 10

# Atualiza o sistema
apt-get update
apt-get install -y apt-transport-https ca-certificates curl software-properties-common

# Instala Docker usando o método oficial da documentação
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io

# Inicia e habilita o Docker
systemctl start docker
systemctl enable docker

# Adiciona o usuário ubuntu ao grupo docker
usermod -aG docker ubuntu

# Instala o Docker Compose
curl -L "https://github.com/docker/compose/releases/download/v2.23.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Cria os diretórios e arquivos
mkdir -p /home/ubuntu/app
cd /home/ubuntu/app || exit

# Cria o arquivo docker-compose.yml
cat > docker-compose.yml << 'EOT'
${docker_compose_content}
EOT

# Cria o arquivo nginx.conf
cat > nginx.conf << 'EOT'
${nginx_conf_content}
EOT

# Corrige as permissões
chown -R ubuntu:ubuntu /home/ubuntu/app

# Inicia os containers
cd /home/ubuntu/app || exit
docker-compose up -d

# Verifica se os containers estão rodando
sleep 20
docker ps

echo "=== CONFIGURAÇÃO CONCLUÍDA $(date) ==="