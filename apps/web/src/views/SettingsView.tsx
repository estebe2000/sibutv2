import React, { useState, useEffect } from 'react';
import { Container, Title, Paper, Tabs, Stack, TextInput, Button, Select, Group, PasswordInput } from '@mantine/core';
import { IconUsers, IconDatabase, IconSettings, IconPlugConnected } from '@tabler/icons-react';
import { notifications } from '@mantine/notifications';
import api from '../services/api';

export function SettingsView({ config, onSave }: any) {
  const [localConfig, setLocalConfig] = useState<any[]>([]);
  const [testing, setTesting] = useState(false);
  const [ollamaModels, setOllamaModels] = useState<string[]>([]);
  const [scanningOllama, setScanningOllama] = useState(false);

  useEffect(() => {
    // Default structure if empty
    const defaults = [
      { key: 'ldap_url', value: 'ldap://ldap:389', category: 'ldap' },
      { key: 'ldap_base_dn', value: 'dc=univ,dc=fr', category: 'ldap' },
      { key: 'smtp_host', value: 'mail', category: 'mail' },
      { key: 'smtp_port', value: '1025', category: 'mail' },
      
      // New AI Config
      { key: 'ai_provider', value: 'codestral', category: 'ai' },
      { key: 'ai_model', value: 'codestral-latest', category: 'ai' },
      { key: 'ai_endpoint', value: 'https://codestral.mistral.ai/v1', category: 'ai' },
      { key: 'ai_api_key', value: '', category: 'ai' },
      
      { key: 'APP_LOGO_URL', value: '', category: 'branding' },
      { key: 'APP_PRIMARY_COLOR', value: '#1971c2', category: 'branding' },
      { key: 'APP_WELCOME_MESSAGE', value: 'Bienvenue sur Skills Hub', category: 'branding' }
    ];

    const merged = defaults.map(d => {
      // Migration: map old mistral_api_key to ai_api_key if ai_api_key is missing
      if (d.key === 'ai_api_key') {
          const old = config.find((c: any) => c.key === 'mistral_api_key');
          const newKey = config.find((c: any) => c.key === 'ai_api_key');
          if (!newKey && old) return { ...d, value: old.value };
      }
      
      const existing = config.find((c: any) => c.key === d.key);
      return existing || d;
    });
    setLocalConfig(merged);
  }, [config]);

  const updateVal = (key: string, val: string | null) => {
    if (val === null) return;
    setLocalConfig(prev => prev.map(c => c.key === key ? { ...c, value: val } : c));
  };

  const getValue = (key: string) => localConfig.find(c => c.key === key)?.value || '';

  const scanOllama = async () => {
      setScanningOllama(true);
      try {
          const res = await api.get('/ai/ollama/models');
          setOllamaModels(res.data.models);
          // Only update endpoint if scan works to override default localhost if needed (e.g. host.docker.internal)
          if (res.data.endpoint) updateVal('ai_endpoint', res.data.endpoint);
          
          const currentModel = getValue('ai_model');
          if (res.data.models.length > 0) {
               // Update model only if current one is not in list or empty
               if (!currentModel || !res.data.models.includes(currentModel)) {
                   updateVal('ai_model', res.data.models[0]);
               }
          }
          notifications.show({ title: 'Ollama Détecté', message: `${res.data.models.length} modèles trouvés.`, color: 'green' });
      } catch (e) {
          notifications.show({ title: 'Ollama introuvable', message: 'Vérifiez que Ollama tourne sur le port 11434.', color: 'orange' });
          setOllamaModels([]);
      }
      setScanningOllama(false);
  };

  const defaults: any = {
      'codestral': { url: 'https://codestral.mistral.ai/v1', model: 'codestral-latest' },
      'mistral': { url: 'https://api.mistral.ai/v1', model: 'mistral-small-latest' },
      'openai': { url: 'https://api.openai.com/v1', model: 'gpt-4o' },
      'anthropic': { url: 'https://api.anthropic.com/v1', model: 'claude-3-5-sonnet-latest' },
      'ollama': { url: 'http://localhost:11434', model: '' }
  };

  const handleProviderChange = (provider: string | null) => {
      if (!provider) return;
      
      // 1. Update Provider
      updateVal('ai_provider', provider);
      
      // 2. Set Defaults
      if (defaults[provider]) {
          updateVal('ai_endpoint', defaults[provider].url);
          if (defaults[provider].model) {
              updateVal('ai_model', defaults[provider].model);
          }
      }

      // 3. Scan if Ollama
      if (provider === 'ollama') {
          scanOllama();
      }
  };

  const handleTestConnection = async () => {
      setTesting(true);
      try {
          // Temporarily save config to backend or send current values for testing
          // Ideally backend should have a /test-ai endpoint accepting credentials
          await api.post('/ai/test-connection', {
              provider: getValue('ai_provider'),
              model: getValue('ai_model'),
              endpoint: getValue('ai_endpoint'),
              api_key: getValue('ai_api_key')
          });
          notifications.show({ title: 'Succès', message: 'Connexion établie avec succès !', color: 'green' });
      } catch (e: any) {
          notifications.show({ title: 'Échec', message: e.response?.data?.detail || 'Impossible de se connecter.', color: 'red' });
      }
      setTesting(false);
  };

  const categories = [
    { id: 'ldap', label: 'Serveur LDAP', icon: <IconUsers size={16} /> },
    { id: 'mail', label: 'Serveur Mail (SMTP)', icon: <IconUsers size={16} /> },
    { id: 'ai', label: 'IA (LiteLLM)', icon: <IconDatabase size={16} /> },
    { id: 'branding', label: 'Identité Visuelle', icon: <IconSettings size={16} /> }
  ];

  return (
    <Container size="md">
      <Title order={2} mb="xl">Configuration du Système</Title>
      <Paper withBorder p="md">
        <Tabs defaultValue="ai">
          <Tabs.List mb="md">
            {categories.map(cat => (
              <Tabs.Tab key={cat.id} value={cat.id} leftSection={cat.icon}>{cat.label}</Tabs.Tab>
            ))}
          </Tabs.List>

          {categories.map(cat => (
            <Tabs.Panel key={cat.id} value={cat.id}>
              <Stack>
                {cat.id === 'ai' ? (
                    <>
                        <Select 
                            label="Fournisseur (Provider)" 
                            data={['codestral', 'ollama', 'openai', 'mistral', 'anthropic', 'azure']}
                            value={getValue('ai_provider')}
                            onChange={handleProviderChange}
                        />
                        
                        {getValue('ai_provider') === 'ollama' && ollamaModels.length > 0 ? (
                            <Select
                                label="Modèle Ollama"
                                data={ollamaModels}
                                value={getValue('ai_model')}
                                onChange={(v) => updateVal('ai_model', v)}
                                rightSection={<Button variant="subtle" size="xs" onClick={scanOllama} loading={scanningOllama}>Scan</Button>}
                            />
                        ) : (
                            <TextInput 
                                label="Modèle" 
                                description="Ex: codestral-latest, gpt-4, llama2"
                                value={getValue('ai_model')}
                                onChange={(e) => updateVal('ai_model', e.target.value)}
                            />
                        )}

                        <TextInput 
                            label="Endpoint API" 
                            description="URL de base (ex: https://api.openai.com/v1, http://localhost:11434)"
                            value={getValue('ai_endpoint')}
                            onChange={(e) => updateVal('ai_endpoint', e.target.value)}
                            disabled={getValue('ai_provider') === 'ollama' && ollamaModels.length > 0}
                        />
                        <PasswordInput 
                            label="Clé API" 
                            placeholder="sk-..."
                            value={getValue('ai_api_key')}
                            onChange={(e) => updateVal('ai_api_key', e.target.value)}
                        />
                        <Group justify="flex-end">
                            <Button variant="light" leftSection={<IconPlugConnected size={16}/>} onClick={handleTestConnection} loading={testing}>
                                Tester la connexion
                            </Button>
                        </Group>
                    </>
                ) : (
                    localConfig.filter(c => c.category === cat.id).map(item => (
                      <TextInput
                        key={item.key}
                        label={item.key.replace(/_/g, ' ').toUpperCase()}
                        value={item.value}
                        onChange={(e) => updateVal(item.key, e.target.value)}
                      />
                    ))
                )}
              </Stack>
            </Tabs.Panel>
          ))}
        </Tabs>
        <Button mt="xl" onClick={() => onSave(localConfig)}>Enregistrer la configuration</Button>
      </Paper>
    </Container>
  );
}