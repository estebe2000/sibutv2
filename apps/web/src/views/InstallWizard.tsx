import React, { useState } from 'react';
import { Container, Title, Paper, Stack, TextInput, PasswordInput, Button, Stepper, Group, Text, Alert, ThemeIcon } from '@mantine/core';
import { IconCheck, IconRocket, IconCloudComputing } from '@tabler/icons-react';
import { notifications } from '@mantine/notifications';
import api from '../services/api';

export function InstallWizard({ onComplete }: { onComplete: () => void }) {
    const [active, setActive] = useState(0);
    const [loading, setLoading] = useState(false);
    const [error, setError] = useState<string | null>(null);

    const [formData, setFormData] = useState({
        admin_email: 'admin@skills-hub.com',
        admin_password: '',
        admin_name: 'Administrateur',
        site_name: 'Skills Hub',
        site_url: window.location.origin,
        cloudflare_token: '',
        logo_url: ''
    });

    const update = (key: string, val: string) => setFormData(prev => ({ ...prev, [key]: val }));

    const handleInstall = async () => {
        setLoading(true);
        setError(null);
        try {
            await api.post('/setup/install', formData);
            notifications.show({ title: 'Installation Réussie', message: 'Bienvenue sur Skills Hub !', color: 'green' });
            setTimeout(() => {
                window.location.reload();
            }, 2000);
        } catch (e: any) {
            setError(e.response?.data?.detail || "Une erreur est survenue lors de l'installation.");
            setLoading(false);
        }
    };

    const nextStep = () => setActive((current) => (current < 3 ? current + 1 : current));
    const prevStep = () => setActive((current) => (current > 0 ? current - 1 : current));

    return (
        <Container size="sm" py="xl" style={{ display: 'flex', flexDirection: 'column', justifyContent: 'center', minHeight: '100vh' }}>
            <Paper withBorder p="xl" radius="md" shadow="xl">
                <Group justify="center" mb="xl">
                     <ThemeIcon size={60} radius="xl" color="blue" variant="light">
                        <IconRocket size={34} />
                    </ThemeIcon>
                </Group>
                <Title order={1} ta="center" mb="lg">Installation de Skills Hub</Title>

                <Stepper active={active} onStepClick={setActive} mb="xl">
                    <Stepper.Step label="Admin" description="Compte Super-Admin" />
                    <Stepper.Step label="Site" description="Identité du site" />
                    <Stepper.Step label="Réseau" description="Cloudflare Tunnel" />
                    <Stepper.Step label="Confirmation" description="Lancement" />
                </Stepper>

                <Stack gap="md" py="md">
                    {active === 0 && (
                        <>
                            <Title order={4}>Création du compte Administrateur</Title>
                            <TextInput label="Email (Login)" value={formData.admin_email} onChange={(e) => update('admin_email', e.target.value)} required />
                            <PasswordInput label="Mot de passe" value={formData.admin_password} onChange={(e) => update('admin_password', e.target.value)} required minLength={8} />
                            <TextInput label="Nom complet" value={formData.admin_name} onChange={(e) => update('admin_name', e.target.value)} />
                        </>
                    )}

                    {active === 1 && (
                        <>
                            <Title order={4}>Configuration du Site</Title>
                            <TextInput label="Nom du Portail" value={formData.site_name} onChange={(e) => update('site_name', e.target.value)} required />
                            <TextInput label="URL Publique" description="L'adresse utilisée pour accéder au site (ex: https://mon-skills-hub.com)" value={formData.site_url} onChange={(e) => update('site_url', e.target.value)} />
                            <TextInput label="Logo URL (Optionnel)" placeholder="https://..." value={formData.logo_url} onChange={(e) => update('logo_url', e.target.value)} />
                        </>
                    )}

                    {active === 2 && (
                        <>
                            <Title order={4}>Accès Distant (Cloudflare)</Title>
                            <Alert icon={<IconCloudComputing />} color="blue" title="Zéro Configuration réseau">
                                Si vous disposez d'un token Cloudflare Tunnel, entrez-le ici pour rendre l'application accessible depuis internet sans ouvrir de ports.
                            </Alert>
                            <PasswordInput
                                label="Cloudflare Tunnel Token"
                                placeholder="eyJhIjoi..."
                                value={formData.cloudflare_token}
                                onChange={(e) => update('cloudflare_token', e.target.value)}
                            />
                            <Text size="xs" c="dimmed">Laissez vide si vous gérez le réseau manuellement (Nginx, Apache, etc.).</Text>
                        </>
                    )}

                    {active === 3 && (
                        <>
                            <Title order={4} ta="center">Prêt à décoller ?</Title>
                            <Text ta="center">Voici un résumé de la configuration :</Text>
                            <Paper withBorder p="sm" bg="gray.0">
                                <Stack gap="xs">
                                    <Group justify="space-between"><Text fw={700}>Admin :</Text><Text>{formData.admin_email}</Text></Group>
                                    <Group justify="space-between"><Text fw={700}>Site :</Text><Text>{formData.site_name}</Text></Group>
                                    <Group justify="space-between"><Text fw={700}>Tunnel :</Text><Text>{formData.cloudflare_token ? 'Activé' : 'Désactivé'}</Text></Group>
                                </Stack>
                            </Paper>
                            {error && <Alert color="red" title="Erreur">{error}</Alert>}
                        </>
                    )}
                </Stack>

                <Group justify="space-between" mt="xl">
                    {active > 0 && <Button variant="default" onClick={prevStep}>Retour</Button>}
                    {active < 3 ? (
                        <Button onClick={nextStep} ml={active === 0 ? 'auto' : 0}>Suivant</Button>
                    ) : (
                        <Button color="green" onClick={handleInstall} loading={loading} leftSection={<IconCheck size={16} />}>Installer</Button>
                    )}
                </Group>
            </Paper>
        </Container>
    );
}
