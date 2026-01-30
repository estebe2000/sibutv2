import React, { useState, useEffect } from 'react';
import { Container, Grid, Paper, Text, Group, Title, Stack, Badge, RingProgress, Center, ThemeIcon, Loader, Divider } from '@mantine/core';
import { DonutChart, BarChart } from '@mantine/charts';
import { IconUsers, IconSchool, IconBriefcase, IconTournament, IconArrowUpRight, IconUserCheck, IconLayoutDashboard } from '@tabler/icons-react';
import api from '../services/api';

export function AdminDashboardView() {
    const [stats, setStats] = useState<any>(null);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        api.get('/stats/summary').then(res => {
            setStats(res.data);
            setLoading(false);
        }).catch(e => console.error(e));
    }, []);

    if (loading) return <Center h={400}><Stack align="center"><Loader size="xl" /><Text c="dimmed">Génération des statistiques stratégiques...</Text></Stack></Center>;

    const tutorPercent = Math.round((stats.tutor_ratio.assigned / stats.tutor_ratio.total) * 100) || 0;

    return (
        <Container size="xl" py="md">
            <Group justify="space-between" mb="xl">
                <div>
                    <Title order={2} c="blue.9">Tableau de Bord Direction</Title>
                    <Text size="sm" c="dimmed">Aperçu analytique du département Techniques de Commercialisation</Text>
                </div>
                <Badge size="xl" variant="dot" color="blue">Année 2025-2026</Badge>
            </Group>

            {/* KPI CARDS */}
            <Grid mb="xl">
                <Grid.Col span={{ base: 12, sm: 6, lg: 3 }}>
                    <StatCard label="Étudiants" value={stats.kpis.students} icon={IconUsers} color="blue" trend="+12% vs N-1" />
                </Grid.Col>
                <Grid.Col span={{ base: 12, sm: 6, lg: 3 }}>
                    <StatCard label="Enseignants" value={stats.kpis.professors} icon={IconSchool} color="teal" />
                </Grid.Col>
                <Grid.Col span={{ base: 12, sm: 6, lg: 3 }}>
                    <StatCard label="Promotions / Groupes" value={stats.kpis.groups} icon={IconTournament} color="orange" />
                </Grid.Col>
                <Grid.Col span={{ base: 12, sm: 6, lg: 3 }}>
                    <StatCard label="SAÉ & Projets" value={stats.kpis.activities} icon={IconBriefcase} color="indigo" />
                </Grid.Col>
            </Grid>

            <Grid gutter="md">
                {/* Répartition par Année */}
                <Grid.Col span={{ base: 12, md: 4 }}>
                    <Paper withBorder p="md" radius="md" h="100%">
                        <Title order={4} mb="lg">Effectifs par Niveau</Title>
                        <DonutChart 
                            data={stats.years_distribution.map((y: any, i: number) => ({ name: y.year, value: y.count, color: ['blue.6', 'blue.4', 'blue.2'][i] }))}
                            withLabelsLine
                            labelsType="value"
                            withLabels
                            h={250}
                        />
                    </Paper>
                </Grid.Col>

                {/* Répartition par Parcours */}
                <Grid.Col span={{ base: 12, md: 5 }}>
                    <Paper withBorder p="md" radius="md" h="100%">
                        <Title order={4} mb="lg">Répartition par Parcours (BUT 2 & 3)</Title>
                        <BarChart
                            h={250}
                            data={stats.pathway_distribution}
                            dataKey="name"
                            series={[{ name: 'value', color: 'indigo.6', label: 'Étudiants' }]}
                            tickLine="y"
                        />
                    </Paper>
                </Grid.Col>

                {/* Suivi Tutorat */}
                <Grid.Col span={{ base: 12, md: 3 }}>
                    <Paper withBorder p="md" radius="md" h="100%" bg="blue.0">
                        <Title order={4} mb="xs">Suivi de Tutorat</Title>
                        <Text size="xs" c="dimmed" mb="xl">Taux d'assignation des tuteurs de stage</Text>
                        <Center>
                            <RingProgress
                                size={180}
                                thickness={16}
                                roundCaps
                                sections={[{ value: tutorPercent, color: 'blue' }]}
                                label={
                                    <Center>
                                        <Stack gap={0} align="center">
                                            <Text fw={700} size="xl">{tutorPercent}%</Text>
                                            <Text size="xs" c="dimmed">Assignés</Text>
                                        </Stack>
                                    </Center>
                                }
                            />
                        </Center>
                        <Stack gap="xs" mt="lg">
                            <Group justify="space-between">
                                <Text size="xs" fw={500}>Total Étudiants :</Text>
                                <Text size="xs" fw={700}>{stats.tutor_ratio.total}</Text>
                            </Group>
                            <Group justify="space-between">
                                <Text size="xs" fw={500}>Tutorés :</Text>
                                <Text size="xs" fw={700} c="blue">{stats.tutor_ratio.assigned}</Text>
                            </Group>
                        </Stack>
                    </Paper>
                </Grid.Col>
            </Grid>

            {/* Section Activités Récentes ou Alertes */}
            <Title order={3} mt="xl" mb="md">Alertes de Gestion</Title>
            <Grid>
                <Grid.Col span={6}>
                    <Paper withBorder p="sm" radius="md">
                        <Group>
                            <ThemeIcon color="orange" variant="light" size="lg"><IconBriefcase size={20}/></ThemeIcon>
                            <div>
                                <Text fw={700} size="sm">SAÉ sans grilles d'évaluation</Text>
                                <Text size="xs" c="dimmed">4 SAÉ nécessitent l'attention des responsables de module.</Text>
                            </div>
                        </Group>
                    </Paper>
                </Grid.Col>
                <Grid.Col span={6}>
                    <Paper withBorder p="sm" radius="md">
                        <Group>
                            <ThemeIcon color="red" variant="light" size="lg"><IconUserCheck size={20}/></ThemeIcon>
                            <div>
                                <Text fw={700} size="sm">Étudiants en attente de groupe</Text>
                                <Text size="xs" c="dimmed">{stats.kpis.students - stats.tutor_ratio.total} étudiants ne sont pas encore dispatchés.</Text>
                            </div>
                        </Group>
                    </Paper>
                </Grid.Col>
            </Grid>
        </Container>
    );
}

function StatCard({ label, value, icon: Icon, color, trend }: any) {
    return (
        <Paper withBorder p="md" radius="md" shadow="xs">
            <Group justify="space-between">
                <div>
                    <Text size="xs" c="dimmed" fw={700} tt="uppercase">{label}</Text>
                    <Text fw={700} size="xl">{value}</Text>
                </div>
                <ThemeIcon color={color} variant="light" size="xl" radius="md">
                    <Icon size={24} />
                </ThemeIcon>
            </Group>
            {trend && (
                <Group gap="xs" mt="sm">
                    <Text c="teal" size="xs" fw={700}>{trend}</Text>
                    <IconArrowUpRight size={14} color="teal" />
                </Group>
            )}
        </Paper>
    );
}
