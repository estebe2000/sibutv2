#!/bin/bash

# --- Configuration ---
LITELLM_PORT=4000
MODEL_ALBERT="openweight-large"
API_BASE="https://albert.api.etalab.gouv.fr/v1"
API_KEY="sk-eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjo4NTAyLCJ0b2tlbl9pZCI6MTYxNTQsImV4cGlyZXMiOjE4MDQ0NjA0MDB9.GDGvca0HKxkvziUfe6lFh2GbLwymyDJzvdRgRkSEztA"
VENV_DIR=".litellm_venv"

# --- Création du fichier de config LiteLLM ---
cat <<EOF > litellm_config.yaml
model_list:
  - model_name: claude-3-7-sonnet-20250219
    litellm_params:
      model: openai/$MODEL_ALBERT
      api_base: "$API_BASE"
      api_key: "$API_KEY"
EOF

# --- Gestion de l'environnement virtuel (Forcé en Python 3.12) ---
if [ ! -d "$VENV_DIR" ]; then
    echo "Création de l'environnement virtuel Python 3.12 ($VENV_DIR)..."
    python3.12 -m venv "$VENV_DIR"
fi

echo "Activation de l'environnement virtuel..."
source "$VENV_DIR/bin/activate"

# --- Installation de LiteLLM ---
if ! command -v litellm &> /dev/null; then
    echo "Installation de litellm[proxy] via pip..."
    pip install -q 'litellm[proxy]'
fi

# --- Lancement de la passerelle ---
echo "Démarrage de la passerelle LiteLLM sur le port $LITELLM_PORT..."
# CORRECTION ICI : utilisation de la commande litellm directement
litellm --config litellm_config.yaml --port $LITELLM_PORT > litellm.log 2>&1 &
LITELLM_PID=$!

# --- Gestion de l'arrêt (nettoyage) ---
cleanup() {
    echo -e "\nArrêt de la passerelle LiteLLM (PID $LITELLM_PID)..."
    kill $LITELLM_PID 2>/dev/null
    rm -f litellm_config.yaml
    deactivate 2>/dev/null
    exit 0
}
trap cleanup SIGINT SIGTERM EXIT

# Laisser le temps au serveur proxy de démarrer
sleep 3

# --- Lancement de Claude Code ---
export ANTHROPIC_BASE_URL="http://localhost:$LITELLM_PORT"
export ANTHROPIC_AUTH_TOKEN="cle-factice-locale"

echo "Lancement de Claude Code..."
claude
