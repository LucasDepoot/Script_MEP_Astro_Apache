# Script de mise en ligne d'un projet Astro sur un serveur Apache
## Objectif
Ce script permet de déployer un projet **Astro** sur un serveur **Apache**. Il effectue l'ensemble du processus de transfert des fichiers sur le serveur, de création des configurations nécessaires (VirtualHost), et d'installation du certificat SSL via **Certbot**.

## Prérequis
Avant d'utiliser le script, voici les étapes de préparation à suivre :

1. **Configurer le DNS** :
   - Assurez-vous que votre nom de domaine est bien configuré pour pointer vers l'adresse IP de votre serveur.
   - Exemple : `exemple.com` doit pointer vers votre serveur Apache.

2. **Configurer le fichier `.env.deploy`** :
   - À la racine de votre projet Astro, créez un fichier nommé `.env.deploy`.
   - Ce fichier doit contenir les variables suivantes :
     ```env
     USER=serverUser
     SERVER=serverName
     TARGET=NameDirectoryInApache
     TARGETLC=namedirectorylowercase
     DOMAIN=exemple.com
     ```
   - Remplacez `serverUser`, `serverName`, `NameDirectoryInApache`, `namedirectorylowercase`, et `exemple.com` par les valeurs appropriées pour votre serveur.

3. **Dossier temp sur le serveur** :
    - Le script utilise un dossier temp à la racine de votre serveur pour stocker les fichiers temporairement avant leur transfert vers le répertoire final.
    - Assurez-vous que ce dossier existe sur votre serveur, ou modifiez les chemins dans le script pour les adapter à votre configuration.

4. **Build du projet (facultatif) :** :
    - Le script vérifie si votre projet est déjà compilé dans le dossier dist. Si ce n'est pas le cas, le script lancera automatiquement la commande yarn run build pour le faire.
    - Il n'est donc pas nécessaire de construire le projet à l'avance, sauf si vous avez des configurations personnalisées spécifiques.

## Utilisation du script

1. Téléchargez le script sur votre machine locale où se trouve votre projet Astro.
2. Exécutez le script sur votre machine locale en SSH. Utilisez la commande suivante depuis le répertoire contenant le script : ./mepAstro.sh
3. Répondez aux questions : Le script vous posera plusieurs questions pour s'assurer que les éléments nécessaires sont présents avant de continuer :

    - Nom du dossier parent du projet : Le script vérifiera que ce dossier existe.
    - Vérification de la compilation du projet : Si votre projet n'est pas compilé, le script lancera automatiquement la commande yarn run build.
    - Fichier .env.deploy : Le script vérifiera la présence du fichier .env.deploy et s'assurera que les variables nécessaires sont bien remplies.
4. Le script exécute les actions suivantes :

    - Transfert des fichiers dist sur votre serveur via SCP.
    - Création et configuration automatique du VirtualHost Apache pour votre projet.
    - Installation automatique du certificat SSL avec Certbot.
    - Déploiement des fichiers sur le serveur.

Le script vérifiera toutes les étapes avant de les exécuter, pour s'assurer que tout est prêt pour le déploiement.

5. Vérification du déploiement : Après le déploiement, vous pouvez vérifier que votre projet est bien en ligne en accédant à votre nom de domaine.


## À noter

- Le script est conçu pour être simple et rapide à utiliser, mais il est important de vérifier que toutes les configurations sont correctement remplies avant de l'exécuter.
- Il est aussi possible d'ajouter des options ou des confirmations supplémentaires selon vos besoins.
- Assurez-vous d'avoir un serveur configuré avec Apache, Certbot, et que le domaine est correctement configuré pour recevoir le certificat SSL.
- Vérifiez que le dossier temp existe à la racine du serveur ou ajustez les chemins dans le script selon votre configuration.