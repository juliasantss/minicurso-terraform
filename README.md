Olá, pessoal! 👋
Meu nome é Júlia, sou uma profissional com experiência em infraestrutura em nuvem e automação de ambientes. Ao longo da minha experiência, percebi como o Terraform facilita a criação, manutenção e destruição de recursos de forma simples, padronizada e reproduzível. Por isso, preparei este minicurso prático para compartilhar esse conhecimento com vocês.

Hoje, vamos colocar a mão na massa e criar uma infraestrutura real na AWS, utilizando apenas código. Não é só teoria — cada recurso que vamos provisionar será explicado passo a passo, para que vocês entendam o que, por que e como estamos fazendo.


# ---------------- Objetivo do Minicurso  -------------------
1. Compreender o que é o Terraform e como ele interage com a AWS.

2. Criar uma VPC com subnets públicas e privadas, roteamento e NAT Gateway.

3. Entender o papel de cada recurso da topologia.

4. Seguir boas práticas de organização e versionamento do código.

5. No final, destruir tudo para não gerar custos extras.


# ---------------- Arquitetura AWS Terraform -------------------

A infraestrutura será composta por:

1. VPC: nossa rede principal na AWS.

2. 4 Subnets:

2 públicas (com acesso direto à internet).

2 privadas (acesso à internet via NAT Gateway).

3. Internet Gateway: para permitir saída das subnets públicas.

4. Route Tables: definindo como o tráfego será roteado.

5. NAT Gateway: para permitir que as subnets privadas acessem a internet.

📌 Fluxo de rede:

Subnets públicas → Internet Gateway → Internet.

Subnets privadas → NAT Gateway → Internet Gateway → Internet.

# ----------------------------------------------------------------

💡 Ao final, vocês vão entender como transformar um desenho de arquitetura em código executável com Terraform — algo essencial para quem quer trabalhar com DevOps, Cloud ou SRE.


# ------------------- Providers -------------------

terraform {                               # Bloco de configuração do Terraform
  required_providers {                    # Define quais provedores serão utilizados
    aws = {                               # Provedor AWS
        source = "hashicorp/aws"          # Fonte do provedor (oficial HashiCorp)
        version = "~> 5.0"                 # Versão do provedor AWS
    }
  }
}

provider "aws" {                          # Define o provedor AWS
  region = "us-east-1"                    # Região onde os recursos serão criados

  default_tags {                          # Tags aplicadas automaticamente a todos os recursos
    tags = {
      owner = "Júlia"                     # Tag para identificar o criador
      managed-by = "minicurso-terraform"  # Tag para indicar que foi criado via Terraform
    }
  }
}

# ------------------- NETWORK -------------------

resource "aws_vpc" "vpc" {                # Cria a VPC principal
    cidr_block = "10.0.0.0/20"             # Faixa de IPs da VPC
    tags = {
        Name = "Vpc-Lab"                   # Nome da VPC
    }
}

resource "aws_subnet" "public-1a" {        # Subnet pública 1 (AZ us-east-1a)
    vpc_id = aws_vpc.vpc.id                # ID da VPC onde será criada
    cidr_block = "10.0.0.0/23"              # Faixa de IPs da subnet
    map_public_ip_on_launch = true         # IP público automático
    availability_zone = "us-east-1a"       # Zona de disponibilidade
    tags = {
        Name = "Sub-Lab-Pub-1a"             # Nome da subnet
    }
}

resource "aws_subnet" "public-1b" {        # Subnet pública 2 (AZ us-east-1b)
    vpc_id = aws_vpc.vpc.id
    cidr_block = "10.0.2.0/23"
    map_public_ip_on_launch = true
    availability_zone = "us-east-1b"
    tags = {
      Name = "Sub-Lab-Pub-1b"
    }
}

resource "aws_subnet" "privada-1c" {       # Subnet privada 1 (AZ us-east-1c)
    vpc_id = aws_vpc.vpc.id
    cidr_block = "10.0.4.0/23"
    availability_zone = "us-east-1c"
    tags = {
        Name = "Sub-Lab-Priv-1c"
    }
}

resource "aws_subnet" "privada-1d" {       # Subnet privada 2 (AZ us-east-1d)
    vpc_id = aws_vpc.vpc.id
    cidr_block = "10.0.6.0/23"
    availability_zone = "us-east-1d"
    tags = {
      Name = "Sub-Lab-Priv-1d"
    }
}

resource "aws_internet_gateway" "igw" {    # Internet Gateway (acesso público)
    vpc_id = aws_vpc.vpc.id
    tags = {
      Name = "Internet-Gateway-Terraform"
    }
}

resource "aws_route_table" "rtb-pub" {     # Route Table para subnets públicas
    vpc_id = aws_vpc.vpc.id

    route {                                # Rota padrão para internet
        cidr_block = "0.0.0.0/0"           # Todo o tráfego externo
        gateway_id = aws_internet_gateway.igw.id
    }

    tags = {
      Name = "Rtb-Pub-Terraform"
    }
}

# ------------------- NAT Gateway -------------------

resource "aws_eip" "nat_eip" {             # Elastic IP para o NAT Gateway
    domain = "vpc"
    tags = {
      Name = "Eip-Nat-Terraform"
    }  
}

resource "aws_nat_gateway" "nat" {         # NAT Gateway (acesso internet p/ privadas)
    allocation_id = aws_eip.nat_eip.id     # Usa o Elastic IP criado
    subnet_id = aws_subnet.public-1a.id    # Criado na subnet pública 1a
    tags = {
      Name = "Nat-Gateway-Terraform"
    }
    depends_on = [ aws_internet_gateway.igw ] # Garante que o IGW já exista
}

resource "aws_route_table" "rtb-priv" {    # Route Table para subnets privadas
    vpc_id = aws_vpc.vpc.id

    route {                                # Rota padrão via NAT
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat.id
    }

    tags = {
      Name = "Rtb-Priv-Terraform"
    }
}

# ------------------- Associações -------------------

resource "aws_route_table_association" "priv-1c" { # Associa subnet privada 1c à RT privada
    subnet_id = aws_subnet.privada-1c.id
    route_table_id = aws_route_table.rtb-priv.id
}

resource "aws_route_table_association" "priv-1d" { # Associa subnet privada 1d à RT privada
    subnet_id =  aws_subnet.privada-1d.id
    route_table_id = aws_route_table.rtb-priv.id
}

resource "aws_route_table_association" "pub-1a" {  # Associa subnet pública 1a à RT pública
    subnet_id = aws_subnet.public-1a.id
    route_table_id = aws_route_table.rtb-pub.id
}

resource "aws_route_table_association" "pub-1b" {  # Associa subnet pública 1b à RT pública
    subnet_id = aws_subnet.public-1b.id
    route_table_id = aws_route_table.rtb-pub.id
}


