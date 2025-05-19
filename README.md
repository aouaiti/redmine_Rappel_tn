# Suivi Budgétaire / Budget Tracking for Redmine

Un plugin professionnel pour la gestion des budgets dans Redmine. Conçu spécifiquement pour le contexte tunisien, avec le dinar tunisien (TND) comme devise par défaut et une interface en français.

## Fonctionnalités

- Gestion complète des budgets pour les projets Redmine
- Suivi des coûts avec prise en charge de plusieurs types de dépenses
- Création de budgets avec des éléments détaillés
- Organisation des éléments budgétaires par catégories
- Liaison des éléments budgétaires avec les demandes Redmine
- Suivi automatique du temps passé et calcul des coûts
- Rapports détaillés sur l'utilisation du budget
- Exportation des données en CSV et Excel
- Interface utilisateur moderne avec graphiques et visualisations
- Entièrement traduit en français
- Supporte le Dinar Tunisien (TND) par défaut

## Installation

1. Clonez ce dépôt dans le répertoire `plugins` de votre installation Redmine:
   ```bash
   cd /chemin/vers/redmine/plugins
   git clone https://github.com/votre-compte/redmine_budget_tn.git
   ```

2. Installez les dépendances si nécessaire:
   ```bash
   bundle install
   ```

3. Exécutez les migrations de la base de données:
   ```bash
   rake redmine:plugins:migrate NAME=redmine_budget_tn RAILS_ENV=production
   ```

4. Redémarrez votre serveur Redmine.

5. Configurez les permissions pour les rôles dans Administration > Rôles et permissions.

## Utilisation

1. Activez le module "Budget" dans les paramètres de votre projet.
2. Accédez à l'onglet "Budgets" dans votre projet.
3. Créez un nouveau budget et ajoutez des éléments budgétaires.
4. Suivez vos dépenses et visualisez les rapports.

## Configuration

Vous pouvez configurer le plugin dans Administration > Plugins > Suivi Budgétaire:

- Devise par défaut (TND par défaut)
- Format d'affichage des montants
- Taux horaire par défaut
- Autres paramètres avancés

## Compatibilité

- Redmine 4.2.0 ou supérieur
- Ruby 2.5.0 ou supérieur
- Base de données: MySQL/MariaDB, PostgreSQL, SQLite

## Licence

Ce plugin est publié sous licence MIT.

## Auteur

Développé par Claude pour répondre aux besoins spécifiques de suivi budgétaire dans le contexte tunisien.

## Support

Pour toute question ou demande de support, veuillez ouvrir une issue sur GitHub ou contacter l'auteur. 