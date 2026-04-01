<!DOCTYPE html>
<html lang="fr">
<head>
  <meta charset="UTF-8">
  <title>Ajouter Mouvement - StockSmart</title>
  <link rel="stylesheet" href="../css/style.css">
</head>

<body>

<header>
  <h1>StockSmart</h1>
</header>

<nav>
  <a href="../index.html">Accueil</a>
  <a href="produits.html">Produits</a>
  <a href="categories.html">Catégories</a>
  <a href="mouvements.html">Mouvements</a>
  <a href="login.html">Connexion</a>
</nav>

<div class="container">
  <h2>Nouveau mouvement de stock</h2>

  <div class="form-wrap">
    <form>
      <!-- Les listes seront remplies via BDD plus tard -->

      <label for="produit">Produit :</label>
      <select id="produit" required>
        <option value="">Sélectionner un produit</option>
      </select>

      <label for="type">Type de mouvement :</label>
      <select id="type" required>
        <option value="entree">Entrée (Approvisionnement)</option>
        <option value="vente">Sortie - Vente</option>
        <option value="perte">Sortie - Perte</option>
        <option value="casse">Sortie - Casse</option>
      </select>

      <label for="quantite">Quantité :</label>
      <input id="quantite" type="number" min="1" required>

      <label for="date">Date :</label>
      <input id="date" type="date">

      <label for="commentaire">Commentaire :</label>
      <input id="commentaire" type="text" placeholder="Optionnel">
      <label for="quantite">Quantité :</label>
      <div style="display:flex; gap:8px; align-items:center;">
        <button type="button" onclick="diminuer()">-</button>
        <input id="quantite" type="number" min="0" value="0" required>
        <button type="button" onclick="augmenter()">+</button>
      </div>
      
      <button type="submit" class="btn">Enregistrer</button>
      <a href="mouvements.html" class="btn btn-secondary">Annuler</a>
    </form>
  </div>
</div>

<footer>
  © 2026 StockSmart - Projet TD Web
</footer>

</body>
</html>
