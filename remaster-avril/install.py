#!/usr/bin/env python3
import os
import urllib.request
import urllib.error

def print_header(title):
    print("\n" + "=" * 50)
    print(f" {title}")
    print("=" * 50)

def prompt(message, default=None):
    if default:
        return input(f"{message} [{default}]: ") or default
    return input(f"{message}: ")

def test_url(url, service_name):
    print(f"Testing connection to {service_name} at {url} ...", end=" ")
    try:
        req = urllib.request.Request(url, method="HEAD")
        urllib.request.urlopen(req, timeout=5)
        print("✅ Success")
        return True
    except urllib.error.URLError as e:
        print(f"❌ Failed ({e.reason}) - This is a non-blocking warning.")
        return False
    except ValueError:
        print(f"❌ Invalid URL format - This is a non-blocking warning.")
        return False

def generate_env(config):
    env_content = ""
    for key, value in config.items():
        env_content += f"{key}={value}\n"

    with open(".env", "w") as f:
        f.write(env_content)
    print("\n✅ .env file successfully generated!")

def main():
    print_header("Skills Hub Remaster - Installation Wizard")

    config = {}

    # 1. Project Configuration
    print_header("1. General Project Settings")
    config["DOMAIN"] = prompt("Domain Name", "educ-ai.fr")
    config["PROJECT_NAME"] = prompt("Project Name", "Skills Hub Remaster")
    config["SECRET_KEY"] = prompt("Secret Key (for fallback JWT/sessions)", "skills-hub-secret-key-2026")

    # 2. Database Configuration
    print_header("2. Database Settings")
    config["DATABASE_URL"] = prompt("Database URL", "postgresql://app_user:app_password@db:5432/skills_db")

    # 3. Authentification (Keycloak)
    print_header("3. Keycloak Authentication")
    config["KEYCLOAK_URL"] = prompt("Keycloak Internal URL", "http://keycloak:8080")
    config["KEYCLOAK_REALM"] = prompt("Keycloak Realm", "but-tc")
    config["KEYCLOAK_CLIENT_ID"] = prompt("Client ID", "skills-hub-app")
    config["KEYCLOAK_CLIENT_SECRET"] = prompt("Client Secret", "")

    # 4. AI Configuration
    print_header("4. AI Service Configuration")
    config["AI_SERVICE_URL"] = prompt("AI Service Endpoint", "http://172.16.87.140:8080/v1/chat/completions")
    config["AI_MODEL_NAME"] = prompt("AI Model Name", "llama-3.2-3b")

    # 5. SMTP Configuration
    print_header("5. SMTP Configuration (for Magic Links)")
    config["SMTP_SERVER"] = prompt("SMTP Server", "smtp.educ-ai.fr")
    config["SMTP_PORT"] = prompt("SMTP Port", "587")
    config["SMTP_USER"] = prompt("SMTP User", "")
    config["SMTP_PASSWORD"] = prompt("SMTP Password", "")
    config["SMTP_FROM_EMAIL"] = prompt("Sender Email", "noreply@educ-ai.fr")

    # 6. Optional Services
    print_header("6. Optional Cloudflare Settings")
    config["CLOUDFLARE_TUNNEL_TOKEN"] = prompt("Cloudflare Tunnel Token", "")

    # Tests
    print_header("Running Pre-Installation Checks")
    test_url(config["KEYCLOAK_URL"], "Keycloak")
    test_url(config["AI_SERVICE_URL"], "AI Service")

    # Finalize
    generate_env(config)
    print("\nInstallation setup complete. You can now run docker-compose up -d")

if __name__ == "__main__":
    main()
