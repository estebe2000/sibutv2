import React, { useState, useEffect } from 'react';
import { Container, Paper, Title, Text, Group, Stack, Badge, ThemeIcon, Alert, ActionIcon, Loader, Center, Divider, Accordion, FileInput } from '@mantine/core';
import { IconUser, IconSchool, IconInfoCircle, IconTimeline, IconFileText, IconDownload, IconBook, IconFolder, IconFileUpload, IconBriefcase, IconTrash, IconLock } from '@tabler/icons-react';
import { notifications } from '@mantine/notifications';
import api from '../services/api';
import OdooWidget from '../components/OdooWidget';

interface StudentDashboardProps {
  user: any;
  groups: any[];
  curriculum: any;
}

export function StudentDashboard({ user, groups, curriculum }: StudentDashboardProps) {
  const [fiches, setFiches] = useState<any[]>([]);
  const [uploadedFiles, setUploadedFiles] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [uploading, setUploading] = useState<string | null>(null); // ID de l'entité en cours d'upload

  // Trouver le groupe de l'étudiant
  const studentGroup = groups?.find(g => Number(g.id) === Number(user?.group_id));

  const fetchStudentData = async () => {
    try {
      const [fichesRes, filesRes] = await Promise.all([
        api.get('/fiches/list'),
        api.get('/portfolio/files')
      ]);
      setFiches(fichesRes.data);
      setUploadedFiles(filesRes.data);
    } catch (e) { console.error("Error fetching data", e); }
    setLoading(false);
  };

  useEffect(() => {
    fetchStudentData();
  }, []);

  const handleUpload = async (file: File | null, entityType: string, entityId: string) => {
    if (!file) return;
    setUploading(entityId);
    const formData = new FormData();
    formData.append('file', file);
    try {
      await api.post(`/portfolio/upload?entity_type=${entityType}&entity_id=${entityId}`, formData);
      notifications.show({ title: 'Succès', message: 'Fichier déposé', color: 'green' });
      fetchStudentData();
    } catch (e) {
      notifications.show({ title: 'Erreur', message: 'Échec de l\'envoi', color: 'red' });
    }
    setUploading(null);
  };

  const handleDeleteFile = async (fileId: number) => {
    if (!window.confirm("Supprimer ce document ?")) return;
    try {
      await api.delete(`/portfolio/files/${fileId}`);
      notifications.show({ title: 'Succès', message: 'Fichier supprimé' });
      fetchStudentData();
    } catch (e: any) {
      const msg = e.response?.status === 403 ? "Ce fichier est verrouillé par un enseignant" : "Échec de la suppression";
      notifications.show({ title: 'Erreur', message: msg, color: 'red' });
    }
  };

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

        <OdooWidget />

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
            <div style={{ display: 'grid', gridTemplateColumns: '1fr', gap: '15px' }}>
              {filteredActivities.map((act: any) => {
                const files = uploadedFiles.filter(f => f.entity_type === 'ACTIVITY' && f.entity_id === act.id.toString());
                return (
                  <Paper key={`upload-${act.id}`} withBorder p="md" radius="md" bg="white">
                    <Stack gap="xs">
                      <Group justify="space-between" wrap="nowrap">
                        <Stack gap={0} style={{ flexGrow: 1, minWidth: 0 }}>
                          <Text size="xs" fw={700} c="blue">{act.code}</Text>
                          <Text size="xs" truncate fw={500}>{act.label}</Text>
                        </Stack>
                        <FileInput 
                          placeholder="Déposer" 
                          size="xs" 
                          variant="filled"
                          leftSection={<IconFileUpload size={14} />} 
                          onChange={(file) => handleUpload(file, 'ACTIVITY', act.id.toString())}
                          disabled={uploading === act.id.toString()}
                          style={{ width: 100 }}
                        />
                      </Group>

                      {files.length > 0 ? (
                        <Stack gap={4} mt="xs">
                          {files.map(file => (
                            <Paper key={file.id} withBorder p={5} bg="gray.0" radius="xs">
                              <Group justify="space-between">
                                <Group gap={5} wrap="nowrap" style={{ flexGrow: 1, minWidth: 0 }}>
                                  {file.is_locked ? <IconLock size={12} color="orange" /> : <IconFileText size={12} color="gray" />}
                                  <Text size="10px" truncate>{file.filename}</Text>
                                </Group>
                                <Group gap={2}>
                                  {!file.is_locked && (
                                    <ActionIcon size="xs" color="red" variant="subtle" onClick={() => handleDeleteFile(file.id)}>
                                      <IconTrash size={12} />
                                    </ActionIcon>
                                  )}
                                </Group>
                              </Group>
                            </Paper>
                          ))}
                        </Stack>
                      ) : (
                        <Text size="10px" c="dimmed" fs="italic" ta="center">Aucun document</Text>
                      )}
                    </Stack>
                  </Paper>
                );
              })}
            </div>
          </Stack>
        </Paper>
      </Stack>
    </Container>
  );
}
