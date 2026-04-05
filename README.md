# 📦 Projet-web-StockSmart

> Application web de gestion de stock pour la grande distribution (Auchan, Leclerc, Carrefour…)
> Site permettant d’enregistrer et d’organiser les produits par catégories. L’application affiche en temps réel les quantités disponibles en stock. Elle facilite la gestion des entrées lors des approvisionnements ainsi que des sorties liées aux ventes, pertes ou casses.

---

## 📋 Fonctionnalités

| Fonctionnalité | Statut |
|---|---|
| Page d’accueil publique | ✅ |
| Connexion / Déconnexion | ✅ || Inscription utilisateur | ✅ |
| Tableau de bord récapitulatif | ✅ || Affichage du total produits / catégories | ✅ |
| Suivi du stock faible et des ruptures | ✅ || Calcul de la valeur du stock | ✅ |
| Historique des derniers mouvements | ✅ || Produits en alerte | ✅ |
| Gestion des produits | ✅ || Gestion des catégories | ✅ || Gestion des mouvements | ✅ |
| Panneau d’administration | ✅ || Gestion des utilisateurs (admin) | ✅ || Gestion multi-rôles | ✅ |
| Sessions PHP sécurisées | ✅ |

---

## 🗂️ Structure du projet

```bash
stocksmart/
├── index.php                 # Page d’accueil publique
├── dashboard.php             # Tableau de bord après connexion
├── config.php                # Connexion PDO à la base de données
│
├── css/
│   └── style.css             # Feuille de style principale
│
├── JavaScript/
│   └── scrip.js              # Scripts front-end
│
├── pages/
│   ├── login.php             # Connexion utilisateur
│   ├── inscription.php       # Inscription utilisateur
│   ├── logout.php            # Déconnexion
│   ├── produits.php          # Gestion des produits
│   ├── categories.php        # Gestion des catégories
│   ├── mouvements.php        # Gestion des mouvements
│   └── admin.php             # Panneau d’administration
│
└── database/
    └── stocksmart.sql        # Schéma MySQL + données initiales
```

---

## ⚙️ Installation

### Prérequis
- PHP 8.x
- MySQL / MariaDB
- Apache (XAMPP conseillé)

### Étapes

**1. Copier le projet dans `htdocs`**
```bash
C:\xampp\htdocs\stocksmart
```
**2. Importer la base de données**
- Ouvrir phpMyAdmin
- Créer la base `stocksmartdb`
- Importer le fichier SQL du projet
**3. Configurer la connexion**

Modifier `config.php` :

```php
<?php
$host = 'localhost';
$dbname = 'stocksmartdb';
$username = 'root';
$password = '';

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname;charset=utf8mb4", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    die("Erreur de connexion : " . $e->getMessage());
}
?>
```

**4. Lancer le projet**
- Démarrer Apache et MySQL dans XAMPP
- Ouvrir dans le navigateur :

```txt
http://localhost/stocksmart/
```

---

## 🔑 Comptes de démonstration

| Email | Mot de passe | Rôle |
|---|---|---|
| rose@test.com | password | Admin |
| marie@test.com | password | Gérant |
| julie@test.com | password | Chef de rayon |
| karim@test.com | password | Magasinier |
| sophie@test.com | password | Caissier |

---

## 👥 Rôles disponibles

| Rôle |
|---|
| admin || gerant || chef_rayon || magasinier |
| caissier || employe || lecture |
| consultant |

---

## 🏷️ Catégories disponibles

Fruits et légumes · Boucherie / volaille · Charcuterie / traiteur · Poissonnerie · Crèmerie / produits laitiers · Épicerie salée · Épicerie sucrée · Petit-déjeuner · Boissons · Surgelés · Hygiène / beauté · Entretien maison · Bébé · Animalerie · Bazar / maison · Textile · Électroménager / multimédia · Papeterie / librairie

---

## 🔒 Sécurité

- Mots de passe hashés avec `password_hash()`
- Vérification avec `password_verify()`
- Sessions PHP
- Requêtes préparées PDO
- Protection des pages privées par session
- Accès à `admin.php` réservé au rôle `admin`

---

## 🛠️ Technologies

- **Front-end** : HTML5, CSS3, JavaScript
- **Back-end** : PHP
- **Base de données** : MySQL / MariaDB
- **Serveur local** : XAMPP
- **Accès BD** : PDO

---

## 📌 Remarques

- La page d’accueil est publique.
- Après connexion, l’utilisateur est redirigé vers `dashboard.php`.
- Le panneau `admin.php` est accessible uniquement aux administrateurs.
- La déconnexion se fait via `pages/logout.php`.

## 📌 Prochaines évolutions possibles

- [ ] Upload d'images produits (PHP `move_uploaded_file`)
- [ ] Export PDF des inventaires (TCPDF / DomPDF)
- [ ] Notifications email pour alertes stock (PHPMailer)
- [ ] Tableau de bord graphiques (Chart.js)
- [ ] API REST complète + application mobile
- [ ] Multi-magasins / dépôts
