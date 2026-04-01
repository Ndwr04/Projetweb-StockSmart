CREATE DATABASE IF NOT EXISTS stocksmartdb
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_general_ci;

USE stocksmartdb;

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS mouvements;
DROP TABLE IF EXISTS produits;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS utilisateurs;

SET FOREIGN_KEY_CHECKS = 1;

-- ============================
-- TABLE UTILISATEURS
-- ============================
CREATE TABLE utilisateurs (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(100) NOT NULL,
    prenom VARCHAR(100) DEFAULT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    mot_de_passe VARCHAR(255) DEFAULT NULL,
    password VARCHAR(255) DEFAULT NULL,
    role ENUM(
        'admin',
        'gerant',
        'chef_rayon',
        'magasinier',
        'caissier',
        'employe',
        'lecture',
        'consultant'
    ) NOT NULL DEFAULT 'employe',
    actif TINYINT(1) NOT NULL DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_role (role),
    INDEX idx_actif (actif)
) ENGINE=InnoDB;

-- ============================
-- TABLE CATEGORIES
-- ============================
CREATE TABLE categories (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(100) NOT NULL UNIQUE,
    emoji VARCHAR(10) DEFAULT '📦',
    couleur VARCHAR(7) DEFAULT '#3b82f6',
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ============================
-- TABLE PRODUITS
-- ============================
CREATE TABLE produits (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    reference VARCHAR(50) NOT NULL UNIQUE,
    nom VARCHAR(200) NOT NULL,
    categorie_id INT UNSIGNED NOT NULL,
    fournisseur VARCHAR(150) DEFAULT NULL,
    prix DECIMAL(10,2) DEFAULT 0.00,
    prix_unitaire DECIMAL(10,2) DEFAULT 0.00,
    unite ENUM('unité','kg','L','pack','carton') DEFAULT 'unité',
    quantite INT NOT NULL DEFAULT 0,
    stock INT NOT NULL DEFAULT 0,
    seuil_alerte INT NOT NULL DEFAULT 10,
    image VARCHAR(255) NOT NULL DEFAULT 'images/produits/no-image.jpg',
    image_url VARCHAR(255) DEFAULT NULL,
    image_emoji VARCHAR(10) DEFAULT '📦',
    description TEXT,
    actif TINYINT(1) DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (categorie_id) REFERENCES categories(id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,
    INDEX idx_categorie (categorie_id),
    INDEX idx_stock (stock),
    INDEX idx_quantite (quantite),
    INDEX idx_seuil (seuil_alerte),
    INDEX idx_actif (actif)
) ENGINE=InnoDB;

-- ============================
-- TABLE MOUVEMENTS
-- ============================
CREATE TABLE mouvements (
    id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    produit_id INT UNSIGNED NOT NULL,
    utilisateur_id INT UNSIGNED DEFAULT NULL,
    user_id INT UNSIGNED DEFAULT NULL,
    type_mouvement ENUM('entree','vente','perte','casse','sortie') NOT NULL,
    type ENUM('entree','sortie') DEFAULT NULL,
    quantite INT NOT NULL,
    stock_avant INT DEFAULT NULL,
    stock_apres INT DEFAULT NULL,
    motif ENUM(
        'approvisionnement',
        'vente',
        'perte_peremption',
        'casse',
        'retour_fournisseur',
        'inventaire_regularisation',
        'transfert',
        'perte'
    ) DEFAULT 'approvisionnement',
    reference_doc VARCHAR(100) DEFAULT NULL,
    date_mouvement DATETIME DEFAULT CURRENT_TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    commentaire TEXT,
    FOREIGN KEY (produit_id) REFERENCES produits(id)
        ON UPDATE CASCADE
        ON DELETE CASCADE,
    FOREIGN KEY (utilisateur_id) REFERENCES utilisateurs(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,
    FOREIGN KEY (user_id) REFERENCES utilisateurs(id)
        ON UPDATE CASCADE
        ON DELETE SET NULL,
    INDEX idx_produit (produit_id),
    INDEX idx_user (utilisateur_id),
    INDEX idx_user2 (user_id),
    INDEX idx_type (type_mouvement),
    INDEX idx_date (date_mouvement)
) ENGINE=InnoDB;

-- ============================
-- TRIGGER STOCK AUTO
-- ============================
DELIMITER $$

CREATE TRIGGER after_mouvement_insert
AFTER INSERT ON mouvements
FOR EACH ROW
BEGIN
    IF NEW.type_mouvement = 'entree' THEN
        UPDATE produits
        SET stock = stock + NEW.quantite,
            quantite = quantite + NEW.quantite
        WHERE id = NEW.produit_id;
    ELSE
        UPDATE produits
        SET stock = stock - NEW.quantite,
            quantite = quantite - NEW.quantite
        WHERE id = NEW.produit_id;
    END IF;
END$$

DELIMITER ;

-- ============================
-- UTILISATEURS
-- ============================
INSERT INTO utilisateurs (nom, prenom, email, mot_de_passe, password, role, actif) VALUES
('Pretty', 'Rokia', 'rose@test.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '$2y$12$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'admin', 1),
('Dupont', 'Marie', 'marie@test.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '$2y$12$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'gerant', 1),
('Dupont', 'Julie', 'julie@test.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '$2y$12$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'chef_rayon', 1),
('Stock', 'Karim', 'karim@test.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '$2y$12$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'magasinier', 1),
('Caisse', 'Sophie', 'sophie@test.com', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', '$2y$12$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'caissier', 1);

-- ============================
-- CATEGORIES
-- ============================
INSERT INTO categories (id, nom, emoji, couleur, description) VALUES
(1, 'Fruits et légumes', '🥦', '#10b981', 'Produits frais de fruits et légumes'),
(2, 'Boucherie / volaille', '🥩', '#ef4444', 'Viandes rouges, blanches et volailles'),
(3, 'Charcuterie / traiteur', '🍖', '#f59e0b', 'Produits de charcuterie et traiteur'),
(4, 'Poissonnerie', '🐟', '#3b82f6', 'Poissons, crustacés et fruits de mer'),
(5, 'Crèmerie / produits laitiers', '🥛', '#8b5cf6', 'Lait, yaourts, fromages et crèmes'),
(6, 'Épicerie salée', '🧂', '#f97316', 'Pâtes, riz, conserves, sauces salées'),
(7, 'Épicerie sucrée', '🍫', '#ec4899', 'Biscuits, confiseries, chocolat'),
(8, 'Petit-déjeuner', '☕', '#a16207', 'Café, thé, céréales, boissons chaudes'),
(9, 'Boissons', '🥤', '#0ea5e9', 'Eaux, sodas, jus et boissons diverses'),
(10, 'Surgelés', '🧊', '#06b6d4', 'Produits congelés et surgelés'),
(11, 'Hygiène / beauté', '🧴', '#d946ef', 'Soins, hygiène corporelle et beauté'),
(12, 'Entretien maison', '🧹', '#64748b', 'Produits ménagers et entretien'),
(13, 'Bébé', '👶', '#f472b6', 'Produits destinés aux bébés'),
(14, 'Animalerie', '🐾', '#84cc16', 'Alimentation et soins pour animaux'),
(15, 'Bazar / maison', '🏠', '#78716c', 'Articles divers pour la maison'),
(16, 'Textile', '👕', '#6366f1', 'Vêtements et linge'),
(17, 'Électroménager / multimédia', '📱', '#334155', 'Appareils électriques et multimédia'),
(18, 'Papeterie / librairie', '📚', '#b45309', 'Fournitures scolaires et livres');

-- ============================
-- INSERT PRODUITS
-- ============================
INSERT INTO produits
(id, reference, nom, categorie_id, fournisseur, prix, prix_unitaire, unite, quantite, stock, seuil_alerte, image, image_url, image_emoji, description, actif)
VALUES
(1, 'F001', 'Pommes Golden 1kg', 1, 'Ferme Dupont', 2.99, 2.99, 'kg', 18, 18, 6, 'images/produits/pommes-golden.jpg', NULL, '🍎', 'Pommes golden fraîches', 1),
(2, 'F002', 'Bananes 1kg', 1, 'Banana Corp', 1.79, 1.79, 'kg', 25, 25, 8, 'images/produits/bananes.jpg', NULL, '🍌', 'Bananes mûres', 1),
(3, 'F003', 'Carottes 1kg', 1, 'Ferme Bio', 1.20, 1.20, 'kg', 30, 30, 10, 'images/produits/carottes.jpg', NULL, '🥕', 'Carottes fraîches', 1),
(4, 'F004', 'Salade verte', 1, 'Maraîcher Local', 1.50, 1.50, 'unité', 15, 15, 5, 'images/produits/salade.jpg', NULL, '🥬', 'Salade verte fraîche', 1),
(5, 'F005', 'Tomates 500g', 1, 'Maraîcher Local', 2.20, 2.20, 'kg', 12, 12, 4, 'images/produits/tomates.jpg', NULL, '🍅', 'Tomates juteuses', 1),
(6, 'F006', 'Pommes de terre 2kg', 1, 'Ferme Dupont', 2.49, 2.49, 'kg', 40, 40, 15, 'images/produits/pommes-terre.jpg', NULL, '🥔', 'Pommes de terre sachet 2kg', 1),
(7, 'F007', 'Courgettes 1kg', 1, 'Ferme Bio', 2.10, 2.10, 'kg', 8, 8, 3, 'images/produits/courgettes.jpg', NULL, '🥒', 'Courgettes fraîches', 1),
(8, 'F008', 'Oignons 1kg', 1, 'Ferme Dupont', 1.80, 1.80, 'kg', 22, 22, 7, 'images/produits/oignons.jpg', NULL, '🧅', 'Oignons jaunes', 1),
(9, 'F009', 'Ail 250g', 1, 'Ferme Bio', 1.90, 1.90, 'kg', 35, 35, 12, 'images/produits/ail.jpg', NULL, '🧄', 'Ail frais', 1),
(10, 'F010', 'Citrons 1kg', 1, 'Agrumes Sud', 3.20, 3.20, 'kg', 14, 14, 5, 'images/produits/citrons.jpg', NULL, '🍋', 'Citrons jaunes', 1),

(11, 'V001', 'Escalopes poulet 1kg', 2, 'Boucherie Martin', 7.50, 7.50, 'kg', 10, 10, 4, 'images/produits/escalopes-poulet.jpg', NULL, '🍗', 'Escalopes de poulet fraîches', 1),
(12, 'V002', 'Steak haché 20%', 2, 'Maison Bouvet', 6.90, 6.90, 'kg', 8, 8, 3, 'images/produits/steak-hache.jpg', NULL, '🥩', 'Steak haché 20%', 1),
(13, 'V003', 'Cuisses poulet', 2, 'Volaille Express', 5.80, 5.80, 'kg', 15, 15, 6, 'images/produits/cuisses-poulet.jpg', NULL, '🍗', 'Cuisses de poulet', 1),
(14, 'V004', 'Côtelettes porc', 2, 'Boucherie Martin', 8.20, 8.20, 'kg', 12, 12, 5, 'images/produits/cottelettes-porc.jpg', NULL, '🥓', 'Côtelettes de porc', 1),
(15, 'V005', 'Merguez 500g', 2, 'Maison Bouvet', 4.50, 4.50, 'pack', 20, 20, 8, 'images/produits/merguez.jpg', NULL, '🌭', 'Merguez 500g', 1),
(16, 'V006', 'Aiguillettes poulet', 2, 'Volaille Express', 7.90, 7.90, 'kg', 6, 6, 2, 'images/produits/aiguillettes.jpg', NULL, '🍗', 'Aiguillettes de poulet', 1),
(17, 'V007', 'Filet mignon porc', 2, 'Boucherie Martin', 12.50, 12.50, 'kg', 5, 5, 2, 'images/produits/filet-mignon.jpg', NULL, '🥩', 'Filet mignon de porc', 1),
(18, 'V008', 'Surlonge bœuf', 2, 'Maison Bouvet', 15.90, 15.90, 'kg', 4, 4, 2, 'images/produits/surlonge-boeuf.jpg', NULL, '🥩', 'Surlonge de bœuf', 1),
(19, 'V009', 'Foie poulet 500g', 2, 'Volaille Express', 3.80, 3.80, 'pack', 18, 18, 7, 'images/produits/foie-poulet.jpg', NULL, '🍗', 'Foie de poulet', 1),
(20, 'V010', 'Haut de cuisse dinde', 2, 'Boucherie Martin', 9.20, 9.20, 'kg', 9, 9, 4, 'images/produits/cuisse-dinde.jpg', NULL, '🍗', 'Haut de cuisse de dinde', 1),

(21, 'C001', 'Jambon blanc 200g', 3, 'Charcuterie Du Coin', 2.80, 2.80, 'pack', 25, 25, 10, 'images/produits/jambon-blanc.jpg', NULL, '🥓', 'Jambon blanc tranché', 1),
(22, 'C002', 'Rillettes porc 180g', 3, 'Maison Cendré', 3.20, 3.20, 'pack', 16, 16, 6, 'images/produits/rillettes.jpg', NULL, '🥓', 'Rillettes de porc', 1),
(23, 'C003', 'Pâté maison 200g', 3, 'Maison Cendré', 4.10, 4.10, 'pack', 14, 14, 5, 'images/produits/pate-maison.jpg', NULL, '🥓', 'Pâté de campagne', 1),
(24, 'C004', 'Saucisson sec 200g', 3, 'Charcuterie Du Coin', 5.90, 5.90, 'pack', 22, 22, 8, 'images/produits/saucisson-sec.jpg', NULL, '🥓', 'Saucisson sec', 1),
(25, 'C005', 'Fromage de tête', 3, 'Maison Cendré', 4.50, 4.50, 'pack', 12, 12, 4, 'images/produits/fromage-tete.jpg', NULL, '🥓', 'Fromage de tête', 1),
(26, 'C006', 'Chorizo 200g', 3, 'Charcuterie Du Coin', 6.20, 6.20, 'pack', 18, 18, 7, 'images/produits/chorizo.jpg', NULL, '🌶️', 'Chorizo doux', 1),
(27, 'C007', 'Jambon cru 100g', 3, 'Maison Cendré', 7.80, 7.80, 'pack', 10, 10, 3, 'images/produits/jambon-cru.jpg', NULL, '🥓', 'Jambon cru affiné', 1),
(28, 'C008', 'Terrine campagne', 3, 'Charcuterie Du Coin', 5.60, 5.60, 'pack', 11, 11, 4, 'images/produits/terrine.jpg', NULL, '🥓', 'Terrine de campagne', 1),
(29, 'C009', 'Knacki 10x40g', 3, 'Herta', 3.90, 3.90, 'pack', 30, 30, 12, 'images/produits/knacki.jpg', NULL, '🌭', 'Saucisses knacki', 1),
(30, 'C010', 'Salami 150g', 3, 'Charcuterie Du Coin', 6.80, 6.80, 'pack', 15, 15, 6, 'images/produits/salami.jpg', NULL, '🥓', 'Salami tranché', 1),

(31, 'P001', 'Filets cabillaud 400g', 4, 'Poisson Frais SA', 9.90, 9.90, 'pack', 8, 8, 3, 'images/produits/cabillaud.jpg', NULL, '🐟', 'Filets de cabillaud', 1),
(32, 'P002', 'Crevettes roses 200g', 4, 'Marée Atlantique', 7.50, 7.50, 'pack', 12, 12, 4, 'images/produits/crevettes.jpg', NULL, '🦐', 'Crevettes roses', 1),
(33, 'P003', 'Saumon fumé 100g', 4, 'Marée Atlantique', 6.80, 6.80, 'pack', 20, 20, 8, 'images/produits/saumon-fume.jpg', NULL, '🐟', 'Saumon fumé', 1),
(34, 'P004', 'Filets maquereau', 4, 'Poisson Frais SA', 4.20, 4.20, 'pack', 10, 10, 4, 'images/produits/maquereau.jpg', NULL, '🐟', 'Filets de maquereau', 1),
(35, 'P005', 'Moules décortiquées', 4, 'Marée Atlantique', 5.90, 5.90, 'pack', 6, 6, 2, 'images/produits/moules.jpg', NULL, '🦪', 'Moules décortiquées', 1),
(36, 'P006', 'Thon au naturel', 4, 'Conserverie Océane', 1.80, 1.80, 'unité', 25, 25, 10, 'images/produits/thon-naturel.jpg', NULL, '🐟', 'Thon au naturel', 1),
(37, 'P007', 'Sardines en boîte', 4, 'Conserverie Océane', 1.20, 1.20, 'unité', 35, 35, 15, 'images/produits/sardines.jpg', NULL, '🐟', 'Sardines à l’huile', 1),
(38, 'P008', 'Surimi bâtonnets', 4, 'Frais & Co', 2.99, 2.99, 'pack', 18, 18, 7, 'images/produits/surimi.jpg', NULL, '🦀', 'Bâtonnets de surimi', 1),
(39, 'P009', 'Anchois marinade', 4, 'Conserverie Océane', 3.50, 3.50, 'pack', 14, 14, 5, 'images/produits/anchois.jpg', NULL, '🐟', 'Anchois marinés', 1),
(40, 'P010', 'Calmars anneaux', 4, 'Poisson Frais SA', 8.90, 8.90, 'pack', 9, 9, 3, 'images/produits/calmars.jpg', NULL, '🦑', 'Anneaux de calmars', 1),

(41, 'L001', 'Yaourt nature 4x125g', 5, 'Danone', 0.90, 0.90, 'pack', 12, 12, 4, 'images/produits/yaourt-nature.jpg', NULL, '🥛', 'Yaourts nature', 1),
(42, 'L002', 'Beurre demi-sel 250g', 5, 'Lactalis', 2.40, 2.40, 'pack', 20, 20, 8, 'images/produits/beurre.jpg', NULL, '🧈', 'Beurre demi-sel', 1),
(43, 'L003', 'Fromage emmental 300g', 5, 'Fromagerie Centrale', 4.80, 4.80, 'pack', 15, 15, 6, 'images/produits/emmental.jpg', NULL, '🧀', 'Emmental râpé', 1),
(44, 'L004', 'Camembert 250g', 5, 'Fromagerie Centrale', 3.90, 3.90, 'unité', 10, 10, 4, 'images/produits/camembert.jpg', NULL, '🧀', 'Camembert fermier', 1),
(45, 'L005', 'Crème fraîche 20%', 5, 'Lactalis', 1.60, 1.60, 'unité', 18, 18, 7, 'images/produits/creme-fraiche.jpg', NULL, '🥛', 'Crème fraîche', 1),
(46, 'L006', 'Lait entier 1L', 5, 'Danone', 1.20, 1.20, 'unité', 30, 30, 12, 'images/produits/lait-entier.jpg', NULL, '🥛', 'Lait entier', 1),
(47, 'L007', 'Fromage frais 150g', 5, 'Fromagerie Centrale', 1.99, 1.99, 'pack', 22, 22, 9, 'images/produits/fromage-frais.jpg', NULL, '🧀', 'Fromage frais', 1),
(48, 'L008', 'Œufs moyens x12', 5, 'Ferme du Nid', 3.20, 3.20, 'pack', 25, 25, 10, 'images/produits/oeufs.jpg', NULL, '🥚', 'Œufs moyens', 1),
(49, 'L009', 'Roquefort 200g', 5, 'Fromagerie Centrale', 6.50, 6.50, 'pack', 8, 8, 3, 'images/produits/roquefort.jpg', NULL, '🧀', 'Roquefort AOP', 1),
(50, 'L010', 'Petits suisses 4x60g', 5, 'Danone', 2.10, 2.10, 'pack', 16, 16, 6, 'images/produits/petits-suisses.jpg', NULL, '🥛', 'Petits suisses nature', 1),

(51, 'B001', 'Jus orange 1L', 9, 'Tropicana', 2.50, 2.50, 'unité', 5, 5, 5, 'images/produits/jus-orange.jpg', NULL, '🍊', 'Jus d’orange', 1),
(52, 'B002', 'Eau minérale 1.5L', 9, 'Evian', 1.00, 1.00, 'unité', 20, 20, 5, 'images/produits/eau-minerale.jpg', NULL, '💧', 'Eau minérale', 1),
(53, 'B003', 'Coca Cola 33cl', 9, 'Coca-Cola', 1.20, 1.20, 'unité', 25, 25, 10, 'images/produits/coca-cola.jpg', NULL, '🥤', 'Boisson gazeuse', 1),
(54, 'B004', 'Eau pétillante 1L', 9, 'Perrier', 1.40, 1.40, 'unité', 15, 15, 6, 'images/produits/eau-petillante.jpg', NULL, '💦', 'Eau pétillante', 1),
(55, 'B005', 'Jus multifruit 1L', 9, 'Tropicana', 2.80, 2.80, 'unité', 8, 8, 3, 'images/produits/jus-multifruit.jpg', NULL, '🍹', 'Jus multifruit', 1),
(56, 'B006', 'Thé glacé 1.5L', 9, 'Lipton', 2.10, 2.10, 'unité', 12, 12, 4, 'images/produits/the-glace.jpg', NULL, '🫖', 'Thé glacé', 1),
(57, 'B007', 'Sprite 33cl', 9, 'Sprite', 1.30, 1.30, 'unité', 18, 18, 7, 'images/produits/sprite.jpg', NULL, '🥤', 'Soda citron-lime', 1),
(58, 'B008', 'Bière blonde 33cl x6', 9, 'Heineken', 7.90, 7.90, 'pack', 10, 10, 4, 'images/produits/biere-blonde.jpg', NULL, '🍺', 'Pack bière blonde', 1),
(59, 'B009', 'Sirop menthe 1L', 9, 'Teisseire', 4.50, 4.50, 'unité', 14, 14, 5, 'images/produits/sirop-menthe.jpg', NULL, '🌿', 'Sirop de menthe', 1),
(60, 'B010', 'Limonade 1L', 9, 'Lorina', 2.20, 2.20, 'unité', 11, 11, 4, 'images/produits/limonade.jpg', NULL, '🥤', 'Limonade artisanale', 1),

(61, 'H001', 'Savon liquide 500ml', 11, 'Dove', 3.20, 3.20, 'unité', 8, 8, 3, 'images/produits/savon-liquide.jpg', NULL, '🧼', 'Savon liquide main', 1),
(62, 'H002', 'Shampoing 400ml', 11, 'L’Oréal', 4.90, 4.90, 'unité', 12, 12, 4, 'images/produits/shampoing.jpg', NULL, '🧴', 'Shampoing doux', 1),
(63, 'H003', 'Dentifrice 100ml', 11, 'Colgate', 2.80, 2.80, 'unité', 25, 25, 10, 'images/produits/dentifrice.jpg', NULL, '🦷', 'Dentifrice', 1),
(64, 'H004', 'Déodorant spray', 11, 'Nivea', 3.50, 3.50, 'unité', 18, 18, 7, 'images/produits/deodorant.jpg', NULL, '🌸', 'Déodorant spray', 1),
(65, 'H005', 'Gel douche 250ml', 11, 'Dove', 2.99, 2.99, 'unité', 15, 15, 6, 'images/produits/gel-douche.jpg', NULL, '🛁', 'Gel douche', 1),
(66, 'H006', 'Crème hydratante', 11, 'Nivea', 6.80, 6.80, 'unité', 10, 10, 4, 'images/produits/creme-hydratante.jpg', NULL, '🧴', 'Crème hydratante', 1),
(67, 'H007', 'Rasoir 5 lames', 11, 'Gillette', 8.90, 8.90, 'pack', 22, 22, 9, 'images/produits/rasoir.jpg', NULL, '🪒', 'Rasoir 5 lames', 1),
(68, 'H008', 'Papier toilette x12', 11, 'Lotus', 7.50, 7.50, 'pack', 30, 30, 12, 'images/produits/papier-toilette.jpg', NULL, '🧻', 'Papier toilette', 1),
(69, 'H009', 'Serviettes hygiéniques', 11, 'Always', 3.20, 3.20, 'pack', 16, 16, 6, 'images/produits/serviettes.jpg', NULL, '🩷', 'Serviettes hygiéniques', 1),
(70, 'H010', 'Aftershave 100ml', 11, 'Nivea Men', 5.90, 5.90, 'unité', 14, 14, 5, 'images/produits/aftershave.jpg', NULL, '🪞', 'Aftershave', 1),

(71, 'E001', 'Liquide vaisselle 1L', 12, 'Paic', 2.49, 2.49, 'unité', 20, 20, 8, 'images/produits/liquide-vaisselle.jpg', NULL, '🧽', 'Liquide vaisselle', 1),
(72, 'E002', 'Lessive liquide 2L', 12, 'Ariel', 6.90, 6.90, 'unité', 12, 12, 4, 'images/produits/lessive-liquide.jpg', NULL, '🧺', 'Lessive liquide', 1),
(73, 'E003', 'Produits multi-surfaces', 12, 'Mr Propre', 3.80, 3.80, 'unité', 15, 15, 6, 'images/produits/multi-surfaces.jpg', NULL, '🧴', 'Nettoyant multi-surfaces', 1),
(74, 'E004', 'Eau de javel 1L', 12, 'Ajax', 1.99, 1.99, 'unité', 18, 18, 7, 'images/produits/eau-javel.jpg', NULL, '🧪', 'Eau de javel', 1),
(75, 'E005', 'Sac poubelle 50L x50', 12, 'Spontex', 9.50, 9.50, 'pack', 25, 25, 10, 'images/produits/sac-poubelle.jpg', NULL, '🗑️', 'Sacs poubelle', 1),
(76, 'E006', 'Destructeur graisse', 12, 'Cillit Bang', 4.20, 4.20, 'unité', 10, 10, 4, 'images/produits/destructeur-graisse.jpg', NULL, '🧼', 'Décrassant graisse', 1),
(77, 'E007', 'Eponges x4', 12, 'Scotch-Brite', 2.10, 2.10, 'pack', 30, 30, 12, 'images/produits/eponges.jpg', NULL, '🧽', 'Éponges ménage', 1),
(78, 'E008', 'Produits vitres 750ml', 12, 'Ajax', 2.80, 2.80, 'unité', 16, 16, 6, 'images/produits/vitres.jpg', NULL, '🪟', 'Nettoyant vitres', 1),
(79, 'E009', 'Gants caoutchouc', 12, 'Spontex', 1.80, 1.80, 'unité', 22, 22, 9, 'images/produits/gants-caoutchouc.jpg', NULL, '🧤', 'Gants ménagers', 1),
(80, 'E010', 'Chiffons microfibres x5', 12, 'Vileda', 4.90, 4.90, 'pack', 28, 28, 11, 'images/produits/chiffons.jpg', NULL, '🧻', 'Chiffons microfibres', 1),

(81, 'BB001', 'Couches taille 2 x40', 13, 'Pampers', 12.90, 12.90, 'pack', 8, 8, 3, 'images/produits/couches-t2.jpg', NULL, '👶', 'Couches bébé taille 2', 1),
(82, 'BB002', 'Lait 1er âge 400g', 13, 'Gallia', 15.50, 15.50, 'pack', 12, 12, 4, 'images/produits/lait-bebe.jpg', NULL, '🍼', 'Lait infantile', 1),
(83, 'BB003', 'Lingettes x80', 13, 'Pampers', 3.99, 3.99, 'pack', 15, 15, 6, 'images/produits/lingettes.jpg', NULL, '🧻', 'Lingettes bébé', 1),
(84, 'BB004', 'Compote pomme x4', 13, 'Good Gout', 2.20, 2.20, 'pack', 20, 20, 8, 'images/produits/compote-pomme.jpg', NULL, '🍏', 'Compotes pour bébé', 1),
(85, 'BB005', 'Biberon 260ml', 13, 'Avent', 7.80, 7.80, 'unité', 10, 10, 4, 'images/produits/biberon.jpg', NULL, '🍼', 'Biberon 260ml', 1),
(86, 'BB006', 'Eau bébé 1L', 13, 'Evian', 1.60, 1.60, 'unité', 18, 18, 7, 'images/produits/eau-bebe.jpg', NULL, '💧', 'Eau pour bébé', 1),
(87, 'BB007', 'Couches taille 1 x40', 13, 'Pampers', 12.90, 12.90, 'pack', 9, 9, 3, 'images/produits/couches-t1.jpg', NULL, '👶', 'Couches bébé taille 1', 1),
(88, 'BB008', 'Tetine silicone', 13, 'Avent', 4.50, 4.50, 'unité', 25, 25, 10, 'images/produits/tetine.jpg', NULL, '🍼', 'Tétine silicone', 1),
(89, 'BB009', 'Linge bébé x3', 13, 'Petit Bateau', 8.90, 8.90, 'pack', 14, 14, 5, 'images/produits/linge-bebe.jpg', NULL, '👕', 'Linge bébé', 1),
(90, 'BB010', 'Doudou ours', 13, 'Kaloo', 9.99, 9.99, 'unité', 16, 16, 6, 'images/produits/doudou.jpg', NULL, '🧸', 'Doudou ourson', 1),

(91, 'P001', 'Cahier 96p', 18, 'Oxford', 1.20, 1.20, 'unité', 50, 50, 20, 'images/produits/cahier-96p.jpg', NULL, '📓', 'Cahier 96 pages', 1),
(92, 'P002', 'Stylo bic bleu x5', 18, 'Bic', 2.50, 2.50, 'pack', 100, 100, 40, 'images/produits/stylos-bic.jpg', NULL, '🖊️', 'Stylos bic bleus', 1),
(93, 'P003', 'Feutres 12 couleurs', 18, 'Maped', 5.90, 5.90, 'pack', 25, 25, 10, 'images/produits/feutres.jpg', NULL, '🖍️', 'Feutres coloriage', 1),
(94, 'P004', 'Carnet A5 ligné', 18, 'Clairefontaine', 3.80, 3.80, 'unité', 35, 35, 15, 'images/produits/carnet-a5.jpg', NULL, '📒', 'Carnet A5', 1),
(95, 'P005', 'Colle bâton 40g', 18, 'UHU', 1.99, 1.99, 'unité', 40, 40, 16, 'images/produits/colle-baton.jpg', NULL, '🧴', 'Colle bâton', 1),
(96, 'P006', 'Règle 30cm', 18, 'Maped', 0.80, 0.80, 'unité', 60, 60, 25, 'images/produits/regle-30cm.jpg', NULL, '📏', 'Règle 30 cm', 1),
(97, 'P007', 'Gomme blanche', 18, 'Staedtler', 0.60, 0.60, 'unité', 80, 80, 32, 'images/produits/gomme.jpg', NULL, '🧼', 'Gomme blanche', 1),
(98, 'P008', 'Ciseaux école', 18, 'Maped', 2.40, 2.40, 'unité', 30, 30, 12, 'images/produits/ciseaux-ecole.jpg', NULL, '✂️', 'Ciseaux scolaires', 1),
(99, 'P009', 'Bloc notes A4', 18, 'Oxford', 1.50, 1.50, 'unité', 45, 45, 18, 'images/produits/bloc-notes.jpg', NULL, '🗒️', 'Bloc-notes A4', 1),
(100, 'P010', 'Stylo gel noir x3', 18, 'Pilot', 3.20, 3.20, 'pack', 55, 55, 22, 'images/produits/stylo-gel.jpg', NULL, '🖋️', 'Stylos gel noirs', 1);


-- ============================
-- INSERT MOUVEMENTS (EXEMPLE)
-- ============================
INSERT INTO mouvements
(id, produit_id, utilisateur_id, type_mouvement, type, quantite, stock_avant, stock_apres, motif, reference_doc, date_mouvement, commentaire)
VALUES
(1, 1, 1, 'entree', 'entree', 20, 18, 38, 'approvisionnement', 'BL-2026-001', '2026-02-01 09:30:00', 'Réapprovisionnement pommes Golden'),
(2, 2, 1, 'entree', 'entree', 15, 25, 40, 'approvisionnement', 'BL-2026-002', '2026-02-01 10:00:00', 'Réception bananes'),
(3, 12, 2, 'vente', 'sortie', 3, 8, 5, 'vente', 'TICKET-1001', '2026-02-01 11:15:00', 'Vente steak haché'),
(4, 41, 2, 'vente', 'sortie', 4, 12, 8, 'vente', 'TICKET-1002', '2026-02-01 12:10:00', 'Vente yaourts'),
(5, 61, 3, 'entree', 'entree', 10, 8, 18, 'approvisionnement', 'BL-2026-003', '2026-02-02 08:45:00', 'Arrivage savon liquide'),
(6, 72, 3, 'entree', 'entree', 12, 12, 24, 'approvisionnement', 'BL-2026-004', '2026-02-02 09:00:00', 'Réception lessive'),
(7, 83, 1, 'perte', 'sortie', 2, 15, 13, 'perte_peremption', 'REG-2026-001', '2026-02-02 17:45:00', 'Lingettes abîmées'),
(8, 90, 1, 'vente', 'sortie', 1, 16, 15, 'vente', 'TICKET-1003', '2026-02-03 14:20:00', 'Vente doudou ours'),
(9, 31, 2, 'entree', 'entree', 6, 8, 14, 'approvisionnement', 'BL-2026-005', '2026-02-04 07:50:00', 'Approvisionnement poissonnerie'),
(10, 95, 3, 'casse', 'sortie', 5, 40, 35, 'casse', 'REG-2026-002', '2026-02-04 16:05:00', 'Colles bâton endommagées');
