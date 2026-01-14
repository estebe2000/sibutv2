import React, { useState, useEffect } from 'react';
import { Container, Title, Paper, Tabs, Stack, TextInput, Button } from '@mantine/core';
import { IconUsers, IconDatabase, IconSettings } from '@tabler/icons-react';

export function SettingsView({ config, onSave }: any) {
  const [localConfig, setLocalConfig] = useState<any[]>([]);

  useEffect(() => {
    // Default structure if empty
    const defaults = [
      { key: 'ldap_url', value: 'ldap://ldap:389', category: 'ldap' },
      { key: 'ldap_base_dn', value: 'dc=univ,dc=fr', category: 'ldap' },
      { key: 'smtp_host', value: 'mail', category: 'mail' },
      { key: 'smtp_port', value: '1025', category: 'mail' },
      { key: 'mistral_api_key', value: '', category: 'ai' },
      { key: 'APP_LOGO_URL', value: '', category: 'branding' },
      { key: 'APP_PRIMARY_COLOR', value: '#1971c2', category: 'branding' },
      { key: 'APP_WELCOME_MESSAGE', value: 'Bienvenue sur Skills Hub', category: 'branding' }
    ];

    const merged = defaults.map(d => {
      const existing = config.find((c: any) => c.key === d.key);
      return existing || d;
    });
    setLocalConfig(merged);
  }, [config]);

  const updateVal = (key: string, val: string) => {
    setLocalConfig(prev => prev.map(c => c.key === key ? { ...c, value: val } : c));
  };

  const categories = [
    { id: 'ldap', label: 'Serveur LDAP', icon: <IconUsers size={16} /> },
    { id: 'mail', label: 'Serveur Mail (SMTP)', icon: <IconUsers size={16} /> },
    { id: 'ai', label: 'IA (Codestral)', icon: <IconDatabase size={16} /> },
    { id: 'branding', label: 'Identité Visuelle', icon: <IconSettings size={16} /> }
  ];

  return (
    <Container size="md">
      <Title order={2} mb="xl">Configuration du Système</Title>
      <Paper withBorder p="md">
        <Tabs defaultValue="ldap">
          <Tabs.List mb="md">
            {categories.map(cat => (
              <Tabs.Tab key={cat.id} value={cat.id} leftSection={cat.icon}>{cat.label}</Tabs.Tab>
            ))}
          </Tabs.List>

          {categories.map(cat => (
            <Tabs.Panel key={cat.id} value={cat.id}>
              <Stack>
                {localConfig.filter(c => c.category === cat.id).map(item => (
                  <TextInput
                    key={item.key}
                    label={item.key.replace(/_/g, ' ').toUpperCase()}
                    value={item.value}
                    onChange={(e) => updateVal(item.key, e.target.value)}
                  />
                ))}
              </Stack>
            </Tabs.Panel>
          ))}
        </Tabs>
        <Button mt="xl" onClick={() => onSave(localConfig)}>Enregistrer la configuration</Button>
      </Paper>
    </Container>
  );
}
