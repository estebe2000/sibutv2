import React from 'react';
import { Container, Paper, Title, Text, Stack, Group, Avatar, Badge, Grid, Card, Button, Divider, ThemeIcon, Progress, Center } from '@mantine/core';
import { IconExternalLink, IconSparkles, IconMail, IconPhone, IconWorld } from '@tabler/icons-react';

export function LiveBookPreviewView({ user }: { user: any }) {
    // Simulation du contenu publié
    return (
        <div style={{ backgroundColor: '#f8f9fa', minHeight: '100vh', padding: '40px 0' }}>
            <Container size="md">
                {/* HEADER STYLE CMS */}
                <Paper shadow="xl" p={40} radius="lg" mb="xl" style={{ borderTop: '8px solid #228be6' }}>
                    <Grid align="center">
                        <Grid.Col span={{ base: 12, md: 4 }}>
                            <Avatar src={null} size={150} radius="xl" mx="auto" />
                        </Grid.Col>
                        <Grid.Col span={{ base: 12, md: 8 }}>
                            <Stack gap={5}>
                                <Badge color="blue" size="lg" variant="dot">Disponible pour un stage</Badge>
                                <Title order={1} style={{ fontSize: '2.5rem' }}>{user.full_name}</Title>
                                <Text size="xl" fw={500} c="dimmed">Étudiant en BUT Techniques de Commercialisation</Text>
                                <Group mt="md">
                                    <Group gap={5}><IconMail size={16}/><Text size="sm">{user.email}</Text></Group>
                                    <Group gap={5}><IconWorld size={16}/><Text size="sm">linkedin.com/in/{user.ldap_uid}</Text></Group>
                                </Group>
                            </Stack>
                        </Grid.Col>
                    </Grid>
                </Paper>

                <Grid>
                    <Grid.Col span={{ base: 12, md: 8 }}>
                        <Stack gap="xl">
                            {/* SECTION EXPERIENCE SIMULÉE */}
                            <Title order={2} mb="md" style={{ borderBottom: '2px solid #eee', paddingBottom: 10 }}>Mes Réflexions de Compétences</Title>
                            
                            <Card withBorder radius="md" p="xl" shadow="sm">
                                <Title order={3} mb="xs">Analyse du mix-marketing chez Decathlon</Title>
                                <Text size="sm" c="dimmed" mb="md">Publié le 15 Janvier 2026</Text>
                                <Text lineClamp={4}>
                                    Dans le cadre de ma SAÉ 1.01, j'ai eu l'opportunité d'analyser la stratégie marketing de Decathlon Le Havre. 
                                    J'ai pu identifier les leviers de croissance sur le segment des sports de glisse et proposer un plan d'action...
                                </Text>
                                <Button variant="light" mt="md" rightSection={<IconExternalLink size={14}/>}>Lire la suite</Button>
                            </Card>

                            <Card withBorder radius="md" p="xl" shadow="sm">
                                <Title order={3} mb="xs">Prospection et négociation B2B</Title>
                                <Text size="sm" c="dimmed" mb="md">Publié le 28 Décembre 2025</Text>
                                <Text lineClamp={4}>
                                    Ce projet m'a permis de mettre en pratique les techniques de vente apprises en cours. 
                                    J'ai réalisé un fichier de prospection de 50 entreprises et obtenu 5 rendez-vous qualifiés...
                                </Text>
                                <Button variant="light" mt="md" rightSection={<IconExternalLink size={14}/>}>Lire la suite</Button>
                            </Card>
                        </Stack>
                    </Grid.Col>

                    <Grid.Col span={{ base: 12, md: 4 }}>
                        <Stack gap="xl">
                            <Title order={2} mb="md" style={{ borderBottom: '2px solid #eee', paddingBottom: 10 }}>Compétences</Title>
                            <Paper withBorder p="md" radius="md">
                                <Stack gap="xs">
                                    <Group justify="space-between"><Text size="sm" fw={700}>Marketing</Text><Badge color="blue">Avancé</Badge></Group>
                                    <Progress value={85} color="blue" size="sm" />
                                    
                                    <Group justify="space-between" mt="sm"><Text size="sm" fw={700}>Vente</Text><Badge color="green">Intermédiaire</Badge></Group>
                                    <Progress value={60} color="green" size="sm" />

                                    <Group justify="space-between" mt="sm"><Text size="sm" fw={700}>Communication</Text><Badge color="orange">Maîtrisé</Badge></Group>
                                    <Progress value={75} color="orange" size="sm" />
                                </Stack>
                            </Paper>

                            <Title order={2} mb="md" style={{ borderBottom: '2px solid #eee', paddingBottom: 10 }}>Outils</Title>
                            <Group gap="xs">
                                <Badge variant="light">Odoo V17</Badge>
                                <Badge variant="light">Canva Pro</Badge>
                                <Badge variant="light">Google Analytics</Badge>
                                <Badge variant="light">Pack Office</Badge>
                            </Group>
                        </Stack>
                    </Grid.Col>
                </Grid>

                <Divider my={50} label="Généré par Educ-AI Skills Hub" labelPosition="center" />
                <Center mb={100}>
                    <Button variant="default" onClick={() => window.location.reload()}>Quitter l'aperçu</Button>
                </Center>
            </Container>
        </div>
    );
}