<?php
session_start();
require_once '../config.php';

if ($_SERVER["REQUEST_METHOD"] == "POST") {
    $email = $_POST['email'];
    $password = $_POST['mot_de_passe'];

    $stmt = $pdo->prepare("SELECT * FROM utilisateurs WHERE email = ?");
    $stmt->execute([$email]);
    $user = $stmt->fetch();

    if ($user && password_verify($password, $user['mot_de_passe'])) {
        $_SESSION['user_id'] = $user['id'];
        $_SESSION['user_nom'] = $user['prenom'] . ' ' . $user['nom'];
        $_SESSION['user_role'] = $user['role'];
        header("Location: ../index.php");
        exit();
    } else {
        echo "<p class='msg-error'>Email ou mot de passe incorrect.</p>";
    }
}
?>

<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Connexion StockSmart</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>.msg-error { color: #dc3545; background: #f8d7da; padding: 10px; border-radius: 5px; margin: 10px 0; }</style>
</head>
<body class="bg-light">
    <div class="container mt-5">
        <div class="row justify-content-center">
            <div class="col-md-6">
                <div class="card shadow">
                    <div class="card-body p-5">
                        <h3 class="text-center mb-4">🔐 Connexion</h3>
                        
                        <?php if ($_SERVER["REQUEST_METHOD"] == "POST"): ?>
                            <div class="alert alert-warning">
                                <strong>rose@test.com / password</strong>
                            </div>
                        <?php endif; ?>

                        <form method="POST">
                            <div class="mb-4">
                                <label class="form-label">Email</label>
                                <input type="email" class="form-control" name="email" required>
                            </div>
                            <div class="mb-4">
                                <label class="form-label">Mot de passe</label>
                                <input type="password" class="form-control" name="mot_de_passe" required>
                            </div>
                            <button type="submit" class="btn btn-primary w-100">Se connecter</button>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
</body>
</html>
