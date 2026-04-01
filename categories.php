<?php
require_once '../config.php';

// AJOUT
if (isset($_POST['ajouter'])) {
    $nom = trim($_POST['nom']);
    if ($nom !== '') {
        $sql = "INSERT INTO categories (nom) VALUES (?)";
        $pdo->prepare($sql)->execute([$nom]);
        $success = "Catégorie <strong>" . htmlspecialchars($nom) . "</strong> ajoutée !";
    } else {
        $error = "Le nom de la catégorie ne peut pas être vide.";
    }
}

// SUPPRESSION
if (isset($_GET['supprimer'])) {
    $id = $_GET['supprimer'];
    $sql = $pdo->prepare("SELECT COUNT(*) FROM produits WHERE categorie_id = ?");
    $sql->execute([$id]);
    if ($sql->fetchColumn() == 0) {
        $pdo->prepare("DELETE FROM categories WHERE id = ?")->execute([$id]);
        $success = "Catégorie supprimée !";
    } else {
        $error = "Impossible : catégorie utilisée par des produits !";
    }
}

$categories = $pdo->query("SELECT * FROM categories ORDER BY nom")->fetchAll();
?>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Catégories - StockSmart</title>
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
    <h2>📂 Gestion des catégories</h2>

    <?php if (isset($success)): ?>
        <div class="msg-success"><?= $success ?></div>
    <?php endif; ?>

    <?php if (isset($error)): ?>
        <div class="msg-error"><?= $error ?></div>
    <?php endif; ?>

    <!-- Liste des catégories -->
    <div class="section">
        <h3>📋 Catégories (<?= count($categories) ?>)</h3>

        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Nom</th>
                    <th>Produits</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
            <?php foreach ($categories as $cat): ?>
                <tr>
                    <td><strong>#<?= $cat['id'] ?></strong></td>
                    <td><?= htmlspecialchars($cat['nom']) ?></td>
                    <td>
                        <?php
                        $nb = $pdo->prepare("SELECT COUNT(*) FROM produits WHERE categorie_id = ?");
                        $nb->execute([$cat['id']]);
                        echo $nb->fetchColumn();
                        ?>
                    </td>
                    <td>
                        <a href="?supprimer=<?= $cat['id'] ?>"
                           class="btn btn-sm btn-danger"
                           onclick="return confirm('Supprimer <?= htmlspecialchars($cat['nom']) ?> ?')">
                            🗑️ Supprimer
                        </a>
                    </td>
                </tr>
            <?php endforeach; ?>
            </tbody>
        </table>
    </div>

    <!-- Formulaire ajout catégorie -->
    <div class="section section-form">
        <h3>➕ Nouvelle catégorie</h3>

        <form method="POST" class="form-entity">
            <div class="form-group">
                <label for="nom">Nom de la catégorie</label>
                <input type="text" id="nom" name="nom" placeholder="Ex : Électronique" required>
            </div>

            <div class="form-actions">
                <button type="submit" name="ajouter" class="btn btn-sm">Ajouter</button>
            </div>
        </form>
    </div>
</div>

<footer>
    © 2026 StockSmart - Projet TD Web
</footer>

</body>
</html>
