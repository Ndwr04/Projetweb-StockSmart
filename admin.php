<?php
session_start();
require_once '../config.php';

if (!isset($_SESSION['user_id']) || $_SESSION['user_role'] != 'admin') {
    header('Location: ../pages/login.php');
    exit();
}

// SUPPRESSION USER
if (isset($_GET['supp_user'])) {
    $id = (int) $_GET['supp_user'];

    if ($_SESSION['user_id'] != $id) {
        $pdo->prepare("DELETE FROM utilisateurs WHERE id = ?")->execute([$id]);
        $success = "Utilisateur supprimé !";
    }
}

// STATS GLOBALES
$nb_users = $pdo->query("SELECT COUNT(*) FROM utilisateurs")->fetchColumn();
$nb_produits = $pdo->query("SELECT COUNT(*) FROM produits")->fetchColumn();
$nb_categories = $pdo->query("SELECT COUNT(*) FROM categories")->fetchColumn();
$nb_mouvements = $pdo->query("SELECT COUNT(*) FROM mouvements")->fetchColumn();

// UTILISATEURS
$utilisateurs = $pdo->query("
    SELECT id, nom, prenom, email, role, created_at
    FROM utilisateurs
    ORDER BY role DESC, nom ASC
")->fetchAll(PDO::FETCH_ASSOC);
?>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Administration - StockSmart</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="../css/style.css">
</head>
<body>
    <nav class="navbar navbar-expand-lg navbar-dark bg-dark">
        <div class="container">
            <a class="navbar-brand" href="../dashboard.php">📦 StockSmart Admin</a>
            <div class="navbar-nav">
                <a class="nav-link" href="../dashboard.php">Dashboard</a>
                <a class="nav-link" href="../pages/produits.php">Produits</a>
                <a class="nav-link active" href="admin.php">Administration</a>
                <a class="nav-link" href="../pages/logout.php">Déconnexion</a>
            </div>
        </div>
    </nav>

    <div class="container mt-4">
        <h1>⚙️ Panneau d'administration</h1>

        <?php if (isset($success)): ?>
            <div class="alert alert-success"><?= htmlspecialchars($success) ?></div>
        <?php endif; ?>

        <div class="row mb-5">
            <div class="col-md-3">
                <div class="card p-3 text-center bg-primary text-white">
                    <h2><?= $nb_produits ?></h2>
                    <small>Produits</small>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card p-3 text-center bg-success text-white">
                    <h2><?= $nb_categories ?></h2>
                    <small>Catégories</small>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card p-3 text-center bg-warning text-white">
                    <h2><?= $nb_mouvements ?></h2>
                    <small>Mouvements</small>
                </div>
            </div>
            <div class="col-md-3">
                <div class="card p-3 text-center bg-info text-white">
                    <h2><?= $nb_users ?></h2>
                    <small>Utilisateurs</small>
                </div>
            </div>
        </div>

        <div class="card mb-5">
            <div class="card-header bg-danger text-white">
                <h4 class="mb-0">👥 Gestion des utilisateurs</h4>
            </div>
            <div class="card-body">
                <div class="table-responsive">
                    <table class="table table-hover align-middle">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Nom</th>
                                <th>Email</th>
                                <th>Rôle</th>
                                <th>Inscrit le</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php foreach ($utilisateurs as $user): ?>
                                <tr>
                                    <td><strong>#<?= (int)$user['id'] ?></strong></td>
                                    <td><?= htmlspecialchars(($user['prenom'] ?? '') . ' ' . ($user['nom'] ?? '')) ?></td>
                                    <td><?= htmlspecialchars($user['email']) ?></td>
                                    <td>
                                        <?php
                                        if ($user['role'] === 'admin') {
                                            $badge = 'danger';
                                        } elseif ($user['role'] === 'gerant') {
                                            $badge = 'warning';
                                        } elseif ($user['role'] === 'chef_rayon') {
                                            $badge = 'primary';
                                        } elseif ($user['role'] === 'magasinier') {
                                            $badge = 'success';
                                        } elseif ($user['role'] === 'caissier') {
                                            $badge = 'info';
                                        } else {
                                            $badge = 'secondary';
                                        }
                                        ?>
                                        <span class="badge bg-<?= $badge ?>"><?= htmlspecialchars(ucfirst(str_replace('_', ' ', $user['role']))) ?></span>
                                    </td>
                                    <td>
                                        <?= !empty($user['created_at']) ? date('d/m/Y', strtotime($user['created_at'])) : '-' ?>
                                    </td>
                                    <td>
                                        <?php if ($_SESSION['user_id'] != $user['id']): ?>
                                            <a href="?supp_user=<?= (int)$user['id'] ?>"
                                               class="btn btn-sm btn-outline-danger"
                                               onclick="return confirm('Supprimer <?= htmlspecialchars($user['prenom']) ?> ?')">
                                                🗑️
                                            </a>
                                        <?php else: ?>
                                            <span class="text-muted">Compte actuel</span>
                                        <?php endif; ?>
                                    </td>
                                </tr>
                            <?php endforeach; ?>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>

        <div class="row">
            <div class="col-md-4">
                <div class="card text-center h-100">
                    <div class="card-body">
                        <h5>🔄 Vider les données</h5>
                        <p class="text-muted">TRUNCATE toutes les tables</p>
                        <a href="#" class="btn btn-danger w-100" onclick="confirmReset()">⚠️ Reset</a>
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card text-center h-100">
                    <div class="card-body">
                        <h5>📊 Backup SQL</h5>
                        <p class="text-muted">Télécharger dump complet</p>
                        <a href="#" class="btn btn-secondary w-100">💾 Backup</a>
                    </div>
                </div>
            </div>
            <div class="col-md-4">
                <div class="card text-center h-100">
                    <div class="card-body">
                        <h5>🔧 Config système</h5>
                        <p class="text-muted">Paramètres avancés</p>
                        <a href="#" class="btn btn-info w-100">⚙️ Config</a>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <script>
        function confirmReset() {
            if (confirm('⚠️ Vider TOUTES les données ?')) {
                alert('Fonctionnalité à implémenter');
            }
        }
    </script>
</body>
</html>




