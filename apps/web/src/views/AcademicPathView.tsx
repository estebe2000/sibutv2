import React from 'react';
import { Container, Paper, Title, Text, Stack, Group, ThemeIcon, Timeline, Progress, Badge, Accordion, Grid, Alert, ActionIcon, Tooltip } from '@mantine/core';
import { IconSchool, IconCheck, IconCircleDashed, IconFileCheck, IconPaperclip, IconChartBar, IconSparkles, IconInfoCircle, IconLock } from '@tabler/icons-react';

export function AcademicPathView() {
    // Simulation de données pour l'étudiant tdtd
    const competencies = [
        {
            code: "C1",
            label: "Marketing",
            progress: 65,
            color: "blue",
            acs: [
                { code: "AC1.01", label: "Analyser les besoins des clients", status: "ACQUIS", evidence: 2 },
                { code: "AC1.02", label: "Définir un mix-marketing cohérent", status: "EN COURS", evidence: 1 },
                { code: "AC1.03", label: "Piloter une action de communication", status: "NON COMMENCÉ", evidence: 0 }
            ]
        },
        {
            code: "C2",
            label: "Vente",
            progress: 40,
            color: "green",
            acs: [
                { code: "AC2.01", label: "Prospecter des cibles pertinentes", status: "ACQUIS", evidence: 3 },
                { code: "AC2.02", label: "Négocier une offre commerciale", status: "NON COMMENCÉ", evidence: 0 }
            ]
        }
    ];

    return (
        <Container size="xl" py="md">
            <Stack gap="lg">
                {/* BANDEAU DÉMO */}
                <Alert color="orange" variant="filled" icon={<IconSparkles size={16} />}>
                    <Text fw={700}>MODE SIMULATION - DÉMONSTRATION "KARUTA-LIKE"</Text>
                    <Text size="xs">Cet écran présente l'implémentation future du suivi global des compétences transverses.</Text>
                </Alert>

                <Paper withBorder p="md" radius="md" bg="grape.0">
                    <Group justify="space-between">
                        <Group>
                            <IconSchool color="#be4bdb" />
                            <Title order={3}>Mon Parcours Scolaire & Compétences</Title>
                        </Group>
                        <Badge color="grape" variant="light" size="lg">Année 2 - Semestre 3</Badge>
                    </Group>
                </Paper>

                <Grid>
                    <Grid.Col span={{ base: 12, md: 4 }}>
                        <Stack gap="md">
                            <Paper withBorder p="md" radius="md" shadow="sm">
                                <Group mb="xs"><IconChartBar size={20} color="gray"/><Text fw={700}>Synthèse de progression</Text></Group>
                                <Stack gap="xs">
                                    {competencies.map(c => (
                                        <div key={c.code}>
                                            <Group justify="space-between" mb={5}>
                                                <Text size="xs" fw={700}>{c.code} - {c.label}</Text>
                                                <Text size="xs" c="dimmed">{c.progress}%</Text>
                                            </Group>
                                            <Progress value={c.progress} color={c.color} size="sm" radius="xl" />
                                        </div>
                                    ))}
                                </Stack>
                            </Paper>

                            <Paper withBorder p="md" radius="md" bg="gray.0">
                                <Group mb="sm"><IconInfoCircle size={18} color="blue"/><Text size="sm" fw={600}>À propos du référentiel</Text></Group>
                                <Text size="xs" c="dimmed">
                                    Chaque compétence est validée par l'acquisition d'Apprentissages Critiques (AC). 
                                    Vous devez fournir au moins une preuve pour chaque AC.
                                </Text>
                            </Paper>
                        </Stack>
                    </Grid.Col>

                    <Grid.Col span={{ base: 12, md: 8 }}>
                        <Paper withBorder p="md" radius="md" shadow="sm">
                            <Title order={4} mb="lg">Détail des Apprentissages Critiques (AC)</Title>
                            
                            <Accordion variant="separated">
                                {competencies.map(c => (
                                    <Accordion.Item key={c.code} value={c.code}>
                                        <Accordion.Control 
                                            icon={<ThemeIcon color={c.color} variant="light" size="sm"><IconChartBar size={14}/></ThemeIcon>}
                                        >
                                            <Text fw={700}>{c.code} : {c.label}</Text>
                                        </Accordion.Control>
                                        <Accordion.Panel>
                                            <Stack gap="xs">
                                                {c.acs.map(ac => (
                                                    <Paper key={ac.code} withBorder p="sm" bg="gray.0">
                                                        <Group justify="space-between">
                                                            <Stack gap={2}>
                                                                <Text size="sm" fw={600}>{ac.code} - {ac.label}</Text>
                                                                <Group gap="xs">
                                                                    <Badge size="xs" color={ac.status === 'ACQUIS' ? 'green' : (ac.status === 'EN COURS' ? 'orange' : 'gray')}>
                                                                        {ac.status}
                                                                    </Badge>
                                                                    {ac.evidence > 0 && (
                                                                        <Group gap={4}>
                                                                            <IconPaperclip size={12} color="blue" />
                                                                            <Text size="xs" c="blue" fw={500}>{ac.evidence} preuve(s)</Text>
                                                                        </Group>
                                                                    )}
                                                                </Group>
                                                            </Stack>
                                                            <Group>
                                                                <Tooltip label="Voir les preuves liées">
                                                                    <ActionIcon variant="light" color="blue" disabled={ac.evidence === 0}><IconFileCheck size={16}/></ActionIcon>
                                                                </Tooltip>
                                                                <Tooltip label="Ajouter une preuve">
                                                                    <ActionIcon variant="outline" color="gray"><IconPaperclip size={16}/></ActionIcon>
                                                                </Tooltip>
                                                            </Group>
                                                        </Group>
                                                    </Paper>
                                                ))}
                                            </Stack>
                                        </Accordion.Panel>
                                    </Accordion.Item>
                                ))}
                            </Accordion>
                        </Paper>
                    </Grid.Col>
                </Grid>

                <Paper p="xl" withBorder radius="md" bg="gray.0" style={{ borderStyle: 'dashed' }}>
                    <Stack align="center" ta="center" gap="xs">
                        <ThemeIcon size={40} radius="xl" color="gray" variant="light">
                            <IconLock size={24} />
                        </ThemeIcon>
                        <Title order={5}>Archives des années précédentes</Title>
                        <Text size="xs" c="dimmed">
                            Les dossiers de BUT 1 sont en cours de migration depuis l'ancienne plateforme.
                        </Text>
                    </Stack>
                </Paper>
            </Stack>
        </Container>
    );
}