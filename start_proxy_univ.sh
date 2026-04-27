#!/bin/bash
LITELLM_PORT=5545
CONFIG_FILE="proxy_univ_config.yaml"
VENV_DIR=".litellm_venv"

if [ ! -d "$VENV_DIR" ]; then
    echo "Erreur : L'environnement virtuel $VENV_DIR n'existe pas."
    exit 1
fi

echo "Activation de l'environnement virtuel $VENV_DIR..."
source "$VENV_DIR/bin/activate"

echo "Démarrage du proxy LiteLLM sur le port $LITELLM_PORT..."
litellm --config "$CONFIG_FILE" --port "$LITELLM_PORT"
