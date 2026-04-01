<?php
require_once '../config.php';

error_reporting(E_ALL);
ini_set('display_errors', 1);

$success = null;
$error = null;

$uploadDir = '../images/produits/';
$uploadDbPath = 'images/produits/';
$allowedExtensions = ['jpg', 'jpeg', 'png', 'webp'];

if (!is_dir($uploadDir)) {
    mkdir($uploadDir, 0777, true);
}

function uploadImageProduit($file, $uploadDir, $uploadDbPath, $allowedExtensions) {
    if (!isset($file) || $file['error'] === UPLOAD_ERR_NO_FILE) {
        return [true, null];
    }

    if ($file['error'] !== UPLOAD_ERR_OK) {
        return [false, "Erreur lors de l'envoi de l'image."];
    }

    $extension = strtolower(pathinfo($file['name'], PATHINFO_EXTENSION));
    if (!in_array($extension, $allowedExtensions, true)) {
        return [false, "Format image invalide. Formats autorisés : jpg, jpeg, png, webp."];
    }

    if ($file['size'] > 2 * 1024 * 1024) {
        return [false, "Image trop lourde. Taille max : 2 Mo."];
    }

    $check = @getimagesize($file['tmp_name']);
    if ($check === false) {
        return [false, "Le fichier envoyé n'est pas une image valide."];
    }

    $safeName = uniqid('prod_', true) . '.' . $extension;
    $destination = $uploadDir . $safeName;

    if (!move_uploaded_file($file['tmp_name'], $destination)) {
        return [false, "Impossible d'enregistrer l'image sur le serveur."];
    }

    return [true, $uploadDbPath . $safeName];
}

// AJOUT PRODUIT
if (isset($_POST['ajouter'])) {
    $ref = trim($_POST['reference']);
    $nom = trim($_POST['nom']);
    $cat = (int)($_POST['categorie_id'] ?? 0);
    $qte = (int)($_POST['quantite'] ?? 0);
    $seuil = (int)($_POST['seuil_alerte'] ?? 0);
    $prix = (float)($_POST['prix'] ?? 0);

    [$okUpload, $imagePathOrError] = uploadImageProduit($_FILES['image'] ?? null, $uploadDir, $uploadDbPath, $allowedExtensions);

    if (!$okUpload) {
        $error = $imagePathOrError;
    } else {
        $image = $imagePathOrError ?: 'images/produits/no-image.jpg';

        $sql = "INSERT INTO produits (reference, nom, categorie_id, quantite, seuil_alerte, prix, image)
                VALUES (?, ?, ?, ?, ?, ?, ?)";
        $stmt = $pdo->prepare($sql);
        $stmt->execute([$ref, $nom, $cat, $qte, $seuil, $prix, $image]);

        $success = "Produit <strong>" . htmlspecialchars($nom, ENT_QUOTES, 'UTF-8') . "</strong> ajouté !";
    }
}

// SUPPRESSION
if (isset($_GET['supprimer'])) {
    $id = (int)$_GET['supprimer'];

    $stmt = $pdo->prepare("SELECT image, nom FROM produits WHERE id = ?");
    $stmt->execute([$id]);
    $produitASupprimer = $stmt->fetch();

    if ($produitASupprimer) {
        $sql = "DELETE FROM produits WHERE id = ?";
        $stmt = $pdo->prepare($sql);
        $stmt->execute([$id]);

        if (!empty($produitASupprimer['image']) && $produitASupprimer['image'] !== 'images/produits/no-image.jpg') {
            $imageFile = '../' . $produitASupprimer['image'];
            if (file_exists($imageFile)) {
                @unlink($imageFile);
            }
        }

        $success = "Produit supprimé !";
    }
}

// ÉDITION
if (isset($_POST['modifier'])) {
    $id = (int)$_POST['id'];
    $ref = trim($_POST['reference']);
    $nom = trim($_POST['nom']);
    $cat = (int)($_POST['categorie_id'] ?? 0);
    $qte = (int)($_POST['quantite'] ?? 0);
    $seuil = (int)($_POST['seuil_alerte'] ?? 0);
    $prix = (float)($_POST['prix'] ?? 0);
    $ancienneImage = $_POST['ancienne_image'] ?? 'images/produits/no-image.jpg';

    $nouvelleImage = $ancienneImage;

    if (isset($_FILES['image']) && $_FILES['image']['error'] !== UPLOAD_ERR_NO_FILE) {
        [$okUpload, $imagePathOrError] = uploadImageProduit($_FILES['image'], $uploadDir, $uploadDbPath, $allowedExtensions);

        if (!$okUpload) {
            $error = $imagePathOrError;
        } else {
            $nouvelleImage = $imagePathOrError;

            if (!empty($ancienneImage) && $ancienneImage !== 'images/produits/no-image.jpg') {
                $ancienneImageFile = '../' . $ancienneImage;
                if (file_exists($ancienneImageFile)) {
                    @unlink($ancienneImageFile);
                }
            }
        }
    }

    if (!$error) {
        $sql = "UPDATE produits 
                SET reference = ?, nom = ?, categorie_id = ?, quantite = ?, seuil_alerte = ?, prix = ?, image = ?
                WHERE id = ?";
        $stmt = $pdo->prepare($sql);
        $stmt->execute([$ref, $nom, $cat, $qte, $seuil, $prix, $nouvelleImage, $id]);

        $success = "Produit <strong>" . htmlspecialchars($nom, ENT_QUOTES, 'UTF-8') . "</strong> modifié !";
    }
}

// Récup produits + catégories
$produits = $pdo->query("
    SELECT p.*, c.nom as categorie_nom
    FROM produits p
    LEFT JOIN categories c ON p.categorie_id = c.id
    ORDER BY p.nom
")->fetchAll();

$categories = $pdo->query("SELECT * FROM categories ORDER BY nom")->fetchAll();

// Produit à éditer
$edit_produit = null;
if (isset($_GET['edit'])) {
    $id = (int)$_GET['edit'];
    $stmt = $pdo->prepare("SELECT * FROM produits WHERE id = ?");
    $stmt->execute([$id]);
    $edit_produit = $stmt->fetch();
}
?>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Produits - StockSmart</title>
    <link rel="stylesheet" href="../css/style.css">
    <style>
        .img-produit {
            width: 70px;
            height: 70px;
            object-fit: cover;
            border-radius: 8px;
            border: 1px solid #ddd;
            background: #f5f5f5;
        }

        .msg-error {
            background: #fde2e2;
            color: #a40000;
            padding: 12px;
            border-radius: 8px;
            margin-bottom: 15px;
        }

        .preview-image {
            margin-top: 10px;
        }

        .preview-image img {
            width: 90px;
            height: 90px;
            object-fit: cover;
            border-radius: 8px;
            border: 1px solid #ccc;
        }
    </style>
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
    <h2>📦 Gestion des produits</h2>

    <?php if ($success): ?>
        <div class="msg-success"><?= $success ?></div>
    <?php endif; ?>

    <?php if ($error): ?>
        <div class="msg-error"><?= htmlspecialchars($error, ENT_QUOTES, 'UTF-8') ?></div>
    <?php endif; ?>

    <div class="section section-form">
        <h3><?= $edit_produit ? '✏️ Modifier un produit' : '➕ Ajouter un produit' ?></h3>

        <form method="POST" class="form-entity" enctype="multipart/form-data">
            <?php if ($edit_produit): ?>
                <input type="hidden" name="id" value="<?= $edit_produit['id'] ?>">
                <input type="hidden" name="ancienne_image" value="<?= htmlspecialchars($edit_produit['image'] ?? 'images/produits/no-image.jpg', ENT_QUOTES, 'UTF-8') ?>">
            <?php endif; ?>

            <div class="form-group">
                <label for="reference">Référence</label>
                <input type="text" id="reference" name="reference"
                       value="<?= htmlspecialchars($edit_produit['reference'] ?? '', ENT_QUOTES, 'UTF-8') ?>" required>
            </div>

            <div class="form-group">
                <label for="nom">Nom</label>
                <input type="text" id="nom" name="nom"
                       value="<?= htmlspecialchars($edit_produit['nom'] ?? '', ENT_QUOTES, 'UTF-8') ?>" required>
            </div>

            <div class="form-group">
                <label for="categorie_id">Catégorie</label>
                <select id="categorie_id" name="categorie_id" required>
                    <option value="">Choisir une catégorie...</option>
                    <?php foreach ($categories as $cat): ?>
                        <option value="<?= $cat['id'] ?>"
                            <?= ($edit_produit && $edit_produit['categorie_id'] == $cat['id']) ? 'selected' : '' ?>>
                            <?= htmlspecialchars($cat['nom'], ENT_QUOTES, 'UTF-8') ?>
                        </option>
                    <?php endforeach; ?>
                </select>
            </div>

            <div class="form-group">
                <label for="quantite">Quantité</label>
                <input type="number" id="quantite" name="quantite" min="0"
                       value="<?= htmlspecialchars($edit_produit['quantite'] ?? '0', ENT_QUOTES, 'UTF-8') ?>" required>
            </div>

            <div class="form-group">
                <label for="seuil_alerte">Seuil d'alerte</label>
                <input type="number" id="seuil_alerte" name="seuil_alerte" min="0"
                       value="<?= htmlspecialchars($edit_produit['seuil_alerte'] ?? '0', ENT_QUOTES, 'UTF-8') ?>" required>
            </div>

            <div class="form-group">
                <label for="prix">Prix (€)</label>
                <input type="number" id="prix" name="prix" min="0" step="0.01"
                       value="<?= htmlspecialchars($edit_produit['prix'] ?? '0', ENT_QUOTES, 'UTF-8') ?>" required>
            </div>

            <div class="form-group">
                <label for="image">Image du produit</label>
                <input type="file" id="image" name="image" accept=".jpg,.jpeg,.png,.webp">
                <small>Formats autorisés : jpg, jpeg, png, webp. Taille max : 2 Mo.</small>

                <?php if ($edit_produit && !empty($edit_produit['image'])): ?>
                    <div class="preview-image">
                        <p>Image actuelle :</p>
                        <img src="../<?= htmlspecialchars($edit_produit['image'], ENT_QUOTES, 'UTF-8') ?>"
                             alt="<?= htmlspecialchars($edit_produit['nom'], ENT_QUOTES, 'UTF-8') ?>">
                    </div>
                <?php endif; ?>
            </div>

            <div class="form-actions">
                <button type="submit" name="<?= $edit_produit ? 'modifier' : 'ajouter' ?>" class="btn btn-sm">
                    <?= $edit_produit ? '✏️ Modifier' : '➕ Ajouter' ?>
                </button>
                <?php if ($edit_produit): ?>
                    <a href="produits.php" class="btn btn-secondary btn-sm">❌ Annuler</a>
                <?php endif; ?>
            </div>
        </form>
    </div>

    <div class="section">
        <h3>📋 Liste des produits (<?= count($produits) ?>)</h3>

        <table>
            <thead>
                <tr>
                    <th>Image</th>
                    <th>Référence</th>
                    <th>Nom</th>
                    <th>Catégorie</th>
                    <th>Quantité</th>
                    <th>Seuil</th>
                    <th>Prix</th>
                    <th>Actions</th>
                </tr>
            </thead>
            <tbody>
            <?php foreach ($produits as $produit): ?>
                <tr class="<?= $produit['quantite'] <= $produit['seuil_alerte'] ? 'alert' : '' ?>">
                    <td>
                        <img class="img-produit"
                             src="../<?= htmlspecialchars($produit['image'] ?? 'images/produits/no-image.jpg', ENT_QUOTES, 'UTF-8') ?>"
                             alt="<?= htmlspecialchars($produit['nom'], ENT_QUOTES, 'UTF-8') ?>">
                    </td>
                    <td><strong><?= htmlspecialchars($produit['reference'], ENT_QUOTES, 'UTF-8') ?></strong></td>
                    <td><?= htmlspecialchars($produit['nom'], ENT_QUOTES, 'UTF-8') ?></td>
                    <td><?= htmlspecialchars($produit['categorie_nom'] ?? 'Non classé', ENT_QUOTES, 'UTF-8') ?></td>
                    <td>
                        <span class="badge <?= $produit['quantite'] <= $produit['seuil_alerte'] ? 'badge-danger' : 'badge-success' ?>">
                            <?= $produit['quantite'] ?>
                        </span>
                    </td>
                    <td><?= $produit['seuil_alerte'] ?></td>
                    <td>€<?= number_format((float)$produit['prix'], 2, ',', ' ') ?></td>
                    <td>
                        <a href="?edit=<?= $produit['id'] ?>" class="btn btn-sm">✏️ Modifier</a>
                        <a href="?supprimer=<?= $produit['id'] ?>"
                           class="btn btn-sm btn-danger"
                           onclick="return confirm('Supprimer <?= htmlspecialchars($produit['nom'], ENT_QUOTES, 'UTF-8') ?> ?')">
                            🗑️ Supprimer
                        </a>
                    </td>
                </tr>
            <?php endforeach; ?>
            </tbody>
        </table>
    </div>
</div>

<footer>
    © 2026 StockSmart - Projet TD Web
</footer>

</body>
</html>
