# 🦷 OccluSense Cloud Suite

> **Système IoT & Cloud pour l'analyse de l'équilibre dentaire.**

Ce projet est une solution complète de monitoring dentaire. Il permet le contrôle instantané de l'occlusion après un soin en cabinet et le suivi nocturne du bruxisme à domicile.

## 🚀 Démo en ligne

Retrouvez l'application sécurisée ici : [https://occlusense.delphine.cloud](https://occlusense.delphine.cloud)

---

## 🛠️ Architecture & Technologies

Le projet repose sur une infrastructure **Serverless** hautement disponible et sécurisée sur AWS :

- **Frontend :** Web App interactive (HTML5, CSS3, JavaScript) avec data-visualisation des pressions occlusales.
- **Infrastructure as Code (IaC) :** Déploiement automatisé via **Terraform**.
- **Hébergement & CDN :** **AWS S3** pour le stockage statique et **CloudFront** pour la distribution mondiale.
- **Sécurité :** Certificat SSL (HTTPS) via **AWS Certificate Manager (ACM)**.
- **DNS :** Configuration de zone et sous-domaines via **OVH**.
- **Backend :** Simulation de données IoT avec **Python** et traitement via **AWS Lambda**.

## 📊 Fonctionnalités clés

- **Analyse au fauteuil :** Visualisation dynamique des points de contact dentaire après intervention.
- **Suivi du Bruxisme :** Graphiques de tendance pour le monitoring nocturne de la pression dentaire.
- **Sécurité des données :** Architecture isolée et accès sécurisé via OAC (Origin Access Control).

## 📂 Structure du projet

- `/infrastructure` : Scripts Terraform (.tf) pour l'automatisation AWS.
- `/Picture` : Assets graphiques et vidéo de démonstration.
- `index.html` : Interface utilisateur principale.
- `occlusion_simulator.py` : Script Python simulant les données de capteurs IoT.

---

## 🔧 Installation locale (Développeurs)

1. Cloner le projet :
   ```bash
   git clone [https://github.com/Delphi-cloud-beep/gouttiere-connectee-cloud.git](https://github.com/Delphi-cloud-beep/gouttiere-connectee-cloud.git)
   ```
