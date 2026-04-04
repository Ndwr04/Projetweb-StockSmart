<?php
session_start();
require_once 'config.php';

$user_nom = $_SESSION['user_nom'] ?? 'Invité';
$user_role = $_SESSION['user_role'] ?? 'Utilisateur';

function h($str) {
    return htmlspecialchars($str ?? '', ENT_QUOTES, 'UTF-8');
}

function isAdmin() {
    return ($_SESSION['user_role'] ?? '') === 'admin';
}

// 1) Totaux produits / catégories
$sqlTotalProd = "SELECT COUNT(*) FROM produits";
$totalProduits = (int)$pdo->query($sqlTotalProd)->fetchColumn();

$sqlTotalCat = "SELECT COUNT(*) FROM categories";
$totalCategories = (int)$pdo->query($sqlTotalCat)->fetchColumn();

// 2) Stock faible
$sqlStockFaible = "SELECT COUNT(*) FROM produits WHERE quantite > 0 AND quantite <= seuil_alerte";
$stockFaible = (int)$pdo->query($sqlStockFaible)->fetchColumn();

// 3) Ruptures
$sqlRuptures = "SELECT COUNT(*) FROM produits WHERE quantite = 0";
$ruptures = (int)$pdo->query($sqlRuptures)->fetchColumn();

// 4) Valeur totale du stock
$valeurStock = (float)($pdo->query("SELECT COALESCE(SUM(prix * quantite), 0) FROM produits")->fetchColumn());

// 5) Mouvements
$sqlMvts = "SELECT m.date_mouvement, m.type_mouvement, m.quantite, p.nom AS produit_nom
            FROM mouvements m
            INNER JOIN produits p ON m.produit_id = p.id
            ORDER BY m.date_mouvement DESC
            LIMIT 8";
$derniersMouvements = $pdo->query($sqlMvts)->fetchAll(PDO::FETCH_ASSOC);

// 6) Produits en alerte
$produitsAlerte = $pdo->query("
    SELECT p.nom, p.quantite, p.seuil_alerte, c.nom AS categorie
    FROM produits p
    LEFT JOIN categories c ON p.categorie_id = c.id
    WHERE p.quantite <= p.seuil_alerte
    ORDER BY p.quantite ASC
    LIMIT 5
")->fetchAll(PDO::FETCH_ASSOC);
?>

<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>StockSmart — Tableau de bord</title>
    <link rel="stylesheet" href="css/style.css">
</head>
<body>

<header>
    <h1>📦 StockSmart</h1>
</header>

<nav>
    <a href="index.php">🏠 Accueil</a>
    <a href="pages/produits.php">📦 Produits</a>
    <a href="pages/categories.php">📂 Catégories</a>
    <a href="pages/mouvements.php">📈 Mouvements</a>
    <?php if (isAdmin()): ?>
        <a href="pages/admin.php">⚙️ Admin</a>
    <?php endif; ?>
    <a href="pages/logout.php">🚪 Déconnexion (<?= h($user_nom) ?>)</a>
</nav>

<div class="page-entity">

    <h2>👋 Bonjour <?= h($user_nom) ?> <small style="font-size:14px;color:var(--muted);">(<?= h($user_role) ?>)</small></h2>

    <!-- CARTES RÉSUMÉ -->
    <div class="resume-grid">
        <div class="resume-row">
            <div class="card">
                <h3>📦 Total Produits</h3>
                <p><?= $totalProduits ?></p>
            </div>
            <div class="card">
                <h3>📂 Catégories</h3>
                <p><?= $totalCategories ?></p>
            </div>
            <div class="card">
                <h3>💰 Valeur stock</h3>
                <p style="font-size:20px;"><?= number_format($valeurStock, 2, ',', ' ') ?> €</p>
            </div>
        </div>
        <div class="resume-row">
            <div class="card">
                <h3>⚠️ Stock faible</h3>
                <p class="alert"><?= $stockFaible ?></p>
            </div>
            <div class="card">
                <h3>🚨 Ruptures</h3>
                <p class="alert"><?= $ruptures ?></p>
            </div>
        </div>
    </div>

    <!-- PRODUITS EN ALERTE -->
    <?php if ($stockFaible > 0 || $ruptures > 0): ?>
    <div class="section">
        <h3>🚨 Produits nécessitant attention</h3>
        <table>
            <thead>
                <tr>
                    <th>Produit</th>
                    <th>Catégorie</th>
                    <th>Stock actuel</th>
                    <th>Seuil alerte</th>
                    <th>État</th>
                </tr>
            </thead>
            <tbody>
                <?php foreach ($produitsAlerte as $p): ?>
                <tr>
                    <td><strong><?= h($p['nom']) ?></strong></td>
                    <td><?= h($p['categorie'] ?? '-') ?></td>
                    <td>
                        <span class="badge <?= $p['quantite'] == 0 ? 'badge-danger' : 'badge-warn' ?>">
                            <?= $p['quantite'] ?>
                        </span>
                    </td>
                    <td><?= $p['seuil_alerte'] ?></td>
                    <td>
                        <span class="badge <?= $p['quantite'] == 0 ? 'badge-danger' : 'badge-warn' ?>">
                            <?= $p['quantite'] == 0 ? '🚨 Rupture' : '⚠️ Faible' ?>
                        </span>
                    </td>
                </tr>
                <?php endforeach; ?>
            </tbody>
        </table>
    </div>
    <?php endif; ?>

    <!-- DERNIERS MOUVEMENTS -->
    <div class="section">
        <h3>📋 Derniers mouvements</h3>
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
                <?php if (empty($derniersMouvements)): ?>
                    <tr>
                        <td colspan="4" style="color:var(--muted);padding:18px;">
                            Aucun mouvement enregistré pour le moment.
                        </td>
                    </tr>
                <?php else: ?>
                    <?php foreach ($derniersMouvements as $m): ?>
                    <tr>
                        <td><?= h($m['produit_nom']) ?></td>
                        <td>
                            <span class="badge <?= $m['type_mouvement'] === 'entree' ? 'badge-success' : 'badge-danger' ?>">
                                <?= $m['type_mouvement'] === 'entree' ? '📥 Entrée' : '📤 ' . ucfirst(h($m['type_mouvement'])) ?>
                            </span>
                        </td>
                        <td><?= (int)$m['quantite'] ?></td>
                        <td><?= h($m['date_mouvement']) ?></td>
                    </tr>
                    <?php endforeach; ?>
                <?php endif; ?>
            </tbody>
        </table>
    </div>

</div>

<footer>© 2026 StockSmart — Projet TD Web</footer>
<script src="JavaScript/scrip.js"></script>
</body>
</html>
