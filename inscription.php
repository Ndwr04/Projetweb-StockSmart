<?php
session_start();
require_once '../config.php';

if (isset($_SESSION['user_id'])) {
    header('Location: ../dashboard.php');
    exit();
}

$erreurs = [];
$champs = [
    'nom' => '',
    'prenom' => '',
    'email' => '',
    'role' => ''
];

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $nom = trim($_POST['nom'] ?? '');
    $prenom = trim($_POST['prenom'] ?? '');
    $email = trim($_POST['email'] ?? '');
    $password = $_POST['password'] ?? '';
    $role = $_POST['role'] ?? '';

    if (empty($nom)) $erreurs['nom'] = "Nom obligatoire.";
    if (empty($prenom)) $erreurs['prenom'] = "Prénom obligatoire.";
    if (empty($email) || !filter_var($email, FILTER_VALIDATE_EMAIL)) $erreurs['email'] = "Email invalide.";
    if (strlen($password) < 6) $erreurs['password'] = "Mot de passe : 6 caractères minimum.";
    if (!in_array($role, ['admin', 'employe'])) $erreurs['role'] = "Veuillez choisir un rôle valide.";

    if (empty($erreurs)) {
        $stmt = $pdo->prepare("SELECT id FROM utilisateurs WHERE email = ?");
        $stmt->execute([$email]);

        if ($stmt->fetch()) {
            $erreurs['email'] = "Cet email est déjà utilisé.";
        }
    }

    if (empty($erreurs)) {
        $hash = password_hash($password, PASSWORD_DEFAULT);

        $stmt = $pdo->prepare("
            INSERT INTO utilisateurs (nom, prenom, email, mot_de_passe, role)
            VALUES (?, ?, ?, ?, ?)
        ");
        $stmt->execute([$nom, $prenom, $email, $hash, $role]);

        $_SESSION['user_id'] = $pdo->lastInsertId();
        $_SESSION['user_nom'] = $prenom . ' ' . $nom;
        $_SESSION['user_role'] = $role;

        header('Location: ../dashboard.php');
        exit();
    } else {
        $champs = [
            'nom' => $nom,
            'prenom' => $prenom,
            'email' => $email,
            'role' => $role
        ];
    }
}
?>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Inscription StockSmart</title>
    <link rel="stylesheet" href="../css/style.css">
    <style>
        .auth-page {
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 30px 16px;
            background: linear-gradient(135deg, #f6f3ef 0%, #ebe2dc 100%);
        }
        .auth-card {
            width: 100%;
            max-width: 580px;
            background: #fff;
            border-radius: 18px;
            box-shadow: 0 18px 50px rgba(0,0,0,0.10);
            padding: 36px 28px;
            border: 1px solid #e7dfda;
        }
        .auth-title {
            text-align: center;
            font-size: 34px;
            color: var(--primary-dark);
            margin-bottom: 8px;
            font-weight: 900;
        }
        .auth-subtitle {
            text-align: center;
            color: var(--muted);
            margin-bottom: 26px;
        }
        .auth-form {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 16px;
        }
        .auth-form .full {
            grid-column: 1 / -1;
        }
        .auth-form label {
            display: block;
            margin-bottom: 6px;
            font-weight: 800;
            color: var(--primary-dark);
        }
        .auth-form input,
        .auth-form select {
            width: 100%;
            padding: 12px 14px;
            border-radius: 12px;
            border: 1px solid #d9cfca;
            outline: none;
            font: inherit;
            background: #fff;
        }
        .auth-form input:focus,
        .auth-form select:focus {
            border-color: var(--primary);
            box-shadow: 0 0 0 3px rgba(138, 111, 99, 0.18);
        }
        .auth-btn {
            width: 100%;
            padding: 13px;
            font-size: 16px;
            margin-top: 6px;
        }
        .auth-links {
            text-align: center;
            margin-top: 18px;
            color: var(--muted);
        }
        .auth-back {
            text-align: center;
            margin-top: 10px;
        }

        @media (max-width: 768px) {
            .auth-form {
                grid-template-columns: 1fr;
            }
            .auth-form .full {
                grid-column: auto;
            }
        }
    </style>
</head>
<body>
    <main class="auth-page">
        <div class="auth-card">
            <h1 class="auth-title">Inscription</h1>
            <p class="auth-subtitle">Créez votre compte StockSmart</p>

            <?php if (!empty($erreurs)): ?>
                <div class="msg-error">
                    <?php foreach ($erreurs as $err): ?>
                        <p><?= htmlspecialchars($err) ?></p>
                    <?php endforeach; ?>
                </div>
            <?php endif; ?>

            <form method="POST" class="auth-form">
                <div>
                    <label for="nom">Nom</label>
                    <input type="text" id="nom" name="nom" value="<?= htmlspecialchars($champs['nom']) ?>" required>
                </div>

                <div>
                    <label for="prenom">Prénom</label>
                    <input type="text" id="prenom" name="prenom" value="<?= htmlspecialchars($champs['prenom']) ?>" required>
                </div>

                <div class="full">
                    <label for="email">Email</label>
                    <input type="email" id="email" name="email" value="<?= htmlspecialchars($champs['email']) ?>" required>
                </div>

                <div>
                    <label for="password">Mot de passe</label>
                    <input type="password" id="password" name="password" required minlength="6">
                </div>

                <div>
                    <label for="role">Rôle</label>
                    <select id="role" name="role" required>
                        <option value="">Choisir un rôle</option>
                        <option value="employe" <?= $champs['role'] === 'employe' ? 'selected' : '' ?>>Employé</option>
                        <option value="admin" <?= $champs['role'] === 'admin' ? 'selected' : '' ?>>Administrateur</option>
                    </select>
                </div>

                <div class="full">
                    <button type="submit" class="btn auth-btn">Créer mon compte</button>
                </div>
            </form>

            <p class="auth-links">
                Déjà un compte ? <a href="login.php">Se connecter</a>
            </p>

            <p class="auth-back">
                <a href="../index.php">← Retour à l’accueil</a>
            </p>
        </div>
    </main>
</body>
</html>





