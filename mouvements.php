<?php
require_once '../config.php';

$message = '';
$success = false;

if ($_POST) {
    $produit_id = $_POST['produit_id'];
    $type = $_POST['type_mouvement'];
    $quantite = (int)$_POST['quantite'];
    $commentaire = $_POST['commentaire'];

    // 1. Enregistrer le mouvement
    $sql = "INSERT INTO mouvements (produit_id, type_mouvement, quantite, commentaire) 
            VALUES (?, ?, ?, ?)";
    $pdo->prepare($sql)->execute([$produit_id, $type, $quantite, $commentaire]);

    // 2. Mettre à jour la quantité
    if ($type == 'entree') {
        $pdo->prepare("UPDATE produits SET quantite = quantite + ? WHERE id = ?")
            ->execute([$quantite, $produit_id]);
        $action = "ajouté";
    } else {
        $pdo->prepare("UPDATE produits SET quantite = quantite - ? WHERE id = ?")
            ->execute([$quantite, $produit_id]);
        $action = "retiré";
    }

    // Nom produit pour message
    $nom = $pdo->prepare("SELECT nom FROM produits WHERE id = ?");
    $nom->execute([$produit_id]);
    $nom_produit = $nom->fetchColumn();

    $message = "$quantite unité(s) de <strong>" . htmlspecialchars($nom_produit) . "</strong> $action avec succès !";
    $success = true;
}

// Liste des produits pour le select
$produits = $pdo->query("SELECT * FROM produits ORDER BY nom")->fetchAll();
?>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mouvements - StockSmart</title>
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>

<header>
    <h1>StockSmart</h1>
</header>

<nav>
    <a href="../index.php">Accueil</a>
    <a href="produits.php">Produits</a>
    <a href="categories.php">Catégories</a>
    <a href="mouvements.php">Mouvements</a>
</nav>

<div class="page-entity">
    <h2>📈 Mouvements de stock</h2>

    <?php if ($message): ?>
        <div class="<?= $success ? 'msg-success' : 'msg-error' ?>">
            <?= $message ?>
        </div>
    <?php endif; ?>

    <div class="section section-form">
        <h3>➕ Enregistrer un mouvement</h3>

        <form method="POST" class="form-entity">

            <div class="form-group">
                <label for="produit_id">Produit</label>
                <select id="produit_id" name="produit_id" required>
                    <option value="">Choisir un produit...</option>
                    <?php foreach ($produits as $p): ?>
                        <option value="<?= $p['id'] ?>">
                            <?= htmlspecialchars($p['nom']) ?> (Stock : <?= $p['quantite'] ?>)
                        </option>
                    <?php endforeach; ?>
                </select>
            </div>

            <div class="form-group">
                <label for="type_mouvement">Type de mouvement</label>
                <select id="type_mouvement" name="type_mouvement" required>
                    <option value="">Type...</option>
                    <option value="entree">📥 Entrée (approvisionnement)</option>
                    <option value="vente">🛒 Vente</option>
                    <option value="perte">📉 Perte</option>
                    <option value="casse">🔨 Casse</option>
                </select>
            </div>

            <div class="form-group">
                <label for="quantite">Quantité</label>
                <input type="number" id="quantite" name="quantite" min="1" required>
            </div>

            <div class="form-group" style="grid-column: 1 / -1;">
                <label for="commentaire">Commentaire (optionnel)</label>
                <input type="text" id="commentaire" name="commentaire"
                       placeholder="ex : Commande client #123, livraison fournisseur...">
            </div>

            <div class="form-actions">
                <button type="submit" class="btn btn-sm">Enregistrer</button>
            </div>
        </form>
    </div>
</div>

<footer>
    © 2026 StockSmart - Projet TD Web
</footer>

</body>
</html>
