<?php
session_start();

if (isset($_SESSION['user_id'])) {
    header('Location: dashboard.php');
    exit();
}
?>
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>StockSmart — Accueil</title>
    <link rel="stylesheet" href="css/style.css">
    <style>
        .home-hero {
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 40px 20px;
            background:
                linear-gradient(rgba(43,38,36,0.45), rgba(43,38,36,0.55)),
                linear-gradient(135deg, #8a6f63 0%, #6f564d 100%);
            color: white;
            text-align: center;
        }

        .home-box {
            max-width: 900px;
        }

        .home-logo {
            font-size: clamp(54px, 11vw, 120px);
            font-weight: 900;
            letter-spacing: 3px;
            line-height: 0.95;
            margin-bottom: 18px;
            text-transform: uppercase;
        }

        .home-logo span {
            display: block;
        }

        .home-subtitle {
            font-size: clamp(18px, 2.5vw, 28px);
            color: rgba(255,255,255,0.92);
            margin-bottom: 18px;
            font-weight: 500;
        }

        .home-text {
            max-width: 700px;
            margin: 0 auto 34px;
            font-size: 17px;
            color: rgba(255,255,255,0.86);
        }

        .home-actions {
            display: flex;
            justify-content: center;
            gap: 16px;
            flex-wrap: wrap;
        }

        .btn-home {
            min-width: 220px;
            padding: 14px 22px;
            border-radius: 14px;
            font-size: 16px;
            font-weight: 800;
            text-align: center;
            text-decoration: none;
            transition: transform 0.25s ease, box-shadow 0.25s ease, background 0.25s ease;
        }

        .btn-home:hover {
            transform: translateY(-3px);
            text-decoration: none;
        }

        .btn-home-primary {
            background: #fff;
            color: var(--primary-dark);
            box-shadow: 0 10px 30px rgba(0,0,0,0.18);
        }

        .btn-home-primary:hover {
            background: #f5f1ef;
        }

        .btn-home-secondary {
            background: rgba(255,255,255,0.12);
            color: #fff;
            border: 1px solid rgba(255,255,255,0.35);
            backdrop-filter: blur(6px);
        }

        .btn-home-secondary:hover {
            background: rgba(255,255,255,0.2);
        }

        @media (max-width: 768px) {
            .home-actions {
                flex-direction: column;
                align-items: center;
            }

            .btn-home {
                width: 100%;
                max-width: 320px;
            }
        }
    </style>
</head>
<body>
    <main class="home-hero">
        <div class="home-box">
            <h1 class="home-logo">
                <span>STOCK</span>
                <span>SMART</span>
            </h1>

            <p class="home-subtitle">La gestion de stock simple, claire et professionnelle</p>

            <p class="home-text">
                Suivez vos produits, vos catégories et vos mouvements en temps réel
                dans une interface moderne pensée pour les employés comme pour les administrateurs.
            </p>

            <div class="home-actions">
                <a href="pages/login.php" class="btn-home btn-home-primary">Se connecter</a>
                <a href="pages/inscription.php" class="btn-home btn-home-secondary">S’inscrire</a>
            </div>
        </div>
    </main>
</body>
</html>



