import React from 'react';
import { Container, Paper, Title, Text, Stack, Group, ThemeIcon, List, Alert } from '@mantine/core';
import { IconCalendar, IconMail, IconMessages, IconCloud, IconTarget, IconUsers, IconInfoCircle } from '@tabler/icons-react';

export function ExternalServicesProposalsView({ type }: { type: string }) {
    const renderContent = () => {
        switch (type) {
            case 'calendar':
                return (
                    <>
                        <Group mb="md">
                            <ThemeIcon size="xl" radius="md" color="yellow" variant="light">
                                <IconCalendar size={24} />
                            </ThemeIcon>
                            <Title order={2}>Synchronisation Hyperplanning</Title>
                        </Group>
                        <Text mb="md">
                            L'objectif est d'intégrer directement votre emploi du temps Hyperplanning dans le Skills Hub.
                        </Text>
                        <List spacing="xs" size="sm" center icon={<ThemeIcon color="yellow" size={18} radius="xl"><IconTarget size={12} /></ThemeIcon>}>
                            <List.Item>Affichage des cours en temps réel</List.Item>
                            <List.Item>Notifications de changement de salle ou d'horaire</List.Item>
                            <List.Item>Lien direct avec les ressources pédagogiques du cours</List.Item>
                        </List>
                    </>
                );
            case 'mail':
                return (
                    <>
                        <Group mb="md">
                            <ThemeIcon size="xl" radius="md" color="yellow" variant="light">
                                <IconMail size={24} />
                            </ThemeIcon>
                            <Title order={2}>Webmail Intégré</Title>
                        </Group>
                        <Text mb="md">
                            Une interface simplifiée pour consulter vos mails académiques sans quitter la plateforme.
                        </Text>
                        <List spacing="xs" size="sm" center icon={<ThemeIcon color="yellow" size={18} radius="xl"><IconTarget size={12} /></ThemeIcon>}>
                            <List.Item>Notification de nouveaux messages</List.Item>
                            <List.Item>Filtres intelligents par SAÉ ou Enseignants</List.Item>
                            <List.Item>Envoi rapide de preuves par mail vers le coffre-fort</List.Item>
                        </List>
                    </>
                );
            case 'chat':
                return (
                    <>
                        <Group mb="md">
                            <ThemeIcon size="xl" radius="md" color="yellow" variant="light">
                                <IconMessages size={24} />
                            </ThemeIcon>
                            <Title order={2}>Canaux de Discussion (Mattermost)</Title>
                        </Group>
                        <Text mb="md">
                            Intégration des canaux Mattermost pour une communication fluide par projet.
                        </Text>
                        <List spacing="xs" size="sm" center icon={<ThemeIcon color="yellow" size={18} radius="xl"><IconTarget size={12} /></ThemeIcon>}>
                            <List.Item>Canaux automatiques par groupe de SAÉ</List.Item>
                            <List.Item>Discussions privées avec les tuteurs de stage</List.Item>
                            <List.Item>Partage rapide de documents du Cloud</List.Item>
                        </List>
                    </>
                );
            case 'cloud':
                return (
                    <>
                        <Group mb="md">
                            <ThemeIcon size="xl" radius="md" color="yellow" variant="light">
                                <IconCloud size={24} />
                            </ThemeIcon>
                            <Title order={2}>Cloud & Stockage (Nextcloud)</Title>
                        </Group>
                        <Text mb="md">
                            Espace de stockage personnel et collaboratif basé sur Nextcloud.
                        </Text>
                        <List spacing="xs" size="sm" center icon={<ThemeIcon color="yellow" size={18} radius="xl"><IconTarget size={12} /></ThemeIcon>}>
                            <List.Item>Synchronisation automatique des dossiers de groupe</List.Item>
                            <List.Item>Édition de documents en ligne (OnlyOffice)</List.Item>
                            <List.Item>Archivage sécurisé des preuves du Portfolio</List.Item>
                        </List>
                    </>
                );
            case 'alumni':
                return (
                    <>
                        <Group mb="md">
                            <ThemeIcon size="xl" radius="md" color="yellow" variant="light">
                                <IconUsers size={24} />
                            </ThemeIcon>
                            <Title order={2}>Réseau Alumni & Annuaire</Title>
                        </Group>
                        <Text mb="md">
                            Un annuaire pour rester en contact avec les anciens diplômés du BUT TC.
                        </Text>
                        <List spacing="xs" size="sm" center icon={<ThemeIcon color="yellow" size={18} radius="xl"><IconTarget size={12} /></ThemeIcon>}>
                            <List.Item>Suivi des parcours après le diplôme</List.Item>
                            <List.Item>Offres de stage et d'emploi exclusives</List.Item>
                            <List.Item>Mentorat entre anciens et nouveaux étudiants</List.Item>
                        </List>
                    </>
                );
            default:
                return <Text>Sélectionnez un service pour voir sa description.</Text>;
        }
    };

    return (
        <Container size="md" py="xl">
            <Paper withBorder p="xl" radius="md" shadow="sm">
                <Stack gap="lg">
                    {renderContent()}
                    <Alert icon={<IconInfoCircle size={16} />} title="En cours de réflexion" color="yellow" variant="light" mt="xl">
                        Cette fonctionnalité fait partie des évolutions futures de la plateforme. N'hésitez pas à nous faire part de vos besoins spécifiques !
                    </Alert>
                </Stack>
            </Paper>
        </Container>
    );
}
