echo "Bienvenue dans le monde de la mise en prod magique d'un projet Astro"
echo "Pense à bien configurer le nom de domaine pour le certificat SSL !"
read -p "Tu l'as fait  (la bonne réponse est:   oui  , le processus s'arrête ici.) ? " CONFIRM
if [ "$CONFIRM" != "oui" ]; then
    echo "Dommage, reviens plus tard !"
    exit 1
fi
# Demande nom du dossier parent Projet -p Attente de reponse
read -p "Indique moi le nom du dossier parent de ton projet: " PROJECT
#Verification existance projet
if [ ! -d "/var/www/html/$PROJECT" ]; then
    echo "Dommage nous ne trouvons pas votre projet !"
    exit 1
else
    # Verification existance projet build
    if [ -d "/var/www/html/$PROJECT/dist" ]; then
        echo "Super ! Tout est en ordre pour ton projet!"
    #Build projet
    else 
        echo "Ton projet n'est pas Build, mais ne t'inquiètes pas! Je m'en occupe !"
        cd "/var/www/html/$PROJECT"
        yarn run build
        if [ ! -d "/var/www/html/$PROJECT/dist" ]; then
            echo "Oula ! Verifie ton projet ..."
            exit 1
        else
            echo "Super ! Continuons ... "
        fi
    fi
    #Verification existance .env.deploy du projet
    if [ ! -f "/var/www/html/$PROJECT/.env.deploy" ]; then
        echo "Oups ! Pas de fichier de déploiement !"
        exit 1
    else
        source /var/www/html/$PROJECT/.env.deploy
    fi
    #Verification remplissage variable .env.deploy
    if [ -z "$USER" ]; then
        echo "Oups, vérifie que la variable USER soit bien remplie."
        exit 1
    fi
    if [ -z "$SERVER" ]; then
        echo "Oups, vérifie que la variable SERVER soit bien remplie."
        exit 1
    fi
    if [ -z "$TARGET" ]; then
        echo "Oups, vérifie que la variable TARGET soit bien remplie."
        exit 1
    fi
    if [ -z "$TARGETLC" ]; then
        echo "Oups, vérifie que la variable TARGETLC soit bien remplie."
        exit 1
    fi
    if [ -z "$DOMAIN" ]; then
        echo "Oups, vérifie que la variable DOMAIN soit bien remplie."
        exit 1
    fi
    echo "Super ! On envoie la sauce sur le serveur !"
    #Transfert fichiers sur le serveur
    scp -r /var/www/html/$PROJECT/dist/* $USER@$SERVER:~/temp
    ssh $USER@$SERVER << EOF
    echo "Transfert: OK Connexion: OK !"
    #Transfert projet dans dossier apache
    if [ ! -d /var/www/html/$TARGET ]; then
        sudo mkdir /var/www/html/$TARGET
        sudo mv ~/temp/* /var/www/html/$TARGET
    else
        sudo rm -r /var/www/html/$TARGET/*
        sudo mv ~/temp/* /var/www/html/$TARGET
    fi
    echo "Les fichiers sont dans la place !"
    #Creation de la configuration apache
    if [ ! -f /etc/apache2/sites-available/$DOMAIN.conf ]; then
        echo "Configuration du port:80 !"
        sudo bash -c 'cat <<EOT > /etc/apache2/sites-available/$DOMAIN.conf                          
<VirtualHost *:80>
    ServerName $DOMAIN

    DocumentRoot /var/www/html/$TARGET
    <Directory /var/www/html/$TARGET>
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/$TARGETLC_error.log
    CustomLog ${APACHE_LOG_DIR}/$TARGETLC_access.log combined
RewriteEngine on
RewriteCond %{SERVER_NAME} =$DOMAIN
RewriteRule ^ https://%{SERVER_NAME}%{REQUEST_URI} [END,NE,R=permanent]
</VirtualHost>
EOT'
        echo "Apache configuré ! Activation... Redémarrage..!"
        sudo a2ensite $DOMAIN.conf
        sudo systemctl reload apache2
        echo "Certification SSL en approche !"
        sudo certbot --apache -d $DOMAIN
        sudo sed -i '/<\/Directory>/a     ErrorDocument 404 /404.html' /etc/apache2/sites-available/$DOMAIN-le-ssl.conf
    fi
    sudo systemctl reload apache2
    echo "Felicitations !!! Le projet est sur la toile !!!"
EOF
fi
