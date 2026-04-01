<?php
session_start();
require_once '../config.php';

$erreurs = [];
$champs = ['nom' => '', 'prenom' => '', 'email' => ''];

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $nom = trim($_POST['nom'] ?? '');
    $prenom = trim($_POST['prenom'] ?? '');
    $email = trim($_POST['email'] ?? '');
    $password = $_POST['password'] ?? '';
    
    // VALIDATIONS
    if (empty($nom)) $erreurs['nom'] = "Nom obligatoire";
    if (empty($prenom)) $erreurs['prenom'] = "Prénom obligatoire";
    if (empty($email) || !filter_var($email, FILTER_VALIDATE_EMAIL)) $erreurs['email'] = "Email invalide";
    if (strlen($password) < 6) $erreurs['password'] = "Mot de passe (6 caractères min)";
    
    // Vérifie si email existe déjà
    if (empty($erreurs)) {
        $stmt = $pdo->prepare("SELECT id FROM utilisateurs WHERE email = ?");
        $stmt->execute([$email]);
        if ($stmt->fetch()) {
            $erreurs['email'] = "Email déjà utilisé";
        }
    }
    
    // CRÉE LE COMPTE (rôle employe par défaut)
    if (empty($erreurs)) {
        $hash = password_hash($password, PASSWORD_DEFAULT);
        $stmt = $pdo->prepare("INSERT INTO utilisateurs (nom, prenom, email, mot_de_passe, role) VALUES (?, ?, ?, ?, 'employe')");
        $stmt->execute([$nom, $prenom, $email, $hash]);
        
        $_SESSION['user_id'] = $pdo->lastInsertId();
        $_SESSION['user_nom'] = "$nom $prenom";
        $_SESSION['user_role'] = 'employe';
        
        header('Location: ../index.php');
        exit();
    } else {
        $champs = ['nom' => $nom, 'prenom' => $prenom, 'email' => $email];
    }
}
?>

<!DOCTYPE html>
<html>
<head>
    <title>Inscription StockSmart</title>
</head>
<body>
    <h2>Créer un compte</h2>
    
    <form method="POST">
        <div>
            <label>Nom *</label>
            <input type="text" name="nom" value="<?= htmlspecialchars($champs['nom']) ?>" required>
            <?php if (isset($erreurs['nom'])): ?><span style="color:red"><?= $erreurs['nom'] ?></span><?php endif; ?>
        </div>
        
        <div>
            <label>Prénom *</label>
            <input type="text" name="prenom" value="<?= htmlspecialchars($champs['prenom']) ?>" required>
            <?php if (isset($erreurs['prenom'])): ?><span style="color:red"><?= $erreurs['prenom'] ?></span><?php endif; ?>
        </div>
        
        <div>
            <label>Email *</label>
            <input type="email" name="email" value="<?= htmlspecialchars($champs['email']) ?>" required>
            <?php if (isset($erreurs['email'])): ?><span style="color:red"><?= $erreurs['email'] ?></span><?php endif; ?>
        </div>
        
        <div>
            <label>Mot de passe *</label>
            <input type="password" name="password" required>
            <?php if (isset($erreurs['password'])): ?><span style="color:red"><?= $erreurs['password'] ?></span><?php endif; ?>
        </div>
        
        <button type="submit">Créer mon compte</button>
    </form>
    
    <p>Déjà un compte ? <a href="login.php">Se connecter</a></p>
</body>
</html>
