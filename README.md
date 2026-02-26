# TP3 - Weather Data Aggregator

## 🎓 Contexte

Ce projet a été réalisé dans le cadre du **Master 2 Informatique -
Ynov**,\
durant le module **Swift - Concepts avancés et concurrence**.

Il s'agit du **TP3**, portant sur : - La concurrence en Swift
(async/await) - Les Task Groups - Les Actors pour la sécurité des
données (thread safety) - La gestion d'erreurs asynchrones - Les appels
API REST et le décodage JSON

------------------------------------------------------------------------

## 🎯 Objectif du TP

Créer une application **CLI (Command Line Interface)** capable de :

-   Récupérer les données météo de 10 villes en parallèle
-   Interroger l'API Open-Meteo (gratuite, sans authentification)
-   Mettre en place un cache thread-safe avec un `actor`
-   Calculer des statistiques (moyenne, min, max, succès/échecs)
-   Mesurer le temps total d'exécution

------------------------------------------------------------------------

## 🛠 Technologies utilisées

-   Swift 5.9+
-   async / await
-   TaskGroup
-   Actor
-   Codable
-   URLSession (via wrapper cross-platform fourni)

------------------------------------------------------------------------

## 🚀 Lancer le projet

### 1️⃣ Cloner le repository

``` bash
git clone git@github.com:HugoD66/Swift_Module_3.git
cd TP3_WeatherAPI_Starter
```

### 2️⃣ Compiler

``` bash
swift build
```

### 3️⃣ Exécuter

``` bash
swift run
```

------------------------------------------------------------------------

## 📦 Fonctionnement de l'application

Au lancement, le programme :

1.  Initialise une liste de 10 villes (Paris, London, Tokyo, etc.)
2.  Lance les requêtes HTTP en parallèle grâce à `withTaskGroup`
3.  Vérifie le cache avant chaque appel API
4.  Met en cache les résultats obtenus
5.  Affiche :
    -   La météo de chaque ville
    -   Le nombre de succès / échecs
    -   La température moyenne, minimale et maximale
    -   Les statistiques du cache (hits / misses)
    -   Le temps total d'exécution

------------------------------------------------------------------------

## 📊 Exemple de sortie

    === Agrégateur de données météo ===

    Récupération des données météo pour 10 villes...

    ✓ Paris : 12.3°C | Vent : 15.2 km/h
    ✓ London : 10.5°C | Vent : 18.7 km/h
    ...

    === Statistiques ===
    Villes totales : 10
    Succès : 10
    Échecs : 0
    Température moyenne : 14.5°C
    Plus chaud : Dubai (28.5°C)
    Plus froid : Moscow (-2.3°C)

    === Cache ===
    Hits : 0
    Misses : 10
    Taux de hit : 0.0%

    Temps d'exécution : 1.23s

------------------------------------------------------------------------

## 📚 Concepts abordés

-   Programmation concurrente en Swift
-   Structured Concurrency
-   Isolation des données avec `actor`
-   Gestion des erreurs personnalisées
-   Décodage JSON avec `Codable`
-   Architecture simple en plusieurs fichiers
