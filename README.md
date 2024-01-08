# Packer et Azure : Créer des Images de VM sur Mesure

Ce guide détaille la création d'images de machine virtuelle personnalisées dans Azure en utilisant Packer. Il couvre l'installation de Packer, la configuration d'un principal de service Azure pour l'authentification, et la construction de l'image avec Packer.
À la fin, nous testerons l'image créée en effectuant un déploiement avec Terraform, pour vérifier qu' elle fonctionne comme prévu dans un environnement Azure.


## Prérequis

Avant de commencer, assurez-vous que les outils suivants sont installés :
- Packer
- Azure CLI

## Installation de Packer

Packer peut être téléchargé et installé à partir de [la page officielle de Packer](https://www.packer.io/downloads). Suivez les instructions pour votre système d'exploitation.

## Installation du Plugin Azure pour Packer

Après l'installation de Packer, installez le plugin Azure en exécutant :

```shell
packer plugins install github.com/hashicorp/azure
```


## Création d'un Principal de Service Azure
Pour permettre à Packer de s'authentifier auprès d'Azure, créez un principal de service en utilisant Azure CLI :

```shell
az ad sp create-for-rbac --name "<sp_name>" --role Contributor --scopes /subscriptions/<subscription_id>/resourceGroups/<resource_group_name> --query "{ client_id: appId, client_secret: password, tenant_id: tenant }"
```
Un exemple de sortie pour cette commande est :

```json
{
    "client_id": "<client_id>",
    "client_secret": "<client_secret>",
    "tenant_id": "<tenant_id>"
}
```

## Obtention de l'ID d'Abonnement Azure
Pour compléter les informations d'identification, obtenez votre ID d'abonnement Azure :

```shell
az account show --query "{ subscription_id: id }"
```


## Packer Configuration - `image.json`

Le fichier `image.json` est utilisé pour définir la configuration pour créer une image personnalisée dans Azure avec Packer. Voici une explication détaillée de chaque section :


### Builders
- **Type**: `azure-arm` indique que le builder Azure Resource Manager est utilisé.
- **Credentials**: Utilise les informations d'identification Azure (`client_id`, `client_secret`, `subscription_id`, `tenant_id`) pour authentifier et autoriser les opérations dans Azure.
- **Resource Group**: Utilise `build_resource_group_name` et `managed_image_resource_group_name` pour spécifier le groupe de ressources où l'image sera construite et stockée (`b3-gr3`).
- **Image Configuration**: Définit les spécifications de l'image de base (éditeur, offre, SKU) pour Ubuntu 22.04 LTS.
- **Tags**: Tags Azure pour catégoriser la ressource créée.
- **VM Size**: La taille de la machine virtuelle utilisée pour construire l'image (`Standard_DS2_v2`).


### Provisioners
- **Shell**: Exécute des commandes pour mettre à jour le système, installer et démarrer Nginx.
- **File**: Transfère le fichier `index.html` de la machine locale à la machine virtuelle Azure.
- **Shell**: Déplace `index.html` dans le répertoire web et ajuste les permissions.


## Fichier `index.html`

Le fichier `index.html` est une page web simple qui fournit des informations sur les ressources DevOps et des définitions pour des outils comme Packer et Azure Key Vault. Il inclut des liens vers des ressources utiles et des descriptions pour aider les visiteurs à comprendre ces technologies.

## Construction de l'Image avec Packer

Pour construire l'image avec Packer, assurez-vous d'être dans le répertoire de travail où se trouve votre fichier `image.json` . Exécutez ensuite la commande suivante :

```shell
sudo packer build image.json
```

Cette commande déclenchera le processus de construction de l'image dans Azure en utilisant la configuration spécifiée dans `image.json`.

Une fois la construction de l'image terminée, elle sera stockée dans le groupe de ressources spécifié dans votre fichier `image.json`, sous la section `managed_image_resource_group_name`. Cela assure une organisation adéquate et une gestion facile de votre image personnalisée dans Azure. Elle est désormais prête à être utilisée pour déployer des machines virtuelles, que ce soit via Terraform ou d'autres outils de gestion d'infrastructures.

La page web contenue dans cette image personnalisée, définie dans le fichier "index.html", est conçue pour être accessible via un navigateur après le déploiement de la machine virtuelle dans Azure. La configuration Terraform pour déployer cette machine virtuelle et rendre la page web accessible est décrite dans la section suivante.



<!-- BEGIN_TF_DOCS -->
## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.86.0 |


## Resources

| Name | Type |
|------|------|
| [azurerm_linux_virtual_machine.b3-gr3_vm](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine) | resource |
| [azurerm_network_interface.b3-gr3_nic](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
| [azurerm_network_interface_security_group_association.b3-gr3_nic_nsg_association](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_security_group_association) | resource |
| [azurerm_network_security_group.b3-gr3_nsg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_network_security_rule.b3-gr3_http](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_rule) | resource |
| [azurerm_public_ip.b3-gr3_public_ip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_subnet.b3-gr3_snet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_virtual_network.b3-gr3_vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |


## Outputs

| Name | Description |
|------|-------------|
| <a name="output_public_ip_fqdn"></a> [public\_ip\_fqdn](#output\_public\_ip\_fqdn) | The fully qualified domain name (FQDN) of the VM |
<!-- END_TF_DOCS -->
