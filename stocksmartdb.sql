-- Création des tables pour le TD0
-- REPONSES AUX QUESTIONS à la ligne 392
DROP DATABASE IF EXISTS techshop;
CREATE DATABASE IF NOT EXISTS techshop;
USE techshop;

-- Table des clients
CREATE TABLE customers (
    customer_id INT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(100) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    address VARCHAR(200),
    loyalty_level ENUM('New', 'Bronze', 'Silver', 'Gold') DEFAULT 'New',
    date_created DATETIME DEFAULT CURRENT_TIMESTAMP,
    date_modified DATETIME DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_visit DATETIME,
    active BOOLEAN DEFAULT TRUE
);

-- Table des fournisseurs
CREATE TABLE suppliers (
    supplier_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    phone VARCHAR(20)
);

-- Table des produits
CREATE TABLE products (
    product_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    price DECIMAL(10,2) NOT NULL,
    stock INT DEFAULT 0,
    category VARCHAR(50),
    supplier_id INT,
    status VARCHAR(20) DEFAULT 'Active',
    last_sale_date DATETIME,
    date_added DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (supplier_id) REFERENCES suppliers(supplier_id)
);

-- Table du catalogue produits
CREATE TABLE product_catalog (
    catalog_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT,
    featured BOOLEAN DEFAULT FALSE,
    display_order INT,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Table des commandes
CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    order_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) DEFAULT 'Pending',
    total_amount DECIMAL(10,2),
    delivery_address VARCHAR(200),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Table des éléments de commande
CREATE TABLE order_items (
    order_id INT,
    product_id INT,
    quantity INT NOT NULL,
    price_at_time DECIMAL(10,2) NOT NULL,
    PRIMARY KEY (order_id, product_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Table des avis produits
CREATE TABLE product_reviews (
    review_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT,
    customer_id INT,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    review_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Table des adresses de livraison
CREATE TABLE delivery_addresses (
    address_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    address VARCHAR(200) NOT NULL,
    is_default BOOLEAN DEFAULT FALSE,
    date_added DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Table de l'historique des prix
CREATE TABLE price_history (
    history_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT,
    price DECIMAL(10,2) NOT NULL,
    change_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Table des listes de souhaits
CREATE TABLE wishlist_items (
    wishlist_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    product_id INT,
    date_added DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Table du panier
CREATE TABLE cart_items (
    cart_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    product_id INT,
    quantity INT DEFAULT 1,
    date_added DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- Table des factures
CREATE TABLE invoices (
    invoice_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT,
    customer_email VARCHAR(100),
    amount DECIMAL(10,2),
    date_created DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- Table des tickets support
CREATE TABLE support_tickets (
    ticket_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
    customer_email VARCHAR(100),
    subject VARCHAR(200),
    status VARCHAR(20) DEFAULT 'Open',
    date_created DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

-- Table d'audit
CREATE TABLE audit_log (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    table_name VARCHAR(50),
    record_id INT,
    action VARCHAR(20),
    old_value TEXT,
    new_value TEXT,
    change_date DATETIME DEFAULT CURRENT_TIMESTAMP,
    changed_by VARCHAR(50)
);


-- Insert data into customers table
INSERT INTO customers (email, name, address, loyalty_level, last_visit, active)
VALUES
('john.doe@example.com', 'John Doe', '123 Elm Street, Cityville', 'Silver', '2023-09-15 12:45:00', TRUE),
('jane.smith@example.com', 'Jane Smith', '456 Oak Avenue, Townsville', 'Gold', '2023-10-01 14:10:00', TRUE),
('mike.jones@example.com', 'Mike Jones', '789 Pine Road, Villageton', 'Bronze', '2023-08-22 09:00:00', FALSE),
('lisa.brown@example.com', 'Lisa Brown', '321 Maple Drive, Lakeview', 'New', '2023-07-19 16:25:00', TRUE),
('paul.green@example.com', 'Paul Green', '654 Cedar Avenue, Hometown', 'Silver', '2023-06-25 11:40:00', TRUE),
('amy.white@example.com', 'Amy White', '987 Birch Blvd, Hilltown', 'Bronze', '2023-05-13 17:55:00', TRUE),
('mark.davis@example.com', 'Mark Davis', '456 Spruce Street, Valley City', 'Gold', '2023-04-20 18:05:00', FALSE),
('sara.wilson@example.com', 'Sara Wilson', '321 Aspen Way, Riverside', 'New', '2023-09-10 15:00:00', TRUE),
('tom.harris@example.com', 'Tom Harris', '789 Willow Lane, Greenfield', 'Silver', '2023-10-11 13:30:00', TRUE),
('linda.thomas@example.com', 'Linda Thomas', '456 Fir Avenue, Beachtown', 'Gold', '2023-10-15 12:10:00', TRUE),
('linda.x@example.com', 'Linda X', '456 Fir Avenue, X', 'Gold', NULL, TRUE);

-- Insert data into suppliers table
INSERT INTO suppliers (name, email, phone)
VALUES
('TechCorp', 'contact@techcorp.com', '123-456-7890'),
('GadgetHouse', 'info@gadgethouse.com', '987-654-3210'),
('RetroFun', 'support@retrofun.com', '555-123-4567'),
('ElectroWorld', 'sales@electroworld.com', '444-222-3333'),
('PowerUp', 'info@powerup.com', '111-222-3333'),
('ComputeHub', 'service@computehub.com', '222-333-4444'),
('GizmoDepot', 'support@gizmodepot.com', '333-444-5555'),
('DeviceCenter', 'contact@devicecenter.com', '555-666-7777'),
('Techies', 'hello@techies.com', '666-777-8888'),
('BestDevices', 'info@bestdevices.com', '777-888-9999');

-- Insert data into products table
INSERT INTO products (name, description, price, stock, category, supplier_id, status, last_sale_date)
VALUES
('Gaming Laptop', 'High-performance gaming laptop', 1429.99, 50, 'Electronics', 1, 'Active', '2023-09-12 10:00:00'),
('Smartphone Pro', 'Latest model smartphone', 989.99, 100, 'Electronics', 2, 'Active', '2023-09-14 11:20:00'),
('Retro Console', 'Classic retro gaming console', 219.99, 75, 'Gaming', 3, 'Active', '2023-10-01 13:30:00'),
('Wireless Earbuds', 'Noise-cancelling earbuds', 149.99, 200, 'Audio', 4, 'Active', '2023-10-10 16:45:00'),
('Smartwatch', 'Feature-packed smartwatch', 249.99, 120, 'Wearables', 5, 'Active', '2023-10-12 14:55:00'),
('Tablet Pro', 'High-resolution tablet', 499.99, 90, 'Electronics', 6, 'Active', '2023-09-20 09:10:00'),
('4K TV', 'Ultra HD 4K television', 699.99, 30, 'Home Electronics', 7, 'Active', '2023-10-15 12:05:00'),
('Gaming Keyboard', 'Mechanical gaming keyboard', 79.99, 150, 'Peripherals', 8, 'Active', '2023-09-25 17:30:00'),
('Bluetooth Speaker', 'Portable Bluetooth speaker', 89.99, 180, 'Audio', 9, 'Active', '2023-10-05 18:00:00'),
('Smart Home Hub', 'Smart home device controller', 129.99, 80, 'Home Automation', 10, 'Active', '2023-09-18 20:15:00');

-- Insert data into product_catalog table
INSERT INTO product_catalog (product_id, featured, display_order)
VALUES
(1, TRUE, 1),
(2, TRUE, 2),
(3, TRUE, 3),
(4, FALSE, 4),
(5, FALSE, 5),
(6, TRUE, 6),
(7, FALSE, 7),
(8, TRUE, 8),
(9, FALSE, 9),
(10, TRUE, 10);

-- Insert data into orders table
INSERT INTO orders (customer_id, order_date, status, total_amount, delivery_address)
VALUES
(1, '2023-10-15 14:30:00', 'UNKNOWN', 1429.99, '123 Elm Street, Cityville'),
(2, '2023-10-14 09:45:00', 'Delivered', 989.99, '456 Oak Avenue, Townsville'),
(3, '2023-09-10 16:15:00', 'Shipped', 219.99, '789 Pine Road, Villageton'),
(4, '2023-10-20 11:10:00', 'Pending', 149.99, '321 Maple Drive, Lakeview'),
(5, '2023-10-11 13:25:00', 'Shipped', 249.99, '654 Cedar Avenue, Hometown'),
(6, '2023-09-12 12:00:00', 'Delivered', 499.99, '987 Birch Blvd, Hilltown'),
(7, '2023-08-22 09:55:00', 'Pending', 699.99, '456 Spruce Street, Valley City'),
(8, '2023-07-10 10:45:00', 'Shipped', 79.99, '321 Aspen Way, Riverside'),
(9, '2023-10-21 12:35:00', 'Pending', 89.99, '789 Willow Lane, Greenfield'),
(10, '2023-09-10 15:15:00', 'Delivered', 129.99, '456 Fir Avenue, Beachtown');

-- Insert data into order_items table
INSERT INTO order_items (order_id, product_id, quantity, price_at_time)
VALUES
(1, 1, 1, 1429.99),
(2, 2, 1, 989.99),
(3, 3, 1, 219.99),
(4, 4, 1, 149.99),
(5, 5, 1, 249.99),
(6, 6, 1, 499.99),
(7, 7, 1, 699.99),
(8, 8, 1, 79.99),
(9, 9, 1, 89.99),
(10, 10, 1, 129.99);

-- Insert data into product_reviews table
INSERT INTO product_reviews (product_id, customer_id, rating, comment)
VALUES
(1, 1, 5, 'Amazing product, highly recommended!'),
(2, 2, 4, 'Good value for money.'),
(3, 3, 5, 'Classic experience! Love it.'),
(4, 4, 3, 'Decent sound, could be better.'),
(5, 5, 4, 'Great features, battery life could be improved.'),
(6, 6, 5, 'Perfect for entertainment.'),
(7, 7, 4, 'Impressive clarity and colors.'),
(8, 8, 3, 'Keys are a bit stiff, but overall good.'),
(9, 9, 4, 'Great for outdoor use.'),
(10, 10, 5, 'Works flawlessly with all my devices.');

-- Insert data into delivery_addresses table
INSERT INTO delivery_addresses (customer_id, address, is_default)
VALUES
(1, '123 Elm Street, Cityville', TRUE),
(2, '456 Oak Avenue, Townsville', TRUE),
(3, '789 Pine Road, Villageton', FALSE),
(4, '321 Maple Drive, Lakeview', TRUE),
(5, '654 Cedar Avenue, Hometown', TRUE),
(6, '987 Birch Blvd, Hilltown', FALSE),
(7, '456 Spruce Street, Valley City', TRUE),
(8, '321 Aspen Way, Riverside', TRUE),
(9, '789 Willow Lane, Greenfield', TRUE),
(10, '456 Fir Avenue, Beachtown', TRUE);

INSERT INTO delivery_addresses (customer_id, address, is_default, date_added)
VALUES
(1, '123 Elm Street, Cityville', TRUE, '2024-10-01'),
(1, '123 Elm Street, Cityville', FALSE, '2023-10-01');

-- Insert data into price_history table
INSERT INTO price_history (product_id, price, change_date)
VALUES
(1, 1429.99, '2023-09-10 10:30:00'),
(2, 989.99, '2023-08-20 09:45:00'),
(3, 219.99, '2023-09-01 14:00:00'),
(4, 149.99, '2023-10-01 11:30:00'),
(5, 249.99, '2023-09-25 15:10:00'),
(6, 499.99, '2023-09-20 16:45:00'),
(7, 699.99, '2023-08-10 12:10:00'),
(8, 79.99, '2023-09-05 13:35:00'),
(9, 89.99, '2023-09-30 14:20:00'),
(10, 129.99, '2023-10-15 15:55:00');

-- Insert data into wishlist_items table
INSERT INTO wishlist_items (customer_id, product_id)
VALUES
(1, 1),
(2, 2),
(3, 3),
(4, 4),
(5, 5),
(6, 6),
(7, 7),
(8, 8),
(9, 9),
(10, 10);

-- Insert data into cart_items table
INSERT INTO cart_items (customer_id, product_id, quantity)
VALUES
(1, 2, 1),
(2, 1, 1),
(3, 5, 2),
(4, 3, 1),
(5, 4, 2),
(6, 6, 1),
(7, 8, 1),
(8, 9, 2),
(9, 7, 1),
(10, 10, 1);

-- Insert data into invoices table
INSERT INTO invoices (order_id, customer_email, amount)
VALUES
(1, 'john.doe@example.com', 1429.99),
(2, 'jane.smith@example.com', 989.99),
(3, 'mike.jones@example.com', 219.99),
(4, 'lisa.brown@example.com', 149.99),
(5, 'paul.green@example.com', 249.99),
(6, 'amy.white@example.com', 499.99),
(7, 'mark.davis@example.com', 699.99),
(8, 'sara.wilson@example.com', 79.99),
(9, 'tom.harris@example.com', 89.99),
(10, 'linda.thomas@example.com', 129.99);

-- Insert data into support_tickets table
INSERT INTO support_tickets (customer_id, customer_email, subject, status)
VALUES
(1, 'john.doe@example.com', 'Issue with Gaming Laptop', 'Open'),
(2, 'jane.smith@example.com', 'Smartphone Pro not charging', 'Closed'),
(3, 'mike.jones@example.com', 'Retro Console defect', 'Pending'),
(4, 'lisa.brown@example.com', 'Missing accessory', 'Resolved'),
(5, 'paul.green@example.com', 'Delivery delayed', 'Open'),
(6, 'amy.white@example.com', 'Tablet Pro screen issue', 'Closed'),
(7, 'mark.davis@example.com', 'Keyboard keys malfunctioning', 'Pending'),
(8, 'sara.wilson@example.com', 'Bluetooth speaker sound issue', 'Open'),
(9, 'tom.harris@example.com', 'Invoice discrepancy', 'Closed'),
(10, 'linda.thomas@example.com', 'Warranty question', 'Open');

-- Insert data into audit_log table
INSERT INTO audit_log (table_name, record_id, action, old_value, new_value, changed_by)
VALUES
('customers', 1, 'Update', '{"loyalty_level": "Silver"}', '{"loyalty_level": "Gold"}', 'admin'),
('products', 2, 'Update', '{"stock": 100}', '{"stock": 90}', 'admin'),
('orders', 3, 'Insert', NULL, '{"order_id": 3, "status": "Shipped"}', 'system'),
('customers', 4, 'Delete', '{"active": "TRUE"}', '{"active": "FALSE"}', 'user'),
('support_tickets', 5, 'Update', '{"status": "Open"}', '{"status": "Resolved"}', 'support'),
('product_reviews', 6, 'Update', '{"rating": "4"}', '{"rating": "5"}', 'moderator'),
('products', 7, 'Insert', NULL, '{"product_id": 7, "status": "Active"}', 'admin'),
('invoices', 8, 'Update', '{"amount": "79.99"}', '{"amount": "89.99"}', 'accounting'),
('cart_items', 9, 'Delete', '{"quantity": "1"}', '{"quantity": "0"}', 'system'),
('wishlist_items', 10, 'Insert', NULL, '{"customer_id": 10, "product_id": 10}', 'user');


-- Insertion des produits avec stock=0
INSERT INTO products (name, price, stock, category, supplier_id, status) VALUES 
('Casque Gaming Pro X', 149.99, 0, 'Audio', 1, 'Active'),
('Souris Optique 4000dpi', 49.99, 0, 'Peripherals', 2, 'Active'), 
('Webcam HD Pro', 89.99, 0, 'Peripherals', 3, 'Active');

-- Ces produits ne sont pas dans order_items donc jamais commandés
INSERT INTO products (name, price, stock, category, supplier_id, status) VALUES
('Microphone Studio USB', 129.99, 5, 'Audio', 4, 'Active'),
('Clavier Rétroéclairé', 79.99, 8, 'Peripherals', 5, 'Active');

-- Ces produits n'ont pas d'avis dans product_reviews
INSERT INTO products (name, price, stock, category, supplier_id, status) VALUES
('Tapis de Souris XXL', 29.99, 20, 'Peripherals', 6, 'Active'),
('Hub USB Type-C', 39.99, 15, 'Peripherals', 7, 'Active');

INSERT INTO delivery_addresses (address)
VALUES ('789 Test Street, New City');


-- D'abord, ajoutons la colonne et quelques managers
ALTER TABLE customers ADD COLUMN manager_id INT;

UPDATE customers 
SET manager_id = 2 
WHERE customer_id IN (1, 3, 4);


--- adresse de livraison non utilisée
INSERT INTO delivery_addresses (address)
VALUES ('789 Test Street, New City');

-- REPONSES AUX QUESTIONS 
-- A1. Produits prix > 500
SELECT name, price FROM products WHERE price > 500;

-- Résultat: Gaming Laptop (1429.99), Smartphone Pro (989.99), 4K TV (699.99).

-- A2. Clients Gold visités après 2023-10-01
SELECT name, loyalty_level, last_visit 
FROM customers 
WHERE loyalty_level = 'Gold' AND last_visit > '2023-10-01';

-- Résultat: Jane Smith, Linda Thomas.

-- A3. Tickets support 'Open'
SELECT ticket_id, subject, status FROM support_tickets WHERE status = 'Open';

-- Résultat: tickets 1,5,8,10

-- A4. Produits catégorie 'Electronics'
SELECT name, price FROM products WHERE category = 'Electronics';

-- Résultat: Gaming Laptop, Smartphone Pro, Tablet Pro

-- A5. Clients sans visite depuis 2023-09-01
SELECT name, last_visit 
FROM customers 
WHERE last_visit < '2023-09-01' OR last_visit IS NULL;

-- Résultat: Mike Jones, Paul Green, Amy White, Mark Davis, Linda X.

-- A6. Fournisseurs téléphone commence par '555'
SELECT name, phone FROM suppliers WHERE phone LIKE '555%';

-- Résultat: RetroFun, DeviceCenter.

-- Section B: Jointures Simples
-- B1. Commandes avec nom client
SELECT o.order_id, o.order_date, c.name 
FROM orders o 
INNER JOIN customers c ON o.customer_id = c.customer_id;

-- B2. Produits avec avis 5 étoiles
SELECT p.name, p.price, r.rating, r.comment 
FROM products p 
INNER JOIN product_reviews r ON p.product_id = r.product_id 
WHERE r.rating = 5;

-- Résultat: Gaming Laptop, Retro Console, Tablet Pro, Smart Home Hub.

-- B3. Clients avec adresse par défaut
SELECT c.name, da.address 
FROM customers c 
INNER JOIN delivery_addresses da ON c.customer_id = da.customer_id 
WHERE da.is_default = TRUE;

-- B4. Produits et fournisseurs
SELECT p.name AS productname, s.name AS suppliername 
FROM products p 
INNER JOIN suppliers s ON p.supplier_id = s.supplier_id;

-- B5. Éléments de commandes détaillés
SELECT o.order_id, p.name, oi.quantity, oi.price_at_time 
FROM orders o 
INNER JOIN order_items oi ON o.order_id = oi.order_id 
INNER JOIN products p ON oi.product_id = p.product_id;

-- Section C: Produits Cartésiens (CROSS JOIN)
-- C1. Couples produits même catégorie
SELECT p1.name AS product1, p2.name AS product2, p1.category 
FROM products p1 
CROSS JOIN products p2 
WHERE p1.category = p2.category AND p1.product_id < p2.product_id;

-- C2. Clients Gold × Produits Electronics
SELECT c.name AS client, p.name AS product 
FROM customers c 
CROSS JOIN products p 
WHERE c.loyalty_level = 'Gold' AND p.category = 'Electronics';

-- C3. Fournisseurs × Catégories
SELECT s.name AS suppliername, p.category 
FROM suppliers s 
CROSS JOIN products p;

-- Section D: UNION / UNION ALL
-- D1. Emails clients + fournisseurs
SELECT email, 'Client' AS Type FROM customers WHERE email IS NOT NULL
UNION
SELECT email, 'Fournisseur' AS Type FROM suppliers WHERE email IS NOT NULL;

-- D2. Commandes + Factures > 500
SELECT order_date AS Date, total_amount AS Montant, 'Commande' AS Type 
FROM orders WHERE total_amount > 500
UNION ALL
SELECT date_created AS Date, amount AS Montant, 'Facture' AS Type 
FROM invoices WHERE amount > 500;

-- D3. Produits rupture stock OU jamais commandés OU sans avis
(SELECT name AS product, 'Rupture Stock' AS reason FROM products WHERE stock = 0)
UNION ALL
(SELECT name, 'Jamais Commandé' FROM products p WHERE NOT EXISTS (
    SELECT 1 FROM order_items oi WHERE oi.product_id = p.product_id))
UNION ALL
(SELECT name, 'Sans Avis' FROM products p WHERE NOT EXISTS (
    SELECT 1 FROM product_reviews pr WHERE pr.product_id = p.product_id));

-- Section E: LEFT/RIGHT JOIN

-- E1. Tous clients + adresses (NULL si absent)
SELECT c.name, da.address 
FROM customers c 
LEFT JOIN delivery_addresses da ON c.customer_id = da.customer_id;

-- E2. Tous fournisseurs + produits
SELECT s.name AS supplier, p.name AS product 
FROM suppliers s 
LEFT JOIN products p ON s.supplier_id = p.supplier_id;

-- E3. Tous produits + dernier avis
SELECT p.name, r.review_date, r.comment 
FROM products p 
LEFT JOIN (
    SELECT product_id, review_date, comment,
    ROW_NUMBER() OVER (PARTITION BY product_id ORDER BY review_date DESC) as rn
    FROM product_reviews
) r ON p.product_id = r.product_id AND r.rn = 1;

-- Section F: Self-Join
-- F1. Clients + manager
SELECT c1.name AS client, c2.name AS manager 
FROM customers c1 
LEFT JOIN customers c2 ON c1.manager_id = c2.customer_id;

-- F2. Produit + autre produit même catégorie prix supérieur
SELECT p1.name AS product, p1.price, p2.name AS otherproduct, p2.price AS otherprice
FROM products p1 
JOIN products p2 ON p1.category = p2.category AND p1.price < p2.price 
AND p1.product_id < p2.product_id;

-- F3. Clients Gold + autre Gold plus de commandes
SELECT c1.name AS clientgold, c2.name AS otherclientgold,
(SELECT COUNT(*) FROM orders WHERE customer_id = c1.customer_id) AS clientid,
(SELECT COUNT(*) FROM orders WHERE customer_id = c2.customer_id) AS otherclientid
FROM customers c1 JOIN customers c2 ON c1.loyalty_level = 'Gold' 
AND c2.loyalty_level = 'Gold' AND c1.customer_id < c2.customer_id
HAVING clientid < otherclientid;

-- Section G: UPDATE/DELETE
-- G1. Gold pour commandes >1000
UPDATE customers 
SET loyalty_level = 'Gold' 
WHERE customer_id IN (
    SELECT DISTINCT customer_id FROM orders WHERE total_amount > 1000
);

-- G2. Supprimer produits jamais commandés/wishlist/panier
DELETE p FROM products p 
WHERE NOT EXISTS (SELECT 1 FROM order_items oi WHERE oi.product_id = p.product_id)
AND NOT EXISTS (SELECT 1 FROM wishlist_items w WHERE w.product_id = p.product_id)
AND NOT EXISTS (SELECT 1 FROM cart_items ci WHERE ci.product_id = p.product_id);

-- G3. Cancel commandes Pending >30j sans facture
UPDATE orders 
SET status = 'Cancelled' 
WHERE status = 'Pending' 
AND order_date < DATE_SUB(NOW(), INTERVAL 30 DAY)
AND order_id NOT IN (SELECT order_id FROM invoices);

-- G4. Supprimer adresses non utilisées
DELETE da FROM delivery_addresses da 
WHERE da.address_id NOT IN (
    SELECT DISTINCT SUBSTRING(delivery_address, 1, 200) FROM orders WHERE delivery_address IS NOT NULL
);

-- Section H: Requêtes complexes
-- H1. Clients avec commande ET avis ET ticket
SELECT DISTINCT c.name 
FROM customers c 
WHERE EXISTS (SELECT 1 FROM orders o WHERE o.customer_id = c.customer_id)
AND EXISTS (SELECT 1 FROM product_reviews pr WHERE pr.customer_id = c.customer_id)
AND EXISTS (SELECT 1 FROM support_tickets st WHERE st.customer_id = c.customer_id);
