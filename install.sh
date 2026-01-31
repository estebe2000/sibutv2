#!/bin/bash

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=== Skills Hub Installer ===${NC}"

if [ -f .env ]; then
    echo -e "${GREEN}Configuration file (.env) found.${NC}"
else
    echo "Creating .env file from template..."
    if [ -f .env.template ]; then
        cp .env.template .env

        # Generate random passwords
        echo "Generating secure passwords..."
        sed -i "s/mettez-un-mot-de-passe-ici/$(openssl rand -hex 12)/g" .env
        sed -i "s/changez-moi/$(openssl rand -hex 12)/g" .env
        sed -i "s/generer-un-secret-aleatoire/$(openssl rand -hex 16)/g" .env

        echo -e "${GREEN}.env file created with secure passwords.${NC}"
        echo "You can edit .env manually if you need specific database settings."
    else
        echo "ERROR: .env.template not found!"
        exit 1
    fi
fi

echo -e "${BLUE}Starting Docker containers...${NC}"
./start.sh

echo -e "${BLUE}Waiting for services to start...${NC}"
sleep 10

echo -e "${BLUE}Applying patches and configuring services...${NC}"
bash infrastructure/production/patch-all.sh

echo -e "${GREEN}=== Installation Completed ===${NC}"
