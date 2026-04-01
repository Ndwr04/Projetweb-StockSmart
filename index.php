<?php
session_start();
require_once 'config.php';

// FIX TEMPORAIRE : Force login
if (!isset($_SESSION['user_id'])) {
    $_SESSION['user_id'] = 1;
    $_SESSION['user_nom'] = 'Rose Pretty';
    $_SESSION['user_role'] = 'admin';
}

$user_nom = $_SESSION['user_nom'];
$user_role = $_SESSION['user_role'];

// 1) Totaux produits / catégories
$sqlTotalProd = "SELECT COUNT(*) AS total FROM produits";
$totalProduits = (int)$pdo->query($sqlTotalProd)->fetchColumn();

$sqlTotalCat = "SELECT COUNT(*) AS total FROM categories";
$totalCategories = (int)$pdo->query($sqlTotalCat)->fetchColumn();

// 2) Stock faible
$sqlStockFaible = "SELECT COUNT(*) AS nb FROM produits WHERE quantite > 0 AND quantite <= seuil_alerte";
$stockFaible = (int)$pdo->query($sqlStockFaible)->fetchColumn();

// 3) Ruptures
$sqlRuptures = "SELECT COUNT(*) AS nb FROM produits WHERE quantite = 0";
$ruptures = (int)$pdo->query($sqlRuptures)->fetchColumn();

// 4) Mouvements
$sqlMvts = "SELECT m.date_mouvement, m.type_mouvement, m.quantite, p.nom AS produit_nom
            FROM mouvements m JOIN produits p ON m.produit_id = p.id
            ORDER BY m.date_mouvement DESC LIMIT 5";
$stmtMvts = $pdo->query($sqlMvts);
$derniersMouvements = $stmtMvts->fetchAll(PDO::FETCH_ASSOC);
?>

<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>StockSmart - Tableau de bord</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>

<header>
    <h1>StockSmart - Tableau de Bord</h1>
</header>

<nav>
    <a href="index.php">Accueil</a>
    <a href="pages/produits.php">Produits</a>
    <a href="pages/categories.php">Catégories</a>
    <a href="pages/mouvements.php">Mouvements</a>
    <a href="pages/admin.php">Administration</a>
    <a href="pages/login.php">Connexion</a>
</nav>

<div class="container">

    <h2>Résumé</h2>

    <div class="resume-grid">
        <div class="resume-row">
            <div class="card">
                <h3>Total Produits</h3>
                <p id="totalProduits"><?php echo $totalProduits; ?></p>
            </div>

            <div class="card">
                <h3>Total Catégories</h3>
                <p id="totalCategories"><?php echo $totalCategories; ?></p>
            </div>
        </div>

        <div class="resume-row">
            <div class="card">
                <h3>Stock Faible</h3>
                <p id="stockFaible" class="alert"><?php echo $stockFaible; ?></p>
            </div>

            <div class="card">
                <h3>Produits en rupture</h3>
                <p id="ruptureStock" class="alert"><?php echo $ruptures; ?></p>
            </div>
        </div>
    </div>

    <section class="section-mouvements">
        <h2>Derniers Mouvements</h2>

        <table>
            <thead>
                <tr>
                    <th>Produit</th>
                    <th>Type</th>
                    <th>Quantité</th>
                    <th>Date</th>
                </tr>
            </thead>
            <tbody>
                <?php if (empty($derniersMouvements)) : ?>
                    <tr>
                        <td colspan="4" style="color:#6c6460; padding:18px;">
                            Aucun mouvement enregistré pour le moment.
                        </td>
                    </tr>
                <?php else : ?>
                    <?php foreach ($derniersMouvements as $mvt) : ?>
                        <tr>
                            <td><?php echo htmlspecialchars($mvt['produit_nom']); ?></td>
                            <td><?php echo htmlspecialchars(ucfirst($mvt['type_mouvement'])); ?></td>
                            <td><?php echo (int)$mvt['quantite']; ?></td>
                            <td><?php echo htmlspecialchars($mvt['date_mouvement']); ?></td>
                        </tr>
                    <?php endforeach; ?>
                <?php endif; ?>
            </tbody>
        </table>
    </section>

</div>

<footer>
    © 2026 StockSmart - Projet TD Web
</footer>

<script src="JavaScript/scrip.js"></script>

</body>
</html>
