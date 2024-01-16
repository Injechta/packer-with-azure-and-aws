# Packer et AWS : Créer des Images d'instances sur mesure

Ce guide explique comment créer des AMIs personnalisées dans AWS à l'aide de Packer. Il couvre les étapes d'installation de Packer et le processus de construction des AMIs. Pour conclure, nous testerons les AMIs en déployant des instances EC2 avec Terraform, assurant ainsi leurs fonctionnements dans AWS.


## Prérequis

Avant de commencer, assurez-vous que les outils suivants sont installés :
- Packer
- AWS CLI

## Installation de Packer

Packer peut être téléchargé et installé à partir de [la page officielle de Packer](https://www.packer.io/downloads). Suivez les instructions pour votre système d'exploitation.

## Installation du Plugin AWS pour Packer

Après l'installation de Packer, installez le plugin AWS en exécutant :

```shell
packer plugins install github.com/hashicorp/amazon
```

## Configuration de Packer pour Debian : `debian-ami.pkr.hcl`

Ce fichier de configuration Packer est utilisé pour créer une Amazon Machine Image (AMI) personnalisée basée sur Debian. Il comporte plusieurs sections clés :

### Plugins et Variables :
- **Plugin Amazon** : Nécessaire pour la construction d'AMIs sur AWS.
- **Variables** : Définissent la région AWS (`eu-north-1`) et le profil AWS (`simplon`).

### Source (`amazon-ebs`):
- **Type** : `amazon-ebs`, utilisé pour créer des AMIs basées sur Amazon EBS.
- **Configuration** : Utilise un profil AWS spécifié, la région `eu-north-1`, et un type d'instance `t3.micro`.
- **AMI Name** : Nom de l'AMI généré, comprenant un timestamp pour l'unicité.
- **Subnet et AMI Filters** : Sélectionne le sous-réseau et filtre l'AMI source basée sur Debian 11 (amd64).

### Provisioners :
- **File Provisioners** : Transfèrent `technocorp.pub` et `index.html` sur l'instance EC2.
- **Shell Provisioner** : Effectue une mise à jour du système, installe `snapd`, `certbot` (via Snap), `jq`, `apache2`, `unzip`, `git` et configure l'accès SSH pour l'utilisateur `admin`. Prépare également `index.html` pour Apache.

Cette configuration prépare une AMI Debian avec Apache et d'autres outils essentiels, prête pour des déploiements ultérieurs sur AWS.

## Configuration de Packer pour Ubuntu : `ubuntu-ami.pkr.hcl`

Ce fichier de configuration Packer est utilisé pour créer une Amazon Machine Image (AMI) personnalisée basée sur Ubuntu. Il comprend plusieurs sections clés :

### Plugins et Variables :
- **Plugin Amazon** : Nécessaire pour la construction d'AMIs sur AWS.
- **Variables** : Définissent la région AWS (`eu-north-1`) et le profil AWS (`simplon`).

### Source (`amazon-ebs`):
- **Type** : `amazon-ebs`, utilisé pour créer des AMIs basées sur Amazon EBS.
- **Configuration** : Utilise un profil AWS spécifié, la région `eu-north-1`, et un type d'instance `t3.micro`.
- **AMI Name** : Nom de l'AMI généré, comprenant un timestamp pour l'unicité.
- **Subnet et AMI Filters** : Sélectionne le sous-réseau et filtre l'AMI source basée sur Ubuntu 22.04 (Jammy Jellyfish).

### Provisioners :
- **File Provisioners** : Transfèrent `technocorp.pub` et `index.html` sur l'instance EC2.
- **Shell Provisioner** : Met à jour le système, installe `snapd`, `certbot` (via Snap), `jq`, `apache2`, `unzip`, `git` et configure l'accès SSH pour l'utilisateur `admin`. Prépare également `index.html` pour Apache.

Cette configuration prépare une AMI Ubuntu avec Apache et d'autres outils essentiels, prête pour des déploiements ultérieurs sur AWS.


## Fichier `index.html`

Le fichier `index.html` est une page web simple qui fournit des informations sur les ressources DevOps et des définitions pour des outils comme Packer et Azure Key Vault. Il inclut des liens vers des ressources utiles et des descriptions pour aider les visiteurs à comprendre ces technologies.


## Construction des images avec Packer

Pour construire les images avec Packer, assurez-vous d'être dans le répertoire de travail où se trouvent les fichiers `debian-ami.pkr.hcl` et `ubuntu-ami.pkr.hcl` . Exécutez ensuite les commandes suivantes :

```shell
packer build debian-ami.pkr.hcl
```

```shell
packer build ubuntu-ami.pkr.hcl
```

Ces commandes déclencheront le processus de construction des images dans AWS en utilisant la configuration spécifiée dans `debian-ami.pkr.hcl` et `ubuntu-ami.pkr.hcl`.

Après avoir créé vos AMIs personnalisées avec Packer, retrouvez-les dans la console AWS de la manière suivante :

Ouvrez la Console AWS Management et connectez-vous.
Allez dans le service EC2.
Dans le panneau de navigation, cliquez sur "Images" puis "AMIs".
Utilisez le filtre "Owned by me" pour afficher vos AMIs personnalisées.
Trouvez votre AMI par son nom ou ID.

Les AMIs sont désormais prêtes à être utilisées pour lancer des instances EC2, que ce soit via Terraform ou d'autres outils de gestion d'infrastructures AWS. La page web intégrée dans ces AMIs personnalisées, définie dans le fichier `index.html`, sera accessible via un navigateur après le lancement des instance EC2. La configuration Terraform nécessaire pour déployer ces instance EC2 et rendre la page web accessible sera détaillée dans la section suivante de la documentation.


## Deploiement via Terraform


### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~> 3.0 |
| <a name="requirement_local"></a> [local](#requirement\_local) | ~> 2.1 |

### Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 3.76.1 |
| <a name="provider_local"></a> [local](#provider\_local) | 2.4.1 |
| <a name="provider_tls"></a> [tls](#provider\_tls) | 4.0.5 |


### Resources

| Name | Type |
|------|------|
| [aws_instance.b3_gr3_debian_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_instance.b3_gr3_ubuntu_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_internet_gateway.b3_gr3_main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_key_pair.b3_gr3_ec2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/key_pair) | resource |
| [aws_route_table.b3_gr3_main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table) | resource |
| [aws_route_table_association.b3_gr3_public_subnet](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route_table_association) | resource |
| [aws_security_group.b3_gr3_ec2](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_subnet.b3_gr3_public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.b3_gr3_main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [local_file.b3_gr3_private_ssh_key](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file) | resource |
| [tls_private_key.b3_gr3_ssh_key](https://registry.terraform.io/providers/hashicorp/tls/latest/docs/resources/private_key) | resource |
| [aws_ami.b3_gr3_debian](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_ami.b3_gr3_ubuntu](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_availability_zones.b3_gr3_available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |


### Outputs

| Name | Description |
|------|-------------|
| <a name="output_debian_ssh_command"></a> [debian\_ssh\_command](#output\_debian\_ssh\_command) | SSH command to connect to the Debian instance |
| <a name="output_debian_website_url"></a> [debian\_website\_url](#output\_debian\_website\_url) | URL to access the Debian web server |
| <a name="output_ubuntu_ssh_command"></a> [ubuntu\_ssh\_command](#output\_ubuntu\_ssh\_command) | SSH command to connect to the Ubuntu instance |
| <a name="output_ubuntu_website_url"></a> [ubuntu\_website\_url](#output\_ubuntu\_website\_url) | URL to access the Ubuntu web server |
