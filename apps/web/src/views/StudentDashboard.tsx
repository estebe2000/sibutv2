import React, { useState, useEffect } from 'react';
import { Container, Paper, Title, Text, Group, Stack, Badge, ThemeIcon, Alert, ActionIcon, Loader, Center, Divider, Accordion, FileInput, Button, Select, Menu } from '@mantine/core';
import { IconUser, IconSchool, IconInfoCircle, IconTimeline, IconFileText, IconDownload, IconBook, IconFolder, IconFileUpload, IconBriefcase, IconTrash, IconLock, IconPencil, IconPlus, IconHistory, IconPaperclip, IconCloudDownload } from '@tabler/icons-react';
import { notifications } from '@mantine/notifications';
import api from '../services/api';
import OdooWidget from '../components/OdooWidget';
import { useMediaQuery } from '@mantine/hooks';
import { InternshipForm } from '../components/InternshipForm';
import { InternshipSelfEvaluation } from '../components/InternshipSelfEvaluation';
import { PortfolioEditor } from '../components/PortfolioEditor';

export function StudentDashboard({ user, curriculum, groups }: any) {
  const isMobile = useMediaQuery('(max-width: 768px)');
  const [tutor, setTutor] = useState<any>(null);
  const [internship, setInternship] = useState<any>(null);
  const [view, setView] = useState<'dashboard' | 'editor'>('dashboard');
  const [selectedPageId, setSelectedPageId] = useState<number | undefined>();
  const [portfolioPages, setPortfolioPages] = useState<any[]>([]);
  const [fiches, setFiches] = useState<any[]>([]);
  const [uploadedFiles, setUploadedFiles] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [uploading, setUploading] = useState<string | null>(null);
  const [academicYear, setAcademicYear] = useState('2025-2026');

  const fetchStudentData = async () => {
    try {
      const [tutorRes, internRes, fichesRes, filesRes, pagesRes] = await Promise.all([
        api.get(`/activity-management/student/${user.ldap_uid}/tutor`),
        api.get(`/internships/${user.ldap_uid}`),
        api.get('/fiches/list'),
        api.get('/portfolio/files'),
        api.get('/portfolio/pages')
      ]);
      setTutor(tutorRes.data);
      setInternship(internRes.data);
      setFiches(fichesRes.data);
      setUploadedFiles(filesRes.data);
      setPortfolioPages(pagesRes.data);
    } catch (e) { console.error("Error fetching data", e); }
    setLoading(false);
  };

  useEffect(() => {
    fetchStudentData();
  }, [user.ldap_uid]);

  const handleUpload = async (file: File | null, entityType: string, entityId: string) => {
    if (!file) return;
    setUploading(entityId);
    const formData = new FormData();
    formData.append('file', file);
    try {
      await api.post(`/portfolio/upload?entity_type=${entityType}&entity_id=${entityId}&academic_year=${academicYear}`, formData);
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

  const handleDeletePage = async (id: number) => {
    if (!window.confirm("Supprimer cette page de réflexion ?")) return;
    try {
        await api.delete(`/portfolio/pages/${id}`);
        fetchStudentData();
    } catch (e) { notifications.show({ title: 'Erreur', color: 'red' }); }
  };

  const getLinkedFileIds = (contentJson: string) => {
    // Regex plus robuste acceptant les éventuels backslashes d'échappement du JSON
    const regex = /\/api\/portfolio\/download\\?\/(\d+)/g;
    const ids: string[] = [];
    let match;
    while ((match = regex.exec(contentJson)) !== null) {
        if (!ids.includes(match[1])) ids.push(match[1]);
    }
    return ids;
  };

  if (view === 'editor') {
    return (
        <Container size="lg" py="xl">
            <PortfolioEditor studentUid={user.ldap_uid} pageId={selectedPageId} onBack={() => { setView('dashboard'); fetchStudentData(); }} />
        </Container>
    );
  }

  if (!curriculum || !curriculum.activities || !groups || loading) {
    return <Center h="50vh"><Loader size="lg" /></Center>;
  }

  const studentGroup = groups?.find((g:any) => Number(g.id) === Number(user?.group_id));
  const filteredActivities = curriculum.activities.filter((a: any) => {
    if (!studentGroup) return false;
    return a.level === studentGroup.year && (a.pathway === 'Tronc Commun' || a.pathway === studentGroup.pathway);
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

        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr 1fr', gap: '20px' }}>
          <Paper withBorder p="lg" radius="md" shadow="xs">
            <Group mb="md"><IconSchool color="blue" /><Title order={4}>Ma Scolarité</Title></Group>
            {studentGroup ? (
              <Stack gap="xs">
                <Group justify="space-between"><Text size="sm">Groupe :</Text><Badge size="lg">{studentGroup.name}</Badge></Group>
                <Group justify="space-between"><Text size="sm">Année :</Text><Badge variant="outline">BUT {studentGroup.year}</Badge></Group>
              </Stack>
            ) : <Text size="sm" c="orange" fs="italic">Non assigné.</Text>}
          </Paper>

          <Paper withBorder p="lg" radius="md" shadow="xs" bg="blue.0">
            <Group mb="md"><IconBriefcase color="blue" /><Title order={4}>Mon Tutorat</Title></Group>
            <Stack gap="xs">
                <Text size="xs" c="dimmed" fw={700}>TUTEUR DE STAGE</Text>
                {tutor ? (
                    <div><Text fw={600} size="sm">{tutor.full_name}</Text><Text size="xs" c="blue">{tutor.email}</Text></div>
                ) : <Text size="xs" c="dimmed" fs="italic">Non assigné</Text>}
            </Stack>
          </Paper>

          <Paper withBorder p="lg" radius="md" shadow="xs">
            <Group mb="md"><IconTimeline color="indigo" /><Title order={4}>Mon Profil</Title></Group>
            <Stack gap="xs">
              <Group justify="space-between"><Text size="sm">ID :</Text><Text size="sm">{user?.ldap_uid}</Text></Group>
              <Group justify="space-between"><Text size="sm">Email :</Text><Text size="sm" truncate>{user?.email || 'N/A'}</Text></Group>
            </Stack>
          </Paper>
        </div>

        {!isMobile && <OdooWidget />}
        {internship && !internship.is_finalized && <InternshipForm studentUid={user.ldap_uid} />}
        <InternshipSelfEvaluation studentUid={user.ldap_uid} />

        {/* SECTION PORTFOLIO & RÉFLEXION */}
        <Paper withBorder p="lg" radius="md" shadow="md">
            <Group justify="space-between" mb="xl">
                <Group>
                    <IconFolder size={28} color="var(--mantine-color-blue-6)" />
                    <div>
                        <Title order={3}>Mon Portfolio de Compétences</Title>
                        <Text size="sm" c="dimmed">Rédigez vos réflexions et liez vos preuves d\'apprentissage.</Text>
                    </div>
                </Group>
                <Button leftSection={<IconPlus size={18}/>} onClick={() => { setSelectedPageId(undefined); setView('editor'); }}>
                    Nouvelle Page
                </Button>
            </Group>

            {portfolioPages.length === 0 ? (
                <Alert color="blue" icon={<IconInfoCircle />}>
                    Vous n\'avez pas encore créé de page de réflexion. Commencez par en créer une pour illustrer vos compétences.
                </Alert>
            ) : (
                <Stack gap="md">
                    {portfolioPages.map(page => {
                        const linkedFileIds = getLinkedFileIds(page.content_json);
                        return (
                        <Paper key={page.id} withBorder p="md" radius="md" shadow="xs" className="hover-card">
                            <Group justify="space-between">
                                <Group onClick={() => { setSelectedPageId(page.id); setView('editor'); }} style={{ cursor: 'pointer', flexGrow: 1 }}>
                                    <ThemeIcon variant="light" size="lg"><IconFileText size={20}/></ThemeIcon>
                                    <div>
                                        <Text fw={700}>{page.title}</Text>
                                        <Text size="xs" c="dimmed">Dernière modification : {new Date(page.updated_at).toLocaleDateString()}</Text>
                                    </div>
                                </Group>
                                <Group>
                                    <Badge variant="light" color="gray">{page.academic_year}</Badge>
                                    
                                    {linkedFileIds.length > 0 && (
                                        <Menu shadow="md" width={250}>
                                            <Menu.Target>
                                                <ActionIcon color="blue" variant="light" size="lg" title={`${linkedFileIds.length} preuve(s) liée(s)`}>
                                                    <IconPaperclip size={18} />
                                                </ActionIcon>
                                            </Menu.Target>
                                            <Menu.Dropdown>
                                                <Menu.Label>Preuves de cette page</Menu.Label>
                                                {linkedFileIds.map(fid => {
                                                    const file = uploadedFiles.find(f => f.id.toString() === fid);
                                                    return (
                                                        <Menu.Item 
                                                            key={fid} 
                                                            leftSection={<IconCloudDownload size={14}/>}
                                                            component="a"
                                                            href={`/api/portfolio/download/${fid}`}
                                                            target="_blank"
                                                        >
                                                            {file ? file.filename : `Fichier #${fid}`}
                                                        </Menu.Item>
                                                    );
                                                })}
                                            </Menu.Dropdown>
                                        </Menu>
                                    )}

                                    <ActionIcon color="red" variant="subtle" onClick={() => handleDeletePage(page.id)}><IconTrash size={18}/></ActionIcon>
                                </Group>
                            </Group>
                        </Paper>
                        );
                    })}
                </Stack>
            )}
        </Paper>

        {/* COFFRE-FORT NUMÉRIQUE (PREUVES) */}
        <Paper withBorder p="lg" radius="md" shadow="xs">
            <Group justify="space-between" mb="md">
                <Group>
                    <IconLock size={24} color="orange" />
                    <Title order={4}>Coffre-fort des Preuves (SAÉ)</Title>
                </Group>
                <Select 
                    size="xs" 
                    data={['2023-2024', '2024-2025', '2025-2026']}
                    value={academicYear} 
                    onChange={(v) => setAcademicYear(v || '2025-2026')} 
                    w={120} 
                />
            </Group>
            <Text size="xs" c="dimmed" mb="xl">Déposez ici les documents attestant de vos réalisations pour chaque activité.</Text>

            <Accordion variant="separated">
                {filteredActivities.sort((a: any, b: any) => a.code.localeCompare(b.code)).map((act: any) => {
                    const files = uploadedFiles.filter(f => f.entity_type === 'ACTIVITY' && f.entity_id === act.id.toString());
                    return (
                        <Accordion.Item key={act.id} value={act.code}>
                            <Accordion.Control icon={<Badge color="orange" size="xs">{act.type}</Badge>}>
                                <Group justify="space-between" pr="md">
                                    <Text size="sm" fw={600}>{act.code} : {act.label}</Text>
                                    <Badge size="xs" variant="light" color={files.length > 0 ? 'green' : 'gray'}>
                                        {files.length} preuve(s)
                                    </Badge>
                                </Group>
                            </Accordion.Control>
                            <Accordion.Panel>
                                <Stack gap="md">
                                    <FileInput 
                                        label="Ajouter une preuve"
                                        placeholder="Choisir un fichier" 
                                        size="xs" 
                                        leftSection={<IconFileUpload size={14} />} 
                                        onChange={(file) => handleUpload(file, 'ACTIVITY', act.id.toString())}
                                        disabled={uploading === act.id.toString()}
                                    />
                                    {files.length > 0 ? (
                                        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(200px, 1fr))', gap: '10px' }}>
                                            {files.map(file => (
                                                <Paper key={file.id} withBorder p="xs" bg="gray.0" radius="xs">
                                                    <Group justify="space-between">
                                                        <Group gap={5} wrap="nowrap" style={{ flexGrow: 1, minWidth: 0 }}>
                                                            {file.is_locked ? <IconLock size={12} color="orange" /> : <IconFileText size={12} color="gray" />}
                                                            <Text size="xs" truncate>{file.filename}</Text>
                                                        </Group>
                                                        {!file.is_locked && (
                                                            <ActionIcon size="xs" color="red" variant="subtle" onClick={() => handleDeleteFile(file.id)}>
                                                                <IconTrash size={12} />
                                                            </ActionIcon>
                                                        )}
                                                    </Group>
                                                </Paper>
                                            ))}
                                        </div>
                                    ) : <Text size="xs" c="dimmed" fs="italic" ta="center">Aucun document déposé.</Text>}
                                </Stack>
                            </Accordion.Panel>
                        </Accordion.Item>
                    );
                })}
            </Accordion>
        </Paper>
      </Stack>
    </Container>
  );
}
