import React from 'react';
import { Container, Paper, Title, Text, Group, Stack, Badge, ThemeIcon, Alert, ActionIcon, Loader, Center, Divider, Accordion } from '@mantine/core';
import { IconUser, IconSchool, IconInfoCircle, IconTimeline, IconFileText, IconDownload, IconBook, IconFolder, IconFileUpload, IconBriefcase } from '@tabler/icons-react';

interface StudentDashboardProps {
  user: any;
  groups: any[];
  curriculum: any;
}

export function StudentDashboard({ user, groups, curriculum }: StudentDashboardProps) {
  // Debug
  console.log("StudentDashboard - User:", user);
  console.log("StudentDashboard - Groups count:", groups?.length);
  
  // Trouver le groupe de l'étudiant
  const studentGroup = groups?.find(g => Number(g.id) === Number(user?.group_id));
  console.log("StudentDashboard - Found Group:", studentGroup);

  if (!curriculum || !curriculum.activities || !groups) {
    return <Center h="50vh"><Loader size="lg" /></Center>;
  }

  // 1. Filtrage des Activités (SAÉ, Stages, etc.)
  const filteredActivities = curriculum.activities.filter((a: any) => {
    if (!studentGroup) return false;
    return a.level === studentGroup.year && 
           (a.pathway === 'Tronc Commun' || a.pathway.toLowerCase() === studentGroup.pathway.toLowerCase());
  });

  // 2. Filtrage des Ressources
  const filteredResources = curriculum.resources.filter((r: any) => {
    if (!studentGroup || !r.code) return false;
    const codePrefix = parseInt(r.code.replace('R', '').split('.')[0]);
    let matchLevel = false;
    if (studentGroup.year === 1 && (codePrefix === 1 || codePrefix === 2)) matchLevel = true;
    if (studentGroup.year === 2 && (codePrefix === 3 || codePrefix === 4)) matchLevel = true;
    if (studentGroup.year === 3 && (codePrefix === 5 || codePrefix === 6)) matchLevel = true;
    
    if (!matchLevel) return false;

    return r.pathway === 'Tronc Commun' || r.pathway.toLowerCase() === studentGroup.pathway.toLowerCase();
  });

  return (
    <Container size="md" py="xl">
      <Stack gap="lg">
        <Paper withBorder p="xl" radius="md" shadow="sm" bg="blue.0">
          <Group justify="space-between">
            <Stack gap={0}>
              <Title order={2} c="blue.9">Bienvenue, {user?.full_name || user?.ldap_uid}</Title>
              <Text c="dimmed">Espace Étudiant - BUT Techniques de Commercialisation</Text>
            </Stack>
            <ThemeIcon size={60} radius="xl" variant="light" color="blue">
              <IconUser size={34} />
            </ThemeIcon>
          </Group>
        </Paper>

        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '20px' }}>
          <Paper withBorder p="lg" radius="md" shadow="xs">
            <Group mb="md">
              <IconSchool color="var(--mantine-color-blue-6)" />
              <Title order={4}>Ma Scolarité</Title>
            </Group>
            {studentGroup ? (
              <Stack gap="xs">
                <Group justify="space-between">
                  <Text size="sm" fw={500}>Groupe :</Text>
                  <Badge size="lg">{studentGroup.name}</Badge>
                </Group>
                <Group justify="space-between">
                  <Text size="sm" fw={500}>Année :</Text>
                  <Badge variant="outline" color="blue">BUT {studentGroup.year}</Badge>
                </Group>
                <Group justify="space-between">
                  <Text size="sm" fw={500}>Parcours :</Text>
                  <Badge variant="light" color="grape">{studentGroup.pathway}</Badge>
                </Group>
                <Group justify="space-between">
                  <Text size="sm" fw={500}>Type :</Text>
                  <Badge variant="dot" color="teal">{studentGroup.formation_type === 'FI' ? 'Initiale' : 'Alternance'}</Badge>
                </Group>
              </Stack>
            ) : (
              <Text size="sm" c="orange" fs="italic">Vous n'avez pas encore été assigné à un groupe par l'administration.</Text>
            )}
          </Paper>

          <Paper withBorder p="lg" radius="md" shadow="xs">
            <Group mb="md">
              <IconTimeline color="var(--mantine-color-indigo-6)" />
              <Title order={4}>Mon Profil</Title>
            </Group>
            <Stack gap="xs">
              <Group justify="space-between">
                <Text size="sm" fw={500}>Identifiant :</Text>
                <Text size="sm">{user?.ldap_uid}</Text>
              </Group>
              <Group justify="space-between">
                <Text size="sm" fw={500}>Email :</Text>
                <Text size="sm">{user?.email || 'Non renseigné'}</Text>
              </Group>
            </Stack>
          </Paper>
        </div>

        <Alert variant="light" color="indigo" title="En cours de développement" icon={<IconInfoCircle />}>
          Votre espace de suivi des compétences et votre portfolio Nextcloud sont en cours de configuration. 
          Bientôt, vous pourrez uploader vos preuves et suivre l'acquisition de vos apprentissages critiques ici.
        </Alert>

        <Paper withBorder p="lg" radius="md" shadow="xs">
          <Group mb="md" justify="space-between">
            <Group>
              <IconFileText color="var(--mantine-color-blue-6)" />
              <Title order={4}>Mes Fiches de Formation (PDF)</Title>
            </Group>
            <Badge variant="light">{filteredActivities.length + filteredResources.length} documents</Badge>
          </Group>
          
          <Divider mb="md" />

          <Accordion variant="separated">
            <Accordion.Item value="activities">
              <Accordion.Control icon={<IconSchool size={18} color="orange" />}>
                <Text fw={700}>SAÉ & Activités ({filteredActivities.length})</Text>
              </Accordion.Control>
              <Accordion.Panel>
                <Stack gap="xs">
                  {filteredActivities.sort((a: any, b: any) => a.code.localeCompare(b.code)).map((act: any) => (
                    <Paper key={act.id} withBorder p="xs" radius="sm" bg="gray.0">
                      <Group justify="space-between">
                        <Group gap="xs">
                          <Badge size="xs" variant="filled" color="orange">{act.code}</Badge>
                          <Text size="sm" fw={500}>{act.label}</Text>
                        </Group>
                        <ActionIcon 
                          component="a" 
                          href={`/api/activities/${act.id}/pdf`}
                          target="_blank"
                          variant="light" 
                          color="orange" 
                          size="md"
                        >
                          <IconDownload size={16} />
                        </ActionIcon>
                      </Group>
                    </Paper>
                  ))}
                </Stack>
              </Accordion.Panel>
            </Accordion.Item>

            <Accordion.Item value="resources">
              <Accordion.Control icon={<IconBook size={18} color="teal" />}>
                <Text fw={700}>Ressources ({filteredResources.length})</Text>
              </Accordion.Control>
              <Accordion.Panel>
                <Stack gap="xs">
                  {filteredResources.sort((a: any, b: any) => a.code.localeCompare(b.code)).map((res: any) => (
                    <Paper key={res.id} withBorder p="xs" radius="sm" bg="gray.0">
                      <Group justify="space-between">
                        <Group gap="xs">
                          <Badge size="xs" variant="filled" color="teal">{res.code}</Badge>
                          <Text size="sm" fw={500}>{res.label}</Text>
                        </Group>
                        <ActionIcon 
                          component="a" 
                          href={`/api/resources/${res.id}/pdf`}
                          target="_blank"
                          variant="light" 
                          color="teal" 
                          size="md"
                        >
                          <IconDownload size={16} />
                        </ActionIcon>
                      </Group>
                    </Paper>
                  ))}
                </Stack>
              </Accordion.Panel>
            </Accordion.Item>
          </Accordion>
        </Paper>

        <Paper withBorder p="lg" radius="md" shadow="xs">
          <Group mb="md">
            <IconFolder color="var(--mantine-color-indigo-6)" />
            <Title order={4}>Mon Portfolio & Preuves</Title>
          </Group>
          
          <Divider mb="md" />

          <Stack gap="md">
            <Alert variant="outline" color="gray" icon={<IconBriefcase size={16} />}>
              <Text size="sm" fw={500}>Gestionnaire de Portfolio (Bientôt disponible)</Text>
              <Text size="xs" c="dimmed">Espace centralisé pour gérer l'ensemble de vos documents et preuves de compétences.</Text>
            </Alert>

            <Text size="xs" fw={700} c="dimmed" tt="uppercase">Dépôts par Activité</Text>
            <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '10px' }}>
              {filteredActivities.map((act: any) => (
                <Paper key={`upload-${act.id}`} withBorder p="xs" radius="sm" style={{ borderStyle: 'dashed' }}>
                  <Group justify="space-between">
                    <Stack gap={0}>
                      <Text size="xs" fw={700}>{act.code}</Text>
                      <Text size="10px" c="dimmed" truncate>{act.label}</Text>
                    </Stack>
                    <Badge variant="light" color="gray" size="xs">0 fichier</Badge>
                  </Group>
                </Paper>
              ))}
            </div>
          </Stack>
        </Paper>
      </Stack>
    </Container>
  );
}
