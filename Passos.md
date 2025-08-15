# ---------------- Instalação do Terraform no Linux  -------------------

Opção 1

1. Pré-requisitos
sudo apt update
sudo apt install -y curl unzip gnupg lsb-release ca-certificates software-properties-common


2. Importar a chave GPG da HashiCorp e adicionar o keyring:
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

3. Adicionar o repositório:
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

4. Atualizar e instalar o Terraform:
sudo apt update
sudo apt install -y terraform
 
5. Verificar instalação:
terraform -version

-------

Opção 2
1. Importação da chave
wget -O - https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg2

2. Instalação
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.listsudo 

3. Instalação do Terraform
apt update && sudo apt install terraform

4. Verificar instalação
terraform -version


# ---------------- Instalação do AWS CLI  -------------------

Opção 1 - Mais atual e recomendada

1. Caso haja alguma instalação na máquina
 sudo rm -f /usr/bin/aws
 sudo rm -f /usr/bin/aws_completer
 sudo rm -rf /usr/local/aws-cli
 sudo rm -f /usr/local/bin/aws
 sudo rm -f /usr/local/bin/aws_completer

2. Baixar a AWS CLI v2 mais recente
 curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"

3. Descompactar
 unzip awscliv2.zip

4. Instalar
 sudo ./aws/install
 
5. Verificar
 aws --version

# ---------------- Configuração AWS CLI  -------------------

sudo apt update
sudo apt install -y awscli
aws --version
aws configure
vim ~/.aws/credentials
vim ~/.aws/config

----

# Configuração da credencial
 vim ~/.aws/credentials

[default]
aws_acess_key_id = Chave de acesso
aws_secret_acess_key = Chave de acesso secreta


# Configuração da zona e saída
vim ~/.aws/config 

[default]
region = us-east-1
output = json


# ---------------- Comandos para executar o lab  -------------------

# Executar no terminal do linux

terraform init
terraform validate
terraform plan
terraform apply -auto-approve
terraform destroy -auto-approve


