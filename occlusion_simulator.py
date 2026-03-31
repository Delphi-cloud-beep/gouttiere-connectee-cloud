import random
import time
from datetime import datetime

# Configuration du patient : simuler une molaire gauche trop "haute"
# Cela crée un contact prématuré (Malocclusion)
BIAIS_GAUCHE = 2,5  # La pression sera 2.5x plus forte à gauche qu'à droite

def simuler_capteurs_occlusion():
    # Pression de base exercée par le patient (en Newtons)
    effort_global = random.uniform(10, 30) 
    
    # Répartition déséquilibrée
    pression_gauche = effort_global * BIAIS_GAUCHE
    pression_droite = effort_global * 0.8
    pression_front = effort_global * 1.1
    
    return {
        "timestamp": datetime.now().isoformat(),
        "zones": {
            "molaire_gauche": round(pression_gauche, 2),
            "molaire_droite": round(pression_droite, 2),
            "incisives": round(pression_front, 2)
        }
    }

print("--- Analyse d'Occlusion en cours (delphine.cloud) ---")

try:
    while True:
        data = simuler_capteurs_occlusion()
        
        # Calcul du déséquilibre pour ton dashboard
        diff = data['zones']['molaire_gauche'] - data['zones']['molaire_droite']
        statut = "🔴 DÉFAUT D'OCCLUSION" if diff > 20 else "🟢 ALIGNEMENT OK"
        
        print(f"G: {data['zones']['molaire_gauche']}N | D: {data['zones']['molaire_droite']}N | {statut}")
        
        time.sleep(1)
except KeyboardInterrupt:
    print("Analyse terminée.")