import React, { useState, useEffect } from 'react';
import { Container, Paper, Title, Text, Group, Stack, Badge, ThemeIcon, Loader, Center } from '@mantine/core';
import { IconUser, IconSchool, IconTimeline, IconBriefcase } from '@tabler/icons-react';
import api from '../services/api';
import { useMediaQuery } from '@mantine/hooks';

export function StudentDashboard({ user, groups }: any) {
  const isMobile = useMediaQuery('(max-width: 768px)');
  const [tutor, setTutor] = useState<any>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const fetchStudentData = async () => {
      try {
        const tutorRes = await api.get(`/activity-management/student/${user.ldap_uid}/tutor`);
        setTutor(tutorRes.data);
      } catch (e) { console.error("Error fetching data", e); }
      setLoading(false);
    };
    fetchStudentData();
  }, [user.ldap_uid]);

  if (loading) {
    return <Center h="50vh"><Loader size="lg" /></Center>;
  }

  const studentGroup = groups?.find((g:any) => Number(g.id) === Number(user?.group_id));

  return (
    <Container size="md" py={isMobile ? "md" : "xl"}>
      <Stack gap="lg">
        <Paper withBorder p={isMobile ? "md" : "xl"} radius="md" shadow="sm" bg="blue.0">
          <Group justify="space-between">
            <Stack gap={0} style={{ flex: 1 }}>
              <Title order={isMobile ? 3 : 2} c="blue.9">Bienvenue, {user?.full_name || user?.ldap_uid}</Title>
              <Text c="dimmed" size={isMobile ? "sm" : "md"}>Espace Étudiant - BUT Techniques de Commercialisation</Text>
            </Stack>
            {!isMobile && <ThemeIcon size={60} radius="xl" variant="light" color="blue"><IconUser size={34} /></ThemeIcon>}
          </Group>
        </Paper>

        <div style={{ display: 'grid', gridTemplateColumns: isMobile ? '1fr' : '1fr 1fr 1fr', gap: '20px' }}>
            {/* Tutorat (First on mobile if assigned) */}
            <Paper withBorder p="lg" radius="md" shadow="xs" bg="blue.0" style={{ order: (isMobile && tutor) ? -1 : 'unset' }}>
                <Group mb="md"><IconBriefcase color="blue" /><Title order={4}>Mon Tutorat</Title></Group>
                <Stack gap="xs">
                    <Text size="xs" c="dimmed" fw={700}>TUTEUR DE STAGE</Text>
                    {tutor ? (
                        <div><Text fw={600} size="sm">{tutor.full_name}</Text><Text size="xs" c="blue">{tutor.email}</Text></div>
                    ) : <Text size="xs" c="dimmed" fs="italic">Non assigné</Text>}
                </Stack>
            </Paper>

            <Paper withBorder p="lg" radius="md" shadow="xs">
                <Group mb="md"><IconSchool color="blue" /><Title order={4}>Ma Scolarité</Title></Group>
                {studentGroup ? (
                <Stack gap="xs">
                    <Group justify="space-between"><Text size="sm">Groupe :</Text><Badge size="lg">{studentGroup.name}</Badge></Group>
                    <Group justify="space-between"><Text size="sm">Année :</Text><Badge variant="outline">BUT {studentGroup.year}</Badge></Group>
                </Stack>
                ) : <Text size="sm" c="orange" fs="italic">Non assigné.</Text>}
            </Paper>

            <Paper withBorder p="lg" radius="md" shadow="xs">
                <Group mb="md"><IconTimeline color="indigo" /><Title order={4}>Mon Profil</Title></Group>
                <Stack gap="xs">
                <Group justify="space-between"><Text size="sm">ID :</Text><Text size="sm">{user?.ldap_uid}</Text></Group>
                <Group justify="space-between"><Text size="sm">Email :</Text><Text size="sm" truncate>{user?.email || 'N/A'}</Text></Group>
                </Stack>
            </Paper>
        </div>

        <Paper withBorder p="xl" radius="md" bg="gray.0">
            <Stack align="center" gap="xs">
                <IconTimeline size={40} color="var(--mantine-color-blue-6)" />
                <Title order={3}>Tableau de bord simplifié</Title>
                <Text c="dimmed" ta="center">
                    Utilisez {isMobile ? "la barre de navigation ci-dessous" : "le menu latéral"} pour accéder à vos Stages, votre Portfolio ou votre Espace Odoo.
                </Text>
            </Stack>
        </Paper>
      </Stack>
    </Container>
  );
}
