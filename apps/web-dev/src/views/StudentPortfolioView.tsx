import React, { useState, useEffect } from 'react';
import { Container, Paper, Title, Text, Group, Stack, Badge, ThemeIcon, Alert, ActionIcon, Loader, Center, Accordion, FileInput, Button, Select, Menu, Tabs, Textarea } from '@mantine/core';
import { IconInfoCircle, IconFileText, IconBook, IconFolder, IconFileUpload, IconTrash, IconLock, IconPencil, IconPlus, IconPaperclip, IconCloudDownload, IconCompass, IconFileExport, IconDeviceFloppy, IconWorld } from '@tabler/icons-react';
import { notifications } from '@mantine/notifications';
import api from '../services/api';
import { useMediaQuery } from '@mantine/hooks';
import { PortfolioEditor } from '../components/PortfolioEditor';
import { PortfolioExportWizard } from '../components/PortfolioExportWizard';

export function StudentPortfolioView({ user, curriculum, groups, setGlobalTab }: any) {
  const isMobile = useMediaQuery('(max-width: 768px)');
  const [activeTab, setActiveTab] = useState<string | null>('pages');
  const [view, setView] = useState<'dashboard' | 'editor'>('dashboard');
  const [selectedPageId, setSelectedPageId] = useState<number | undefined>();
  const [portfolioPages, setPortfolioPages] = useState<any[]>([]);
  const [uploadedFiles, setUploadedFiles] = useState<any[]>([]);
  const [ppp, setPpp] = useState<any>(null);
  const [loading, setLoading] = useState(true);
  const [uploading, setUploading] = useState<string | null>(null);
  const [savingPpp, setSavingPpp] = useState(false);
  const [academicYear, setAcademicYear] = useState('2025-2026');

  const fetchStudentData = async () => {
    try {
      const [filesRes, pagesRes, pppRes] = await Promise.all([
        api.get('/portfolio/files'),
        api.get('/portfolio/pages'),
        api.get('/portfolio/ppp')
      ]);
      setUploadedFiles(filesRes.data);
      setPortfolioPages(pagesRes.data);
      setPpp(pppRes.data);
    } catch (e) { console.error("Error fetching data", e); }
    setLoading(false);
  };

  useEffect(() => {
    fetchStudentData();
  }, [user.ldap_uid]);

  const handleSavePpp = async () => {
    setSavingPpp(true);
    try {
        await api.patch('/portfolio/ppp', ppp);
        notifications.show({ title: 'Succès', message: 'Votre PPP a été mis à jour', color: 'green' });
    } catch (e) {
        notifications.show({ title: 'Erreur', message: 'Échec de la sauvegarde', color: 'red' });
    }
    setSavingPpp(false);
  };

  const handleUpload = async (file: File | null, entityType: string, entityId: string) => {
    if (!file) return;
    setUploading(entityId);
    const formData = new FormData();
    formData.append('file', file);
    try {
      await api.post(`/portfolio/upload?entity_type=${entityType}&entity_id=${entityId}&academic_year=${academicYear}`, formData);
      notifications.show({ title: 'Succès', message: 'Fichier déposé', color: 'green' });
      fetchStudentData();
    } catch (e) { notifications.show({ title: 'Erreur', color: 'red' }); }
    setUploading(null);
  };

  const handleDeleteFile = async (fileId: number) => {
    if (!window.confirm("Supprimer ce document ?")) return;
    try {
      await api.delete(`/portfolio/files/${fileId}`);
      fetchStudentData();
    } catch (e) { notifications.show({ title: 'Erreur', color: 'red' }); }
  };

  const handleDeletePage = async (id: number) => {
    if (!window.confirm("Supprimer cette page de réflexion ?")) return;
    try {
        await api.delete(`/portfolio/pages/${id}`);
        fetchStudentData();
    } catch (e) { notifications.show({ title: 'Erreur', color: 'red' }); }
  };

  if (view === 'editor') {
    return (
        <Container size="lg" py="xl">
            <PortfolioEditor studentUid={user.ldap_uid} pageId={selectedPageId} onBack={() => { setView('dashboard'); fetchStudentData(); }} />
        </Container>
    );
  }

  if (loading) return <Center h="50vh"><Loader /></Center>;

  const studentGroup = groups?.find((g:any) => Number(g.id) === Number(user?.group_id));
  const filteredActivities = curriculum?.activities?.filter((a: any) => {
    if (!studentGroup) return false;
    return a.level === studentGroup.year && (a.pathway === 'Tronc Commun' || a.pathway === studentGroup.pathway);
  }) || [];

  return (
    <Container size="xl" py={isMobile ? "xs" : "md"}>
        <Stack gap="lg">
            <Paper withBorder p={isMobile ? "sm" : "md"} radius="md" bg="blue.0">
                <Group justify="space-between" wrap={isMobile ? "wrap" : "nowrap"}>
                    <Group gap="xs">
                        {!isMobile && <IconFolder color="#228be6" />}
                        <Title order={isMobile ? 4 : 3}>Mon Portfolio</Title>
                    </Group>
                    <Button 
                        variant="gradient" 
                        gradient={{ from: 'blue', to: 'cyan' }} 
                        leftSection={<IconWorld size={isMobile ? 14 : 18} />}
                        onClick={() => setGlobalTab('live-book')}
                        size={isMobile ? "xs" : "sm"}
                        fullWidth={isMobile}
                    >
                        {isMobile ? "Voir mon Book" : "Aperçu Live de mon Book"}
                    </Button>
                </Group>
            </Paper>

            <Tabs value={activeTab} onChange={setActiveTab} variant="pills" color="blue">
                <Tabs.List grow={isMobile}>
                    <Tabs.Tab value="pages" leftSection={<IconBook size={16} />}>{isMobile ? "Pages" : "Mes Pages"}</Tabs.Tab>
                    <Tabs.Tab value="proofs" leftSection={<IconLock size={16} />}>{isMobile ? "Coffre" : "Coffre-fort SAÉ"}</Tabs.Tab>
                    <Tabs.Tab value="ppp" leftSection={<IconCompass size={16} />}>PPP</Tabs.Tab>
                    <Tabs.Tab value="export" leftSection={<IconFileExport size={16} />} color="orange">{isMobile ? "Exp" : "Exporter"}</Tabs.Tab>
                </Tabs.List>

                <Tabs.Panel value="pages">
                    <Stack mt="xl">
                        <Group justify="space-between" mb="md" wrap={isMobile ? "wrap" : "nowrap"}>
                            <Text size="xs" c="dimmed">Rédigez vos réflexions et liez vos preuves.</Text>
                            <Button size={isMobile ? "xs" : "sm"} leftSection={<IconPlus size={18}/>} onClick={() => { setSelectedPageId(undefined); setView('editor'); }} fullWidth={isMobile}>Nouvelle Page</Button>
                        </Group>

                        {portfolioPages.length === 0 ? (
                            <Alert color="blue" icon={<IconInfoCircle />}>Vous n'avez pas encore de page de réflexion.</Alert>
                        ) : (
                            <Stack gap="md">
                                {portfolioPages.map(page => {
                                    const linkedIds = page.linked_file_ids ? page.linked_file_ids.split(',').filter(Boolean) : [];
                                    return (
                                    <Paper key={page.id} withBorder p="md" radius="md" shadow="xs" className="hover-card">
                                        <Group justify="space-between" wrap="nowrap">
                                            <Group onClick={() => { setSelectedPageId(page.id); setView('editor'); }} style={{ cursor: 'pointer', flexGrow: 1 }} wrap="nowrap">
                                                <ThemeIcon variant="light" size={isMobile ? "md" : "lg"}><IconFileText size={isMobile ? 16 : 20}/></ThemeIcon>
                                                <div style={{ minWidth: 0 }}><Text fw={700} size={isMobile ? "sm" : "md"} truncate>{page.title}</Text><Text size="10px" c="dimmed">{new Date(page.updated_at).toLocaleDateString()}</Text></div>
                                            </Group>
                                            <Group gap={4} wrap="nowrap">
                                                {!isMobile && <Badge variant="light" color="gray" size="xs">{page.academic_year}</Badge>}
                                                {linkedIds.length > 0 && (
                                                    <Menu shadow="md" width={250}>
                                                        <Menu.Target><ActionIcon color="blue" variant="light" size={isMobile ? "md" : "lg"}><IconPaperclip size={18} /></ActionIcon></Menu.Target>
                                                        <Menu.Dropdown>
                                                            <Menu.Label>Preuves liées</Menu.Label>
                                                            {linkedIds.map(fid => {
                                                                const file = uploadedFiles.find(f => f.id.toString() === fid);
                                                                return <Menu.Item key={fid} leftSection={<IconCloudDownload size={14}/>} component="a" href={`/api/portfolio/download/${fid}`} target="_blank">{file ? file.filename : `Fichier #${fid}`}</Menu.Item>
                                                            })}
                                                        </Menu.Dropdown>
                                                    </Menu>
                                                )}
                                                <ActionIcon color="red" variant="subtle" size={isMobile ? "md" : "lg"} onClick={() => handleDeletePage(page.id)}><IconTrash size={18}/></ActionIcon>
                                            </Group>
                                        </Group>
                                    </Paper>
                                    );
                                })}
                            </Stack>
                        )}
                    </Stack>
                </Tabs.Panel>

                <Tabs.Panel value="proofs">
                    <Paper withBorder p={isMobile ? "sm" : "lg"} radius="md" shadow="xs" mt="xl">
                        <Group justify="space-between" mb="md">
                            <Group gap="xs"><IconLock size={20} color="orange" /><Title order={isMobile ? 5 : 4}>Coffre-fort SAÉ</Title></Group>
                            <Select size="xs" data={['2023-2024', '2024-2025', '2025-2026']} value={academicYear} onChange={(v) => setAcademicYear(v || '2025-2026')} w={isMobile ? 100 : 120} />
                        </Group>
                        <Accordion variant="separated">
                            {filteredActivities.sort((a: any, b: any) => a.code.localeCompare(b.code)).map((act: any) => {
                                const files = uploadedFiles.filter(f => f.entity_type === 'ACTIVITY' && f.entity_id === act.id.toString());
                                return (
                                    <Accordion.Item key={act.id} value={act.code}>
                                        <Accordion.Control icon={<Badge color="orange" size="xs">{act.type}</Badge>}>
                                            <Group justify="space-between" pr="md" wrap="nowrap">
                                                <Text size="xs" fw={600} truncate>{act.code} : {act.label}</Text>
                                                <Badge size="10px" variant="light" color={files.length > 0 ? 'green' : 'gray'}>{files.length}</Badge>
                                            </Group>
                                        </Accordion.Control>
                                        <Accordion.Panel>
                                            <Stack gap="md">
                                                <FileInput label="Ajouter une preuve" placeholder="Choisir un fichier" size="xs" leftSection={<IconFileUpload size={14} />} onChange={(file) => handleUpload(file, 'ACTIVITY', act.id.toString())} disabled={uploading === act.id.toString()} />
                                                {files.length > 0 && (
                                                    <Stack gap="xs">
                                                        {files.map(file => (
                                                            <Paper key={file.id} withBorder p="xs" bg="gray.0" radius="xs">
                                                                <Group justify="space-between" wrap="nowrap">
                                                                    <Group gap={5} wrap="nowrap" style={{ flexGrow: 1, minWidth: 0 }}>
                                                                        {file.is_locked ? <IconLock size={12} color="orange" /> : <IconFileText size={12} color="gray" />}
                                                                        <Text size="xs" truncate>{file.filename}</Text>
                                                                    </Group>
                                                                    {!file.is_locked && <ActionIcon size="xs" color="red" variant="subtle" onClick={() => handleDeleteFile(file.id)}><IconTrash size={12} /></ActionIcon>}
                                                                </Group>
                                                            </Paper>
                                                        ))}
                                                    </Stack>
                                                )}
                                            </Stack>
                                        </Accordion.Panel>
                                    </Accordion.Item>
                                );
                            })}
                        </Accordion>
                    </Paper>
                </Tabs.Panel>

                <Tabs.Panel value="ppp">
                    <Stack mt="xl">
                        <Paper withBorder p="xl" radius="md" shadow="sm">
                            <Group mb="md">
                                <IconCompass size={28} color="blue" />
                                <Title order={3}>Mon Projet Personnel et Professionnel (PPP)</Title>
                            </Group>
                            <Text size="sm" c="dimmed" mb="xl">Anticipez la suite : poursuite d'études ou insertion professionnelle.</Text>
                            
                            <Stack gap="md">
                                <Textarea 
                                    label="Mes ambitions et objectifs de carrière"
                                    placeholder="Ex: Master Marketing, Licence Pro, Création d'entreprise..."
                                    minRows={4}
                                    value={ppp?.career_goals || ''}
                                    onChange={(e) => setPpp({...ppp, career_goals: e.target.value})}
                                />
                                
                                <Text size="sm" fw={500}>Réflexion approfondie :</Text>
                                <Alert color="indigo" icon={<IconInfoCircle />}>
                                    Conseil : Décrivez ici les étapes concrètes que vous envisagez pour atteindre vos objectifs (recherche de stage, spécialisation, etc.).
                                </Alert>
                                <Textarea 
                                    placeholder="Votre réflexion ici..."
                                    minRows={10}
                                    value={ppp?.content_json || ''} 
                                    onChange={(e) => setPpp({...ppp, content_json: e.target.value})}
                                />
                                
                                <Button 
                                    leftSection={<IconDeviceFloppy size={18}/>} 
                                    onClick={handleSavePpp} 
                                    loading={savingPpp}
                                    size="md"
                                >
                                    Sauvegarder mon PPP
                                </Button>
                            </Stack>
                        </Paper>
                    </Stack>
                </Tabs.Panel>

                <Tabs.Panel value="export">
                    <Stack mt="xl">
                        <PortfolioExportWizard studentUid={user.ldap_uid} pages={portfolioPages} />
                    </Stack>
                </Tabs.Panel>
            </Tabs>
        </Stack>
    </Container>
  );
}
