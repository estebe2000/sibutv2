import React, { useState, useEffect } from 'react';
import { Container, Title, Text, Grid, Paper, Group, ThemeIcon, Badge, Button, Stack, Loader, Modal, Center } from '@mantine/core';
import { IconClock, IconUsers, IconCrown, IconArrowRight, IconSettings, IconTargetArrow } from '@tabler/icons-react';
import { ActivityGroupManager } from '../components/ActivityGroupManager';
import api from '../services/api';

import { RubricBuilder } from '../components/RubricBuilder';

export function ProfessorDashboard({ user, curriculum }: any) {
  const [allStudents, setAllStudents] = useState([]);
  const [tutoredStudents, setTutoredStudents] = useState([]);
  const [selectedActivity, setSelectedActivity] = useState<any>(null);
  const [selectedEvalActivity, setSelectedEvalActivity] = useState<any>(null);
  const [selectedTutoredStudent, setSelectedTutoredStudent] = useState<any>(null);

  useEffect(() => {
    const fetchData = async () => {
        try {
            const [usersRes, tutorRes] = await Promise.all([
                api.get('/users'),
                api.get(`/activity-management/teacher/${user.ldap_uid}/tutored-students`)
            ]);
            setAllStudents(usersRes.data.filter((u: any) => u.role === 'STUDENT'));
            setTutoredStudents(tutorRes.data);
        } catch (e) { console.error(e); }
    };
    fetchData();
  }, [user.ldap_uid]);

  if (!user || !curriculum || !curriculum.activities) return <Center><Loader /></Center>;

  // Filtrer les activités où le prof est responsable ou intervenant
  const myActivities = curriculum.activities.filter((a: any) => 
    a.responsible === user.full_name || a.owner_id === user.ldap_uid
  );

  const myResources = curriculum.resources?.filter((r: any) => 
    r.responsible === user.full_name || r.owner_id === user.ldap_uid
  );

  const totalHours = (myResources?.reduce((acc: number, curr: any) => acc + (curr.hours || 0), 0) || 0) +
                     (myActivities?.reduce((acc: number, curr: any) => acc + (curr.hours || 0), 0) || 0);

  return (
    <Container size="xl" py="xl">
        <Group justify="space-between" mb={40}>
            <div>
                <Title order={2}>Bonjour, {user.full_name}</Title>
                <Text c="dimmed">Espace Enseignant - BUT Techniques de Commercialisation</Text>
            </div>
            <Paper px="md" py="xs" radius="md" withBorder shadow="xs">
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
            <Grid.Col span={{ base: 12, md: 8 }}>
                <Title order={4} mb="md">Mes SAÉ (Gestion des Groupes)</Title>
                
                {myActivities.length === 0 ? (
                    <Paper withBorder p="xl" ta="center" bg="gray.0" radius="md">
                        <Text c="dimmed">Aucune SAÉ ne vous est assignée comme responsable.</Text>
                    </Paper>
                ) : (
                    <Stack gap="md">
                        {myActivities.map((act: any) => (
                            <Paper key={act.id} withBorder p="md" radius="md" shadow="xs" style={{ borderLeft: '4px solid #fd7e14' }}>
                                <Group justify="space-between" mb="xs">
                                    <Group gap="xs">
                                        <Badge color="orange" variant="light">{act.code}</Badge>
                                        <Text fw={600}>{act.label}</Text>
                                    </Group>
                                    <Group gap="xs">
                                        <Button 
                                            size="xs" 
                                            variant="light" 
                                            color="orange" 
                                            leftSection={<IconSettings size={14}/>}
                                            onClick={() => setSelectedActivity(act)}
                                        >
                                            Groupes
                                        </Button>
                                        <Button 
                                            size="xs" 
                                            variant="light" 
                                            color="teal" 
                                            leftSection={<IconTargetArrow size={14}/>}
                                            onClick={() => setSelectedEvalActivity(act)}
                                        >
                                            Évaluation
                                        </Button>
                                    </Group>
                                </Group>
                                <Text size="sm" lineClamp={2} c="dimmed" mb="md">{act.description}</Text>
                                <Group justify="space-between">
                                    <Badge size="xs" color="gray" variant="outline">Semestre {act.semester}</Badge>
                                </Group>
                            </Paper>
                        ))}
                    </Stack>
                )}

                <Title order={4} mt="xl" mb="md">Mes Ressources</Title>
                <Stack gap="md">
                    {myResources?.map((res: any) => (
                        <Paper key={res.id} withBorder p="md" radius="md" shadow="xs" style={{ borderLeft: '4px solid #20c997' }}>
                            <Group gap="xs" mb="xs">
                                <Badge color="teal" variant="light">{res.code}</Badge>
                                <Text fw={600}>{res.label}</Text>
                            </Group>
                            <Text size="sm" lineClamp={2} c="dimmed">{res.description}</Text>
                        </Paper>
                    ))}
                </Stack>
            </Grid.Col>

            <Grid.Col span={{ base: 12, md: 4 }}>
                <Stack>
                    <Paper withBorder p="md" radius="md">
                        <Title order={5} mb="md">Accès Services</Title>
                        <Stack gap="xs">
                            <Button variant="light" justify="space-between" rightSection={<IconArrowRight size={16} />} fullWidth component="a" href={`https://odoo.${window.location.hostname.split('.').slice(-2).join('.')}`} target="_blank">Odoo (ERP)</Button>
                            <Button variant="light" color="indigo" justify="space-between" rightSection={<IconArrowRight size={16} />} fullWidth component="a" href={`https://mattermost.${window.location.hostname.split('.').slice(-2).join('.')}`} target="_blank">Mattermost</Button>
                            <Button variant="light" color="cyan" justify="space-between" rightSection={<IconArrowRight size={16} />} fullWidth component="a" href={`https://nextcloud.${window.location.hostname.split('.').slice(-2).join('.')}`} target="_blank">Nextcloud</Button>
                        </Stack>
                    </Paper>

                    <Paper withBorder p="md" radius="md" bg="blue.0">
                        <Group mb="xs">
                            <IconUsers size={20} color="#228be6" />
                            <Text fw={600}>Tutorat de Stage ({tutoredStudents.length})</Text>
                        </Group>
                        {tutoredStudents.length === 0 ? (
                            <Text size="xs" c="dimmed">Vous ne suivez aucun étudiant pour le moment.</Text>
                        ) : (
                            <Stack gap="xs">
                                {tutoredStudents.map((s: any) => (
                                    <Paper key={s.ldap_uid} p="xs" radius="xs" withBorder style={{ cursor: 'pointer' }} onClick={() => setSelectedTutoredStudent(s)}>
                                        <Text size="xs" fw={600}>{s.full_name}</Text>
                                        <Text size="xs" c="dimmed">{s.email}</Text>
                                    </Paper>
                                ))}
                            </Stack>
                        )}
                    </Paper>
                </Stack>
            </Grid.Col>
        </Grid>

        <Modal opened={!!selectedTutoredStudent} onClose={() => setSelectedTutoredStudent(null)} title={`Suivi de Stage : ${selectedTutoredStudent?.full_name}`}>
            {selectedTutoredStudent && <ProfessorInternshipManager student={selectedTutoredStudent} />}
        </Modal>

        <Modal opened={!!selectedEvalActivity} onClose={() => setSelectedEvalActivity(null)} title="Configuration de la Grille d'Évaluation" size="90%">
            {selectedEvalActivity && <RubricBuilder activity={selectedEvalActivity} />}
        </Modal>

        <Modal 
            opened={!!selectedActivity} 
            onClose={() => setSelectedActivity(null)} 
            title="Gestionnaire de Groupes Pédagogiques"
            size="xl"
        >
            {selectedActivity && (
                <ActivityGroupManager 
                    activity={selectedActivity} 
                    allStudents={allStudents} 
                />
            )}
        </Modal>
    </Container>
  );
}