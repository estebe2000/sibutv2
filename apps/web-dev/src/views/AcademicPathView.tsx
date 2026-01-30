import React from 'react';
import { Container, Paper, Title, Text, Stack, Group, ThemeIcon, Timeline, Progress, Badge, Accordion, Grid, Alert, ActionIcon, Tooltip } from '@mantine/core';
import { IconSchool, IconCheck, IconCircleDashed, IconFileCheck, IconPaperclip, IconChartBar, IconSparkles, IconInfoCircle, IconLock } from '@tabler/icons-react';
import { useMediaQuery } from '@mantine/hooks';

export function AcademicPathView() {
    const isMobile = useMediaQuery('(max-width: 768px)');
    
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
        <Container size="xl" py={isMobile ? "xs" : "md"}>
            <Stack gap="lg">
                {/* BANDEAU DÉMO */}
                <Alert color="orange" variant="filled" icon={<IconSparkles size={16} />} p={isMobile ? "xs" : "sm"}>
                    <Text fw={700} size={isMobile ? "xs" : "sm"}>MODE SIMULATION - DÉMONSTRATION</Text>
                    {!isMobile && <Text size="xs">Cet écran présente l'implémentation future du suivi global des compétences transverses.</Text>}
                </Alert>

                <Paper withBorder p={isMobile ? "sm" : "md"} radius="md" bg="grape.0">
                    <Group justify="space-between" wrap={isMobile ? "wrap" : "nowrap"}>
                        <Group gap="xs">
                            <IconSchool color="#be4bdb" size={isMobile ? 20 : 24} />
                            <Title order={isMobile ? 4 : 3}>Mon Parcours</Title>
                        </Group>
                        <Badge color="grape" variant="light" size={isMobile ? "sm" : "lg"}>BUT 2 - S3</Badge>
                    </Group>
                </Paper>

                <Grid gutter="md">
                    <Grid.Col span={{ base: 12, md: 4 }}>
                        <Stack gap="md">
                            <Paper withBorder p="md" radius="md" shadow="sm">
                                <Group mb="xs"><IconChartBar size={20} color="gray"/><Text fw={700} size="sm">Progression</Text></Group>
                                <Stack gap="sm">
                                    {competencies.map(c => (
                                        <div key={c.code}>
                                            <Group justify="space-between" mb={2}>
                                                <Text size="xs" fw={700}>{c.code} - {c.label}</Text>
                                                <Text size="xs" c="dimmed">{c.progress}%</Text>
                                            </Group>
                                            <Progress value={c.progress} color={c.color} size="xs" radius="xl" />
                                        </div>
                                    ))}
                                </Stack>
                            </Paper>

                            {!isMobile && (
                                <Paper withBorder p="md" radius="md" bg="gray.0">
                                    <Group mb="sm"><IconInfoCircle size={18} color="blue"/><Text size="sm" fw={600}>À propos</Text></Group>
                                    <Text size="xs" c="dimmed">
                                        Chaque compétence est validée par l'acquisition d'Apprentissages Critiques (AC). 
                                        Vous devez fournir au moins une preuve pour chaque AC.
                                    </Text>
                                </Paper>
                            )}
                        </Stack>
                    </Grid.Col>

                    <Grid.Col span={{ base: 12, md: 8 }}>
                        <Paper withBorder p={isMobile ? "sm" : "md"} radius="md" shadow="sm">
                            <Title order={isMobile ? 5 : 4} mb="lg">Détail des Apprentissages (AC)</Title>
                            
                            <Accordion variant="separated">
                                {competencies.map(c => (
                                    <Accordion.Item key={c.code} value={c.code}>
                                        <Accordion.Control 
                                            icon={<ThemeIcon color={c.color} variant="light" size="sm"><IconChartBar size={14}/></ThemeIcon>}
                                        >
                                            <Text fw={700} size={isMobile ? "sm" : "md"}>{c.code} : {c.label}</Text>
                                        </Accordion.Control>
                                        <Accordion.Panel>
                                            <Stack gap="xs">
                                                {c.acs.map(ac => (
                                                    <Paper key={ac.code} withBorder p="xs" bg="gray.0">
                                                        <Group justify="space-between" wrap="nowrap">
                                                            <Stack gap={2} style={{ flex: 1, minWidth: 0 }}>
                                                                <Text size="xs" fw={600} truncate>{ac.code} - {ac.label}</Text>
                                                                <Group gap="4">
                                                                    <Badge size="9px" p={4} color={ac.status === 'ACQUIS' ? 'green' : (ac.status === 'EN COURS' ? 'orange' : 'gray')}>
                                                                        {ac.status}
                                                                    </Badge>
                                                                    {ac.evidence > 0 && (
                                                                        <Group gap={2}>
                                                                            <IconPaperclip size={10} color="blue" />
                                                                            <Text size="10px" c="blue" fw={500}>{ac.evidence}</Text>
                                                                        </Group>
                                                                    )}
                                                                </Group>
                                                            </Stack>
                                                            <Group gap={4} wrap="nowrap">
                                                                <ActionIcon variant="light" color="blue" size="sm" disabled={ac.evidence === 0}><IconFileCheck size={14}/></ActionIcon>
                                                                <ActionIcon variant="outline" color="gray" size="sm"><IconPaperclip size={14}/></ActionIcon>
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
                        <ThemeIcon size={isMobile ? 30 : 40} radius="xl" color="gray" variant="light">
                            <IconLock size={isMobile ? 18 : 24} />
                        </ThemeIcon>
                        <Title order={isMobile ? 6 : 5}>Archives</Title>
                        <Text size="10px" c="dimmed">
                            Les dossiers de BUT 1 sont en cours de migration.
                        </Text>
                    </Stack>
                </Paper>
            </Stack>
        </Container>
    );
}