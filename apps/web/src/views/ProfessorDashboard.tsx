import React from 'react';
import { Container, Title, Text, Grid, Paper, Group, ThemeIcon, Badge, Button, Stack, Loader, Progress, Divider } from '@mantine/core';
import { IconBook, IconDatabase, IconClock, IconUsers, IconCrown, IconArrowRight } from '@tabler/icons-react';

export function ProfessorDashboard({ user, curriculum }: any) {
  if (!user || !curriculum || !curriculum.activities) return <Center><Loader /></Center>;

  // Filtrer les activités où le prof est responsable ou intervenant
  const myActivities = curriculum.activities.filter((a: any) => 
    a.owner_id === user.ldap_uid || a.intervenants_identifies?.includes(user.ldap_uid)
  );

  // Filtrer les ressources
  const myResources = curriculum.resources?.filter((r: any) => 
    r.owner_id === user.ldap_uid || r.intervenants_identifies?.includes(user.ldap_uid)
  );

  // Calculer la charge (approximative)
  const totalHours = myResources.reduce((acc: number, curr: any) => acc + (curr.hours || 0), 0) +
                     myActivities.reduce((acc: number, curr: any) => acc + (curr.hours || 0), 0);

  return (
    <Container size="xl" py="xl">
        <Group justify="space-between" mb={40}>
            <div>
                <Title order={2}>Bonjour, {user.full_name}</Title>
                <Text c="dimmed">Espace Enseignant - BUT Techniques de Commercialisation</Text>
            </div>
            <Paper px="md" py="xs" radius="md" withBorder>
                <Group>
                    <ThemeIcon size="lg" variant="light" color="blue"><IconClock size={20} /></ThemeIcon>
                    <div>
                        <Text size="xs" c="dimmed" fw={700}>VOLUME HORAIRE RESP.</Text>
                        <Text fw={700}>{totalHours} h</Text>
                    </div>
                </Group>
            </Paper>
        </Group>

        <Grid>
            {/* Colonne Principale : Mes Modules */}
            <Grid.Col span={{ base: 12, md: 8 }}>
                <Title order={4} mb="md">Mes Responsabilités & Interventions</Title>
                
                {myActivities.length === 0 && myResources.length === 0 ? (
                    <Paper withBorder p="xl" ta="center" bg="gray.0">
                        <Text c="dimmed">Aucun module ne vous est assigné pour le moment.</Text>
                    </Paper>
                ) : (
                    <Stack gap="md">
                        {/* SAÉs */}
                        {myActivities.map((act: any) => (
                            <Paper key={act.id} withBorder p="md" radius="md" shadow="xs" style={{ borderLeft: '4px solid #fd7e14' }}>
                                <Group justify="space-between" mb="xs">
                                    <Group gap="xs">
                                        <Badge color="orange" variant="light">{act.code}</Badge>
                                        <Text fw={600}>{act.label}</Text>
                                    </Group>
                                    {act.owner_id === user.ldap_uid && <Badge leftSection={<IconCrown size={10} />} color="yellow" variant="filled">Responsable</Badge>}
                                </Group>
                                <Text size="sm" lineClamp={2} c="dimmed" mb="md">{act.description}</Text>
                                <Group justify="space-between">
                                    <Group gap="xs">
                                        <Badge size="xs" color="gray" variant="outline">{act.hours}h</Badge>
                                        <Badge size="xs" color="gray" variant="outline">Semestre {act.semester}</Badge>
                                    </Group>
                                </Group>
                            </Paper>
                        ))}

                        {/* Ressources */}
                        {myResources.map((res: any) => (
                            <Paper key={res.id} withBorder p="md" radius="md" shadow="xs" style={{ borderLeft: '4px solid #20c997' }}>
                                <Group justify="space-between" mb="xs">
                                    <Group gap="xs">
                                        <Badge color="teal" variant="light">{res.code}</Badge>
                                        <Text fw={600}>{res.label}</Text>
                                    </Group>
                                    {res.owner_id === user.ldap_uid && <Badge leftSection={<IconCrown size={10} />} color="yellow" variant="filled">Responsable</Badge>}
                                </Group>
                                <Text size="sm" lineClamp={2} c="dimmed" mb="md">{res.description}</Text>
                                <Group justify="space-between">
                                    <Group gap="xs">
                                        <Badge size="xs" color="gray" variant="outline">{res.hours}h</Badge>
                                        <Badge size="xs" color="gray" variant="outline">{res.pathway}</Badge>
                                    </Group>
                                </Group>
                            </Paper>
                        ))}
                    </Stack>
                )}
            </Grid.Col>

            {/* Colonne Latérale : Outils & Liens */}
            <Grid.Col span={{ base: 12, md: 4 }}>
                <Stack>
                    <Paper withBorder p="md" radius="md">
                        <Title order={5} mb="md">Accès Rapide</Title>
                        <Stack gap="xs">
                            <Button variant="light" justify="space-between" rightSection={<IconArrowRight size={16} />} fullWidth component="a" href="https://odoo.educ-ai.fr" target="_blank">
                                Odoo (ERP)
                            </Button>
                            <Button variant="light" color="indigo" justify="space-between" rightSection={<IconArrowRight size={16} />} fullWidth component="a" href="https://mattermost.educ-ai.fr" target="_blank">
                                Mattermost
                            </Button>
                            <Button variant="light" color="cyan" justify="space-between" rightSection={<IconArrowRight size={16} />} fullWidth component="a" href="https://nextcloud.educ-ai.fr" target="_blank">
                                Nextcloud
                            </Button>
                        </Stack>
                    </Paper>

                    <Paper withBorder p="md" radius="md" bg="blue.0">
                        <Group mb="xs">
                            <IconUsers size={20} color="#228be6" />
                            <Text fw={600}>Mes Groupes</Text>
                        </Group>
                        <Text size="xs" c="dimmed">Fonctionnalité à venir : liste des groupes d'étudiants dont vous êtes tuteur ou enseignant principal.</Text>
                    </Paper>
                </Stack>
            </Grid.Col>
        </Grid>
    </Container>
  );
}

function Center({children}: {children: React.ReactNode}) {
    return <div style={{display: 'flex', justifyContent: 'center', alignItems: 'center', height: '100%'}}>{children}</div>
}
