import requests

BASE_URL = "https://kewere-aissa-smart.onrender.com"
EMAIL = "celloudiallo286@gmail.com"
PASSWORD = "Dakar2025"  # ← change ici

# 1. LOGIN
print("🔐 Connexion...")
r = requests.post(f"{BASE_URL}/auth/login",
    data={"username": EMAIL, "password": PASSWORD})
token = r.json()["access_token"]
headers = {"Authorization": f"Bearer {token}", "Content-Type": "application/json"}
print(f"✅ Token obtenu !")

# 2. RÉCUPÉRER LA VRAIE FERME
print("\n🏡 Récupération ferme...")
fermes = requests.get(f"{BASE_URL}/fermes/", headers=headers).json()
if fermes:
    ferme_id = fermes[0]["id"]
    print(f"✅ Ferme trouvée : {ferme_id}")
else:
    ferme = requests.post(f"{BASE_URL}/fermes/", headers=headers, json={
        "nom": "Ferme Kewere", "localisation": "Mbour", "type_elevage": "aviculture"
    }).json()
    ferme_id = ferme["id"]
    print(f"✅ Ferme créée : {ferme_id}")

# 3. CRÉER UN CYCLE
print("\n🐔 Création cycle...")
cycle = requests.post(f"{BASE_URL}/cycles/", headers=headers, json={
    "nom": "Cycle Cobb 500 - Mai 2026",
    "date_debut": "2026-04-01",
    "nombre_sujets": 2000,
    "type_cycle": "chair",
    "batiment": "Bâtiment A",
    "souche": "Cobb 500",
    "statut": "en_cours",
    "ferme_id": ferme_id,
}).json()
print("Réponse cycle:", cycle)
cycle_id = cycle.get("id")
print(f"✅ Cycle ID : {cycle_id}")

# 4. DONNÉES JOURNALIÈRES
print("\n📊 Insertion données...")
from datetime import date, timedelta
date_debut = date(2026, 4, 1)
donnees = [
    {"age_jours": 1,  "poids_moyen": 45,   "mortalite": 3, "consommation_aliment": 4.0,   "temperature": 32.0, "humidite": 65.0, "production": 0},
    {"age_jours": 7,  "poids_moyen": 185,  "mortalite": 2, "consommation_aliment": 18.5,  "temperature": 31.0, "humidite": 67.0, "production": 0},
    {"age_jours": 14, "poids_moyen": 430,  "mortalite": 4, "consommation_aliment": 42.0,  "temperature": 30.0, "humidite": 68.0, "production": 0},
    {"age_jours": 21, "poids_moyen": 820,  "mortalite": 3, "consommation_aliment": 78.0,  "temperature": 30.0, "humidite": 70.0, "production": 0},
    {"age_jours": 28, "poids_moyen": 1290, "mortalite": 5, "consommation_aliment": 115.0, "temperature": 29.0, "humidite": 72.0, "production": 0},
    {"age_jours": 35, "poids_moyen": 1820, "mortalite": 4, "consommation_aliment": 148.0, "temperature": 29.0, "humidite": 71.0, "production": 0},
    {"age_jours": 42, "poids_moyen": 2480, "mortalite": 6, "consommation_aliment": 180.0, "temperature": 28.0, "humidite": 73.0, "production": 0},
]
for d in donnees:
    d["cycle_id"] = cycle_id
    d["ferme_id"] = ferme_id
    d["date_releve"] = str(date_debut + timedelta(days=d["age_jours"]))
    r = requests.post(f"{BASE_URL}/donnees/", headers=headers, json=d)
    print(f"  J{d['age_jours']} → {'✅' if r.status_code in [200,201] else '❌ ' + r.text}")

# 5. STOCKS
print("\n📦 Création stocks...")
stocks = [
    {"produit": "Aliment démarrage",  "quantite": 50,  "unite": "sac",   "seuil_alerte": 10, "ferme_id": ferme_id},
    {"produit": "Aliment croissance", "quantite": 80,  "unite": "sac",   "seuil_alerte": 15, "ferme_id": ferme_id},
    {"produit": "Vaccin Newcastle",   "quantite": 5,   "unite": "litre", "seuil_alerte": 2,  "ferme_id": ferme_id},
    {"produit": "Désinfectant",       "quantite": 3,   "unite": "litre", "seuil_alerte": 1,  "ferme_id": ferme_id},
]
for s in stocks:
    r = requests.post(f"{BASE_URL}/stocks/", headers=headers, json=s)
    print(f"  {s['produit']} → {'✅' if r.status_code in [200,201] else '❌ ' + r.text}")

# 6. EMPLOYÉS
print("\n👥 Création employés...")
employes = [
    {"nom": "Mamadou Diallo", "telephone": "+221771234567", "poste": "manager",     "role": "employe", "salaire": 250000, "ferme_id": ferme_id},
    {"nom": "Fatou Ndiaye",   "telephone": "+221782345678", "poste": "employe",     "role": "employe", "salaire": 150000, "ferme_id": ferme_id},
    {"nom": "Ibrahima Sow",   "telephone": "+221793456789", "poste": "veterinaire", "role": "employe", "salaire": 300000, "ferme_id": ferme_id},
    {"nom": "Aissatou Ba",    "telephone": "+221764567890", "poste": "employe",     "role": "employe", "salaire": 150000, "ferme_id": ferme_id},
]
for e in employes:
    r = requests.post(f"{BASE_URL}/employes/", headers=headers, json=e)
    print(f"  {e['nom']} → {'✅' if r.status_code in [200,201] else '❌ ' + r.text}")

print("\n🎉 Terminé ! Rafraîchis l'app Flutter.")