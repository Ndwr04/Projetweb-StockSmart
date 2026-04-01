/* =========================================================
   STOCKSMART - JAVASCRIPT (SANS VALEURS STATIQUES)
   ========================================================= */

   console.log("scrip.js chargé");

// =======================
// DONNÉES FICTIVES
// =======================
const produitsSimules = [
  { ref: "P001", nom: "Jus d'orange", categorie: "Boissons", quantite: 5, seuil: 5, prix: 2.50 },
  { ref: "P002", nom: "Eau minérale", categorie: "Boissons", quantite: 20, seuil: 5, prix: 1.00 },
  { ref: "P003", nom: "Chips salés", categorie: "Snacks", quantite: 3, seuil: 5, prix: 1.80 }
];

const categoriesSimulees = [
  { id: 1, nom: "Boissons" },
  { id: 2, nom: "Snacks" }
];

// =======================
// Fin des DONNÉES FICTIVES

// AFFICHAGE PRODUITS
// =======================
function afficherProduitsSimules() {
    const tbody = document.querySelector("table tbody");
    // On vérifie qu'on est bien sur la page products.html
    if (!tbody || !window.location.pathname.includes("produits.html")) {
        console.log("Pas sur products.html, afficherProduitsSimules ne fait rien.");
        return;
    }

    console.log("Affichage des produits simulés...");

    if (produitsSimules.length === 0) {
        return;
    }

    // Effacer la ligne "Aucun produit pour le moment."
    tbody.innerHTML = "";

    produitsSimules.forEach(p => {
        const tr = document.createElement("tr");

        tr.innerHTML = `
            <td>${p.ref}</td>
            <td>${p.nom}</td>
            <td>${p.categorie}</td>
            <td>${p.quantite}</td>
            <td>${p.seuil}</td>
            <td>${p.prix.toFixed(2)} €</td>
            <td>
                <a href="produit-edit.html" class="btn-secondary btn-sm">Modifier</a>
                <button type="button" class="btn-secondary btn-sm">Supprimer</button>
            </td>
        `;

        tbody.appendChild(tr);
    });
}

// =======================
// AFFICHAGE CATÉGORIES
// =======================
function afficherCategoriesSimulees() {
    const tbody = document.querySelector("table tbody");
    if (!tbody || !window.location.pathname.includes("categories.html")) {
        return;
    }

    if (categoriesSimulees.length === 0) {
        return;
    }

    tbody.innerHTML = "";

    categoriesSimulees.forEach(cat => {
        const tr = document.createElement("tr");

        tr.innerHTML = `
            <td>${cat.id}</td>
            <td>${cat.nom}</td>
            <td>
                <a href="categorie-edit.html" class="btn-secondary btn-sm">Modifier</a>
                <button type="button" class="btn-secondary btn-sm">Supprimer</button>
            </td>
        `;

        tbody.appendChild(tr);
    });
}

// =======================
// RÉSUMÉ DASHBOARD (index.html)
// =======================
function initDashboardResume() {
  const totalProduitsEl = document.getElementById("totalProduits");
  const totalCategoriesEl = document.getElementById("totalCategories");
  const stockFaibleEl = document.getElementById("stockFaible");
  const ruptureStockEl = document.getElementById("ruptureStock");
  const mouvementsTableBody = document.getElementById("mouvementsTable");

  // On vérifie qu'on est bien sur index.html
  if (!totalProduitsEl || !totalCategoriesEl || !stockFaibleEl || !mouvementsTableBody) {
    return;
  }

  // Remplir les compteurs à partir des tableaux fictifs
  totalProduitsEl.innerText = produitsSimules.length;
  totalCategoriesEl.innerText = categoriesSimulees.length;

  const nbStockFaible = produitsSimules.filter(p => p.quantite <= p.seuil && p.quantite > 0).length;
  stockFaibleEl.innerText = nbStockFaible;

  if (ruptureStockEl) {
    const nbRupture = produitsSimules.filter(p => p.quantite === 0).length;
    ruptureStockEl.innerText = nbRupture;
  }
  // Exemple de mouvements fictifs (tu peux réutiliser ceux que tu veux)
  const mouvementsSimules = [
    { produit: "Jus d'orange", type: "Entrée", quantite: 10, date: "2026-02-01" },
    { produit: "Chips salés", type: "Sortie", quantite: 2, date: "2026-02-02" }
  ];

  mouvementsTableBody.innerHTML = "";

  if (mouvementsSimules.length === 0) {
    const row = document.createElement("tr");
    const cell = document.createElement("td");
    cell.colSpan = 4;
    cell.innerText = "Aucun mouvement enregistré pour le moment.";
    row.appendChild(cell);
    mouvementsTableBody.appendChild(row);
  } else {
    mouvementsSimules.forEach(m => {
      const row = document.createElement("tr");

      row.innerHTML = `
        <td>${m.produit}</td>
        <td>${m.type}</td>
        <td>${m.quantite}</td>
        <td>${m.date}</td>
      `;

      mouvementsTableBody.appendChild(row);
    });
  }
}

// 1. VALIDATION DES FORMULAIRES (Inscription / Connexion)
// Vérifie que les champs ne sont pas vides avant l'envoi à la BDD
function verifierFormulaire() {
    const email = document.getElementById("email");
    const password = document.getElementById("password");

    if (email && password) {
        if (email.value.trim() === "" || password.value.trim() === "") {
            alert("Veuillez remplir tous les champs avant de valider.");
            return false; // Bloque l'envoi du formulaire
        }
    }
    return true; // Autorise l'envoi vers le PHP
}

// 2. COMPTEUR DE QUANTITÉ (Pratique pour l'interface d'ajout): un compteur pour ajuster rapidement une quantité.
// Utilise les fonctions augmenter/diminuer de l'exemple
function augmenter() {
    let champ = document.getElementById("quantite");
    if (champ) {
        let q = parseInt(champ.value) || 0;
        q++;
        champ.value = q;
    }
}

function diminuer() {
    let champ = document.getElementById("quantite");
    if (champ) {
        let q = parseInt(champ.value) || 0;
        if (q > 0) {
            q--;
            champ.value = q;
        }
    }
}

// 3. RECHERCHE DYNAMIQUE (Côté Client)
// Permet de filtrer instantanément les résultats déjà affichés par la BDD [cite: 22, 698]
function filtrerTableau() {
    const input = document.getElementById("search") || document.querySelector(".search input");
    const table = document.querySelector("table tbody");
    
    if (input && table) {
        const filter = input.value.toLowerCase();
        const rows = table.getElementsByTagName("tr");

        for (let i = 0; i < rows.length; i++) {
            let text = rows[i].textContent.toLowerCase();
            // Affiche la ligne seulement si elle contient le texte recherché
            rows[i].style.display = text.includes(filter) ? "" : "none";
        }
    }
}

// Pour que la recherche filtre pendant qu’on tape
function initFiltreAuto() {
    const input = document.getElementById("search") || document.querySelector(".search input");
    if (input) {
        input.addEventListener("keyup", filtrerTableau);
    }
}

// 4. INITIALISATION DES ÉVÉNEMENTS
// Validation des formulaires ?
window.onload = function() {
    console.log("window.onload déclenché sur", window.location.pathname);
    
    // 1) Recherche / filtre tableau (produits, catégories, mouvements)
    const btnSearch = document.querySelector(".btn-secondary");
    if (btnSearch) {
        btnSearch.onclick = filtrerTableau;
    }

    initFiltreAuto();

    // 2) Validation sur login / register (formulaires avec email + password)
    const email = document.getElementById("email");
    const password = document.getElementById("password");
    const form = email && password ? email.form : null;

    if (form) {
        form.onsubmit = verifierFormulaire;
    }
    // Affichage des données fictives
    initDashboardResume();      // pour index.html
    afficherProduitsSimules();  // pour produits.html
    afficherCategoriesSimulees(); // pour categories.html
};
