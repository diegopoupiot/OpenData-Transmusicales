# Application Transmusicales OpenData

Application multi-plateforme développée avec Flutter permettant d'explorer les données OpenData des Transmusicales de Rennes.

## 👥 Équipe
- Elouan B.
- Diego P.

## 📱 Fonctionnalités Principales

- Liste d'exploration des artistes
- Carte interactive avec informations géographiques
- Profils détaillés des artistes avec historique des performances
- Intégration Spotify et Deezer
- Système de notation et commentaires
- Mode jour/nuit
- Système d'authentification

## 🚀 Fonctionnalités Optionnelles

- Liste paginée avec recherche et filtres multicritères
- Galerie photos par artiste
- Système de favoris
- Synchronisation multi-appareils
- Tests unitaires, d'intégration et UI

## 🛠 Technologies Utilisées

- **Frontend:** Flutter (Mobile & Web)
- **Backend:** 
  - Firebase (Authentification)
  - API REST (Données OpenData)
- **Source de données:** Dataset Transmusicales de Rennes Métropole

## 🏗 Architecture

Le projet suit les principes de la Clean Architecture pour assurer :
- Une séparation claire des responsabilités
- Une maintenabilité optimale
- Une testabilité facilitée

## 📊 Source des Données

Les données sont issues du dataset officiel des Transmusicales disponible sur :
[data.rennesmetropole.fr](https://data.rennesmetropole.fr/explore/dataset/artistes_concerts_transmusicales/information/)

## 🔍 Critères de Qualité

- Respect strict des principes de la Clean Architecture
- Performance optimisée pour large volume de données
- Code documenté et maintenu selon les conventions
- Interface utilisateur intuitive et responsive
- Tests complets (si option choisie)

## 🚀 Installation

1. Cloner le repository
2. Installer les dépendances : `flutter pub get`
3. Lancer l'application : `flutter run`