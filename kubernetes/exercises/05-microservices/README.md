## Objectif:
Créer une application web avec plusieurs microservices et exposer ces services via un seul Ingress, en utilisant des chemins d'URL différents pour chaque service.

#### 1. Tâches:

Créer plusieurs Déploiements:

Déployer trois applications Node.js distinctes :
Un service "frontend" qui sert une page HTML de base.
Un service "api" qui fournit une API REST simple (a vous de la definir).
Un service "admin" qui contient une interface d'administration sécurisée.

#### 2. Créer des Services:

Exposer chacun des services via un Service de type ClusterIP.
Créer un Ingress:

Configurer un Ingress pour router le trafic HTTP vers les différents services en fonction des chemins d'URL :
/ : route vers le service "frontend"
/api : route vers le service "api"
/admin : route vers le service "admin"

#### 3. Tester:

Accéder à chaque service en utilisant les chemins d'URL correspondants.

#### 4. Securiser:

Ajouter une authentification pour la partie admin.


