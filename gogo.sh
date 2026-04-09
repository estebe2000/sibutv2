#!/bin/bash

# --- Configuration ---
LITELLM_PORT=4000
# L'ID exact du modèle sur Albert est "openai/gpt-oss-120b"
MODEL_ALBERT="openai/gpt-oss-120b"
API_BASE="https://albert.api.etalab.gouv.fr/v1"
API_KEY="sk-eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VyX2lkIjo4NTAyLCJ0b2tlbl9pZCI6MTYxNTQsImV4cGlyZXMiOjE4MDQ0NjA0MDB9.GDGvca0HKxkvziUfe6lFh2GbLwymyDJzvdRgRkSEztA"
VENV_DIR=".litellm_venv"

# --- Création du fichier de config LiteLLM ---
# Note : On utilise "openai/$MODEL_ALBERT" pour que LiteLLM sache qu'il doit 
# utiliser le driver OpenAI. Comme MODEL_ALBERT contient déjà "openai/", 
# LiteLLM enverra bien "openai/gpt-oss-120b" à l'API Albert.
cat <<EOF > litellm_config.yaml
model_list:
  - model_name: claude-3-7-sonnet-20250219
    litellm_params:
      model: openai/$MODEL_ALBERT
      api_base: "$API_BASE"
      api_key: "$API_KEY"
