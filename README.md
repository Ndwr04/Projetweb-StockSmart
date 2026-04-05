# 📦 Projet-web-StockSmart

> Application web de gestion de stock pour la grande distribution (Auchan, Leclerc, Carrefour…)
> Site permettant d’enregistrer et d’organiser les produits par catégories. L’application affiche en temps réel les quantités disponibles en stock. Elle facilite la gestion des entrées lors des approvisionnements ainsi que des sorties liées aux ventes, pertes ou casses.

---

## 📋 Fonctionnalités

| Fonctionnalité | Statut |
|---|---|
| Connexion / Déconnexion | ✅ |
| Inscription employé (public) | ✅ |
| Tableau de bord récapitulatif | ✅ |
| Gestion des produits (CRUD) | ✅ |
| 18 catégories grande distribution | ✅ |
| Entrées / Sorties de stock | ✅ |
| Seuil d'alerte configurable | ✅ |
| Historique des mouvements | ✅ |
| Alertes stock faible | ✅ |
| Gestion des utilisateurs (admin) | ✅ |
| 7 rôles avec permissions | ✅ |
| Recherche & filtres | ✅ |
| Export CSV | ✅ |
| Upload image produit | ✅ |

---

## 🗂️ Structure du projet

```
stockmaster/
├── index.html              # Application principale (dashboard)
├── login.html              # Page de connexion
├── register.html           # Page d'inscription
│
├── css/
│   └── style.css           # Design system complet
│
├── js/
│   └── app.js              # Logique front-end (navigation, rendu, CRUD)
│
├── config/
│   └── database.php        # Connexion PDO MySQL
│
├── auth/
│   ├── login.php           # API connexion
│   ├── register.php        # API inscription
│   └── logout.php          # Déconnexion
│
├── api/
│   ├── produits.php        # CRUD produits (REST)
│   ├── mouvements.php      # Entrées/Sorties stock
│   ├── categories.php      # CRUD catégories
│   └── utilisateurs.php   # Gestion utilisateurs (admin)
│
└── database/
    └── schema.sql          # Schéma MySQL complet + données initiales
```

---

## ⚙️ Installation

### Prérequis
- PHP ≥ 8.0
- MySQL ≥ 8.0
- Serveur web : Apache (XAMPP/WAMP) ou Nginx

### Étapes

**1. Importer la base de données**
```sql
mysql -u root -p < database/schema.sql
```

**2. Configurer la connexion**

Modifier `config/database.php` :
```php
define('DB_HOST', 'localhost');
define('DB_NAME', 'stockmaster');
define('DB_USER', 'votre_user');
define('DB_PASS', 'votre_password');
```

**3. Démarrer le serveur**
```bash
# Avec PHP built-in (dev)
php -S localhost:8000

# Ou placer dans htdocs/ (XAMPP)
# Puis ouvrir http://localhost/stockmaster/
```

---

## 🔑 Comptes de démonstration

| Email | Mot de passe | Rôle |
|---|---|---|
| rose@test.com | password | 👑 Administrateur |
| marc@test.com | password | 📊 Gérant |
| julie@test.com | password | 🏷️ Chef de rayon |
| karim@test.com | password | 📦 Magasinier |
| sophie@test.com | password | 🛒 Caissier |

---

## 👥 Rôles et permissions

| Rôle | Dashboard | Produits | Mouvements | Admin users |
|---|---|---|---|---|
| **admin** | ✅ | ✅ RW | ✅ RW | ✅ |
| **gérant** | ✅ | ✅ RW | ✅ RW | Partiel |
| **chef_rayon** | ✅ | ✅ RW | ✅ RW | ❌ |
| **magasinier** | ✅ | ✅ RW | ✅ RW | ❌ |
| **caissier** | ✅ | 👁️ R | Sorties seult. | ❌ |
| **employé** | ✅ | 👁️ R | ❌ | ❌ |
| **consultant** | ✅ | 👁️ R | 👁️ R | ❌ |

---

## 🏷️ Catégories disponibles

Fruits & Légumes · Boucherie/Volaille · Charcuterie/Traiteur · Poissonnerie · Produits Laitiers · Épicerie Salée · Épicerie Sucrée · Petit-déjeuner · Boissons · Surgelés · Hygiène/Beauté · Entretien Maison · Bébé · Animalerie · Bazar/Maison · Textile · Électroménager/Multimédia · Papeterie/Librairie

---

## 🔒 Sécurité

- Mots de passe hashés avec `password_hash()` (BCrypt)
- Sessions PHP sécurisées
- Requêtes préparées PDO (protection SQL injection)
- Validation des entrées côté serveur
- Vérification des rôles sur chaque endpoint API
- Inscription publique limitée au rôle `employe`
- Promotion de rôle réservée aux `admin`

---

## 🛠️ Technologies

- **Front-end** : HTML5, CSS3, JavaScript ES6+
- **Back-end** : PHP 8.x
- **Base de données** : MySQL 8.x (PDO)
- **Polices** : Syne (titres) + DM Sans (texte)
- **Pas de framework** — code vanilla léger et maintenable

---

## 📌 Prochaines évolutions possibles

- [ ] Upload d'images produits (PHP `move_uploaded_file`)
- [ ] Export PDF des inventaires (TCPDF / DomPDF)
- [ ] Notifications email pour alertes stock (PHPMailer)
- [ ] Tableau de bord graphiques (Chart.js)
- [ ] API REST complète + application mobile
- [ ] Multi-magasins / dépôts
