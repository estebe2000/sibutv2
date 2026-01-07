import { useState, useEffect } from 'react';
import {
  AppShell,
  Text,
  Group,
  Title,
  Container,
  Grid,
  Paper,
  Stack,
  Button,
  Badge,
  ScrollArea,
  TextInput,
  Select,
  ActionIcon,
  Modal,
  Tabs,
  Card,
  ThemeIcon,
  PasswordInput,
  Center,
  Accordion,
  List,
  Divider,
  Box,
  FileInput,
  Textarea,
  Loader
} from '@mantine/core';
import {
  IconUsers,
  IconSettings,
  IconDatabase,
  IconShieldCheck,
  IconTrash,
  IconGripVertical,
  IconBook,
  IconPencil,
  IconPlus,
  IconCategory,
  IconUpload,
  IconUserPlus,
  IconInfoCircle,
  IconClock,
  IconDownload,
  IconCrown,
  IconUserCircle
} from '@tabler/icons-react';
import { notifications } from '@mantine/notifications';
import { DragDropContext, Droppable, Draggable } from '@hello-pangea/dnd';
import { MultiSelect } from '@mantine/core';
import axios from 'axios';


const API_URL = 'http://localhost:8000';

const YEAR_COLORS: any = {
  0: 'gray',
  1: 'blue',
  2: 'green',
  3: 'grape'
};

function App() {
  // AUTH STATE
  const [token, setToken] = useState<string | null>(localStorage.getItem('token'));
  const [loginUsername, setLoginUsername] = useState('');
  const [loginPassword, setLoginPassword] = useState('');
  const [loginLoading, setLoginLoading] = useState(false);

  // APP STATE
  const [activeTab, setActiveTab] = useState<string | null>('dispatcher');
  const [ldapUsers, setLdapUsers] = useState<any[]>([]);
  const [localGroups, setLocalGroups] = useState<any[]>([]);
  const [assignedUsers, setAssignedUsers] = useState<any[]>([]);
  const [error, setError] = useState<string | null>(null);
  const [systemConfig, setSystemConfig] = useState<any[]>([]);

  // Group Creation State
  const [isGroupModalOpen, setIsGroupModalOpen] = useState(false);
  const [newGroup, setNewGroup] = useState({ name: '', year: 1, pathway: 'Tronc Commun', formation_type: 'FI' });

  // Curriculum State
  const [curriculum, setCurriculum] = useState<any>({ competences: [], activities: [], resources: [] });
  const [loading, setLoading] = useState(false);

  // Axios Interceptor for Auth
  useEffect(() => {
    if (token) {
      axios.defaults.headers.common['Authorization'] = `Bearer ${token}`;
      fetchData();
      fetchCurriculum();
    } else {
      delete axios.defaults.headers.common['Authorization'];
    }
  }, [token]);

  const handleLogin = async () => {
    setLoginLoading(true);
    try {
      const formData = new FormData();
      formData.append('username', loginUsername);
      formData.append('password', loginPassword);
      const res = await axios.post(`${API_URL}/login`, formData);
      setToken(res.data.access_token);
      localStorage.setItem('token', res.data.access_token);
      notifications.show({ title: 'Bienvenue', message: 'Connexion réussie' });
    } catch (e) {
      notifications.show({ color: 'red', title: 'Erreur', message: 'Identifiants incorrects' });
    }
    setLoginLoading(false);
  };

  const handleLogout = () => {
    setToken(null);
    localStorage.removeItem('token');
  };

  const fetchData = async () => {
    try {
      const [ldapRes, groupRes, userRes, configRes] = await Promise.all([
        axios.get(`${API_URL}/ldap-users`),
        axios.get(`${API_URL}/groups`),
        axios.get(`${API_URL}/users`),
        axios.get(`${API_URL}/config`).catch(() => ({ data: [] }))
      ]);
      setLdapUsers(Array.isArray(ldapRes.data) ? ldapRes.data : []);
      setLocalGroups(Array.isArray(groupRes.data) ? groupRes.data : []);
      setAssignedUsers(Array.isArray(userRes.data) ? userRes.data.filter((u: any) => u.group_id !== null) : []);
      setSystemConfig(configRes.data);
    } catch (error: any) {
      if (error.response && error.response.status === 401) handleLogout();
      else setError("Connexion au backend impossible.");
    }
  };

  const handleSaveConfig = async (values: any[]) => {
    try {
      await axios.post(`${API_URL}/config`, values);
      notifications.show({ title: 'Succès', message: 'Configuration enregistrée', color: 'green' });
      fetchData();
    } catch (e) {
      notifications.show({ title: 'Erreur', message: 'Échec de la sauvegarde', color: 'red' });
    }
  };

  const fetchCurriculum = async () => {
    setLoading(true);
    try {
      const [compRes, actRes, resRes] = await Promise.all([
        axios.get(`${API_URL}/competencies`),
        axios.get(`${API_URL}/activities`),
        axios.get(`${API_URL}/resources`)
      ]);
      setCurriculum({
        competences: Array.isArray(compRes.data) ? compRes.data : [], 
        activities: Array.isArray(actRes.data) ? actRes.data : [],
        resources: Array.isArray(resRes.data) ? resRes.data : [] 
      });
    } catch (e) { console.error("Failed to fetch curriculum", e); }
    setLoading(false);
  };

  const handleStudentImport = async (file: File | null) => {
    if (!file) return;
    const formData = new FormData();
    formData.append('file', file);
    try {
      await axios.post(`${API_URL}/import/students`, formData);
      notifications.show({ title: 'Succès', message: 'Étudiants importés et assignés' });
      fetchData();
    } catch (e) { notifications.show({ color: 'red', title: 'Erreur', message: 'Échec de l\'importation' }); }
  };

  const handleCreateGroup = async () => {
    try {
      if ((newGroup as any).id) {
        await axios.patch(`${API_URL}/groups/${(newGroup as any).id}`, newGroup);
        notifications.show({ title: 'Succès', message: 'Groupe mis à jour' });
      } else {
        await axios.post(`${API_URL}/groups`, newGroup);
        notifications.show({ title: 'Succès', message: `Groupe ${newGroup.name} créé` });
      }
      setIsGroupModalOpen(false);
      setNewGroup({ name: '', year: 1, pathway: 'Tronc Commun', formation_type: 'FI' });
      fetchData();
    } catch (e) {
      notifications.show({ color: 'red', title: 'Erreur', message: 'Échec de l\'opération' });
    }
  };

  const deleteGroup = async (id: number) => {
    if (!window.confirm("Supprimer ce groupe et désassigner tous ses étudiants ?")) return;
    try {
      await axios.delete(`${API_URL}/groups/${id}`);
      notifications.show({ title: 'Succès', message: 'Groupe supprimé' });
      fetchData();
    } catch (e) {
      notifications.show({ color: 'red', title: 'Erreur', message: 'Échec de la suppression' });
    }
  };

  const onDragEnd = async (result: any) => {
    const { source, destination, draggableId } = result;
    if (!destination) return;
    const destGroupId = parseInt(destination.droppableId.replace('group-', ''));
    if (isNaN(destGroupId)) return;

    if (source.droppableId === 'ldap-list') {
      const user = ldapUsers.find(u => u.uid === draggableId);
      if (user) {
        setAssignedUsers([...assignedUsers, { ...user, ldap_uid: user.uid, group_id: destGroupId, role: 'STUDENT' }]);
        await axios.post(`${API_URL}/users/assign`, { ldap_uid: user.uid, email: user.email, full_name: user.full_name, role: 'STUDENT', group_id: destGroupId });
      }
    } else if (source.droppableId.startsWith('group-')) {
      const sourceGroupId = parseInt(source.droppableId.replace('group-', ''));
      if (sourceGroupId === destGroupId) return;
      setAssignedUsers(prev => prev.map(u => u.ldap_uid === draggableId ? { ...u, group_id: destGroupId } : u));
      const user = assignedUsers.find(u => u.ldap_uid === draggableId);
      if (user) await axios.post(`${API_URL}/users/assign`, { ldap_uid: user.ldap_uid, email: user.email, full_name: user.full_name, role: user.role, group_id: destGroupId });
    }
  };

  const unassignUser = async (ldapUid: string) => {
    setAssignedUsers(prev => prev.filter(u => u.ldap_uid !== ldapUid));
    try { await axios.post(`${API_URL}/users/unassign?ldap_uid=${ldapUid}`); fetchData(); } catch (e) { fetchData(); }
  };

  const handleSetQuota = async (ldapUid: string) => {
    try {
      await axios.post(`${API_URL}/users/${ldapUid}/quota?quota=100 GB`);
      notifications.show({ title: 'Quota mis à jour', message: 'Espace Nextcloud augmenté à 100 Go', color: 'green' });
    } catch (e) {
      notifications.show({ color: 'red', title: 'Erreur', message: 'Échec de la mise à jour du quota' });
    }
  };

  if (!token) return (
    <Center h="100vh" bg="gray.1">
      <Paper shadow="md" p="xl" radius="md" withBorder w={400}>
        <Stack align="center" mb="md">
          <ThemeIcon size={60} radius="xl" color="blue"><IconShieldCheck size={40} /></ThemeIcon>
          <Title order={3}>Skills Hub Admin</Title>
        </Stack>
        <TextInput label="Identifiant" value={loginUsername} onChange={(e) => setLoginUsername(e.target.value)} mb="sm" />
        <PasswordInput label="Mot de passe" value={loginPassword} onChange={(e) => setLoginPassword(e.target.value)} mb="lg" />
        <Button fullWidth onClick={handleLogin} loading={loginLoading}>Se connecter</Button>
      </Paper>
    </Center>
  );

  return (
    <AppShell header={{ height: 60 }} navbar={{ width: 250, breakpoint: 'sm' }} padding="md">
      <AppShell.Header p="md">
        <Group justify="space-between">
          <Group><IconShieldCheck size={28} color="#228be6" /><Title order={3}>Skills Hub Admin</Title></Group>
          <Button variant="default" size="xs" onClick={handleLogout}>Déconnexion</Button>
        </Group>
      </AppShell.Header>
      <AppShell.Navbar p="md">
        <Stack>
          <Button variant={activeTab === 'dispatcher' ? 'light' : 'subtle'} onClick={() => setActiveTab('dispatcher')} leftSection={<IconUsers size={20} />}>Dispatching</Button>
          <Button variant={activeTab === 'curriculum' ? 'light' : 'subtle'} onClick={() => setActiveTab('curriculum')} leftSection={<IconBook size={20} />} color="grape">Référentiel</Button>
          <Button variant={activeTab === 'settings' ? 'light' : 'subtle'} onClick={() => setActiveTab('settings')} color="gray" leftSection={<IconSettings size={20} />}>Configuration</Button>
        </Stack>
      </AppShell.Navbar>
      <AppShell.Main>
        <DragDropContext onDragEnd={onDragEnd}>
          {activeTab === 'dispatcher' ? (
            <Container size="xl" h="calc(100vh - 100px)">
              <Modal opened={isGroupModalOpen} onClose={() => setIsGroupModalOpen(false)} title="Promotion">
                <Stack>
                  <TextInput label="Nom du groupe" placeholder="ex: TP1, BUT1-A..." value={newGroup.name} onChange={(e) => setNewGroup({...newGroup, name: e.target.value})} required />
                  <Select label="Année" data={['1', '2', '3']} value={newGroup.year.toString()} onChange={(v) => setNewGroup({...newGroup, year: parseInt(v || '1')})} />
                  <Select label="Parcours" data={['Tronc Commun', 'BI', 'BSMRC', 'MDEE', 'MMPV', 'SME']} value={newGroup.pathway} onChange={(v) => setNewGroup({...newGroup, pathway: v || 'Tronc Commun'})} />
                  <Select label="Type" data={[{label: 'Initiale', value: 'FI'}, {label: 'Alternance', value: 'FA'}]} value={newGroup.formation_type} onChange={(v) => setNewGroup({...newGroup, formation_type: v || 'FI'})} />
                  <Button onClick={handleCreateGroup}>Valider</Button>
                </Stack>
              </Modal>

              <Group justify="space-between" mb="md">
                <Title order={4}>Dispatching des Étudiants</Title>
                <Group>
                  <FileInput 
                    placeholder="Importer Étudiants (Excel)" 
                    size="xs" 
                    accept=".xlsx,.csv"
                    leftSection={<IconUpload size={14} />}
                    onChange={handleStudentImport}
                  />
                  <Button size="xs" leftSection={<IconUserPlus size={14} />} variant="outline" onClick={() => {
                    setNewGroup({ name: '', year: 1, pathway: 'Tronc Commun', formation_type: 'FI' });
                    setIsGroupModalOpen(true);
                  }}>Nouveau Groupe</Button>
                </Group>
              </Group>
              <Grid h="calc(100% - 50px)">
                <Grid.Col span={4} h="100%">
                  <Paper withBorder p="md" h="100%" bg="gray.0" style={{ display: 'flex', flexDirection: 'column' }}>
                    <Title order={5} mb="md">LDAP ({ldapUsers.filter(lu => !assignedUsers.find(au => au.ldap_uid === lu.uid)).length})</Title>
                    <Droppable droppableId="ldap-list" isDropDisabled={true}>
                      {(provided) => (
                        <ScrollArea h="100%" ref={provided.innerRef} {...provided.droppableProps}>
                          <Stack gap="xs">
                            {ldapUsers.filter(lu => !assignedUsers.find(au => au.ldap_uid === lu.uid)).map((user, index) => (
                              <Draggable key={user.uid} draggableId={user.uid} index={index}>
                                {(provided) => (
                                  <Paper withBorder p="sm" ref={provided.innerRef} {...provided.draggableProps} {...provided.dragHandleProps} bg="white">
                                    <Group><IconGripVertical size={16} color="gray" /><div><Text size="sm" fw={500}>{user.full_name}</Text><Text size="xs" c="dimmed">{user.email}</Text></div></Group>
                                  </Paper>
                                )}
                              </Draggable>
                            ))}
                            {provided.placeholder}
                          </Stack>
                        </ScrollArea>
                      )}
                    </Droppable>
                  </Paper>
                </Grid.Col>
                <Grid.Col span={8} h="100%">
                  <ScrollArea h="100%">
                    <Grid>{localGroups.map(group => (
                      <Grid.Col key={group.id} span={6}>
                        <Droppable droppableId={`group-${group.id}`}>
                          {(provided, snapshot) => (
                            <Card withBorder ref={provided.innerRef} {...provided.droppableProps} bg={snapshot.isDraggingOver ? 'blue.0' : 'white'} style={{ minHeight: '150px' }}>
                              <Card.Section withBorder inheritPadding py="xs" bg={`${YEAR_COLORS[group.year]}.1`}>
                                <Group justify="space-between">
                                  <Group gap="xs">
                                    <Text fw={700} size="sm">{group.name}</Text>
                                    <Badge color={YEAR_COLORS[group.year]} size="xs">BUT {group.year}</Badge>
                                  </Group>
                                  <Group gap={5}>
                                    {group.name !== "Enseignants" && (
                                      <>
                                        <ActionIcon size="xs" variant="subtle" color="blue" onClick={() => {
                                          setNewGroup(group);
                                          setIsGroupModalOpen(true);
                                        }}>
                                          <IconPencil size={12} />
                                        </ActionIcon>
                                        <ActionIcon size="xs" variant="subtle" color="red" onClick={() => deleteGroup(group.id)}>
                                          <IconTrash size={12} />
                                        </ActionIcon>
                                      </>
                                    )}
                                  </Group>
                                </Group>
                              </Card.Section>
                              <Stack gap={4} mt="xs">
                                {assignedUsers.filter(u => u.group_id === group.id).map((u, index) => (
                                  <Draggable key={u.ldap_uid} draggableId={u.ldap_uid} index={index}>
                                    {(provided) => (
                                      <Paper withBorder p="xs" ref={provided.innerRef} {...provided.draggableProps} {...provided.dragHandleProps} bg="white">
                                        <Group justify="space-between">
                                          <Text size="xs">{u.full_name}</Text>
                                          <Group gap={4}>
                                            {group.name === "Enseignants" && (
                                              <ActionIcon size="xs" color="blue" variant="light" onClick={() => handleSetQuota(u.ldap_uid)} title="Augmenter Quota (100 Go)">
                                                <IconDatabase size={12} />
                                              </ActionIcon>
                                            )}
                                            <ActionIcon size="xs" color="red" variant="subtle" onClick={() => unassignUser(u.ldap_uid)}><IconTrash size={12} /></ActionIcon>
                                          </Group>
                                        </Group>
                                      </Paper>
                                    )}
                                  </Draggable>
                                ))}
                                {provided.placeholder}
                              </Stack>
                            </Card>
                          )}
                        </Droppable>
                      </Grid.Col>
                    ))}</Grid>
                  </ScrollArea>
                </Grid.Col>
              </Grid>
            </Container>
          ) : activeTab === 'curriculum' ? (
            <CompetencyEditor curriculum={curriculum} onRefresh={fetchCurriculum} />
          ) : <SettingsView config={systemConfig} onSave={handleSaveConfig} />}
        </DragDropContext>
      </AppShell.Main>
    </AppShell>
  );
}

function ResponsibilitySelector({ entity, type, professors, onRefresh }: any) {
    if (!professors) return null;
    const profOptions = professors.map((p: any) => ({ value: p.id.toString(), label: p.full_name || 'Sans nom' }));
    
    const handleSetOwner = async (val: string | null) => {
        try {
            await axios.post(`${API_URL}/curriculum/assign-role?entity_type=${type}&entity_id=${entity.id}&user_id=${val}&role_type=owner`);
            notifications.show({ title: 'Succès', message: 'Responsable assigné' });
            onRefresh();
        } catch (e) { notifications.show({ color: 'red', title: 'Erreur', message: 'Échec assignation' }); }
    };

    const handleSetIntervenants = async (values: string[]) => {
        const currentIds = entity?.intervenants?.map((u: any) => u.id.toString()) || [];
        const added = values.filter(v => !currentIds.includes(v));
        const removed = currentIds.filter(v => !values.includes(v));

        try {
            for (const id of added) {
                await axios.post(`${API_URL}/curriculum/assign-role?entity_type=${type}&entity_id=${entity.id}&user_id=${id}&role_type=intervenant`);
            }
            for (const id of removed) {
                await axios.post(`${API_URL}/curriculum/unassign-role?entity_type=${type}&entity_id=${entity.id}&user_id=${id}&role_type=intervenant`);
            }
            if (added.length > 0 || removed.length > 0) onRefresh();
        } catch (e) { notifications.show({ color: 'red', title: 'Erreur', message: 'Échec mise à jour intervenants' }); }
    };

    return (
        <Stack gap="xs" mt="md">
            <Divider label="Gouvernance" labelPosition="center" />
            <Select 
                label="Responsable Principal" 
                placeholder="Choisir un responsable" 
                data={profOptions} 
                value={entity?.owner_id?.toString() || null}
                onChange={handleSetOwner}
                searchable
                leftSection={<IconCrown size={16} color="gold" />}
            />
            <MultiSelect 
                label="Intervenants" 
                placeholder="Ajouter des intervenants" 
                data={profOptions} 
                value={entity?.intervenants?.map((u: any) => u.id.toString()) || []}
                onChange={handleSetIntervenants}
                searchable
                leftSection={<IconUserCircle size={16} />}
            />
        </Stack>
    );
}

function CompetencyEditor({ curriculum, onRefresh, professors }: any) {
  const [pathway, setPathway] = useState('Tronc Commun');
  const [editingComp, setEditingComp] = useState<any>(null);
  const [editingAct, setEditingAct] = useState<any>(null);
  
  const [infoItem, setInfoItem] = useState<any>(null);
  const [infoLoading, setInfoLoading] = useState(false);

  const pathways = ['TOUS', 'Tronc Commun', 'BI', 'BSMRC', 'MDEE', 'MMPV', 'SME'];
  const levels = [1, 2, 3];

  const handleSaveComp = async () => {
    try {
        await axios.patch(`${API_URL}/competencies/${editingComp.id}`, editingComp);
        notifications.show({ title: 'Succès', message: 'Compétence mise à jour' });
        setEditingComp(null);
        onRefresh();
    } catch (e) { notifications.show({ color: 'red', title: 'Erreur', message: 'Échec de la sauvegarde' }); }
  };

  const handleSaveAct = async () => {
    try {
        await axios.patch(`${API_URL}/activities/${editingAct.id}`, editingAct);
        notifications.show({ title: 'Succès', message: 'Activité mise à jour' });
        setEditingAct(null);
        onRefresh();
    } catch (e) { notifications.show({ color: 'red', title: 'Erreur', message: 'Échec de la sauvegarde' }); }
  };

  const handleExport = async () => {
    try {
        const res = await axios.get(`${API_URL}/export/curriculum`);
        const dataStr = "data:text/json;charset=utf-8," + encodeURIComponent(JSON.stringify(res.data, null, 2));
        const downloadAnchorNode = document.createElement('a');
        downloadAnchorNode.setAttribute("href",     dataStr);
        downloadAnchorNode.setAttribute("download", `referentiel_tc_${new Date().toISOString().split('T')[0]}.json`);
        document.body.appendChild(downloadAnchorNode);
        downloadAnchorNode.click();
        downloadAnchorNode.remove();
        notifications.show({ title: 'Export réussi', message: 'Le fichier de sauvegarde a été téléchargé' });
    } catch (e) { notifications.show({ color: 'red', title: 'Erreur', message: 'Échec de l\'export' }); }
  };

  const showInfo = async (item: any, type: 'RES' | 'AC') => {
    setInfoLoading(true);
    setInfoItem({ ...item, type });
    try {
        if (type === 'RES') {
            const res = await axios.get(`${API_URL}/resources/${item.code.trim()}`);
            setInfoItem({ ...res.data, type });
        }
    } catch (e) {
        setInfoItem({ ...item, type, error: 'Détails non trouvés' });
    }
    setInfoLoading(false);
  };

  if (!curriculum || !curriculum.competences) return <Center p="xl"><Loader /></Center>;

  return (
    <Container size="lg">
      {/* INFO MODAL */}
      <Modal opened={!!infoItem} onClose={() => setInfoItem(null)} title={infoItem?.code || "Infos"} size="md">
        {infoLoading ? <Center p="xl"><Loader /></Center> : (
            <Stack>
                <Title order={4}>{infoItem?.label || infoItem?.code}</Title>
                <Divider />
                {infoItem?.error ? <Text color="red">{infoItem.error}</Text> : (
                    <>
                        <Text size="sm" fw={700}>Descriptif :</Text>
                        <Text size="sm">{infoItem?.description || "Aucun descriptif"}</Text>
                        
                        {infoItem?.content && (
                            <>
                                <Text size="sm" fw={700} mt="md">Contenu :</Text>
                                <Text size="sm" style={{ whiteSpace: 'pre-wrap' }}>{infoItem.content}</Text>
                            </>
                        )}

                        {infoItem?.hours > 0 && (
                            <Group mt="md">
                                <IconClock size={16} color="gray" />
                                <Text size="sm">{infoItem.hours} heures (National)</Text>
                            </Group>
                        )}

                        {infoItem?.learning_outcomes?.length > 0 && (
                            <>
                                <Text size="sm" fw={700} mt="md">Apprentissages Critiques liés :</Text>
                                <Group gap={5}>
                                    {infoItem.learning_outcomes.map((lo: any) => (
                                        <Badge key={lo.id} size="xs" variant="outline">{lo.code}</Badge>
                                    ))}
                                </Group>
                            </>
                        )}
                    </>
                )}
            </Stack>
        )}
      </Modal>

      {/* COMP EDITOR MODAL */}
      <Modal opened={!!editingComp} onClose={() => setEditingComp(null)} title="Édition Compétence" size="lg">
        {editingComp && (
            <Stack>
                <Group grow>
                    <TextInput label="Code" value={editingComp.code} disabled />
                    <TextInput label="Parcours" value={editingComp.pathway} disabled />
                </Group>
                <TextInput label="Libellé" value={editingComp.label} onChange={(e) => setEditingComp({...editingComp, label: e.target.value})} />
                <Textarea label="Description" value={editingComp.description || ''} onChange={(e) => setEditingComp({...editingComp, description: e.target.value})} autosize minRows={3} />
                <Button onClick={handleSaveComp}>Sauvegarder</Button>
            </Stack>
        )}
      </Modal>

      {/* ACTIVITY EDITOR MODAL */}
      <Modal opened={!!editingAct} onClose={() => setEditingAct(null)} title="Édition Activité" size="lg">
        {editingAct && (
            <Stack>
                <Group grow>
                    <TextInput label="Code" value={editingAct.code} disabled />
                    <TextInput label="Type" value={editingAct.type} disabled />
                </Group>
                <TextInput label="Libellé" value={editingAct.label} onChange={(e) => setEditingAct({...editingAct, label: e.target.value})} />
                <Textarea label="Description (Objectifs)" value={editingAct.description || ''} onChange={(e) => setEditingAct({...editingAct, description: e.target.value})} autosize minRows={4} />
                <TextInput label="Ressources" value={editingAct.resources || ''} onChange={(e) => setEditingAct({...editingAct, resources: e.target.value})} placeholder="R1.01, R1.02..." />
                <Button onClick={handleSaveAct} mt="md">Sauvegarder</Button>
            </Stack>
        )}
      </Modal>

      <Group justify="space-between" mb="xl">
        <Title order={2}>Gestion du Référentiel</Title>
        <Group>
          <Button variant="light" color="blue" leftSection={<IconDownload size={16} />} onClick={handleExport} size="sm">Exporter (Sauvegarde)</Button>
          <Select 
            placeholder="Parcours" 
            data={pathways} 
            value={pathway} 
            onChange={(v) => setPathway(v || 'Tronc Commun')} 
            size="sm"
          />
          <Button variant="outline" onClick={onRefresh} size="sm">Actualiser</Button>
        </Group>
      </Group>

      {levels.map(lvl => {
        const currPathway = lvl === 1 ? 'Tronc Commun' : pathway;
        
        const comps = curriculum.competences?.filter((c: any) => {
            if (c.level !== lvl) return false;
            if (pathway === 'TOUS') return true;
            return c.pathway === currPathway || c.pathway === 'Tronc Commun';
        }) || [];

        const acts = curriculum.activities?.filter((a: any) => {
            if (a.level !== lvl) return false;
            if (pathway === 'TOUS') return true;
            return a.pathway === currPathway || a.pathway === 'Tronc Commun';
        }) || [];

        if (comps.length === 0 && acts.length === 0) return null;

        return (
          <Paper key={lvl} withBorder p="md" mb="xl" shadow="sm">
            <Group justify="space-between" mb="md">
              <Title order={3} c="blue">BUT {lvl}</Title>
              <Badge size="lg" variant="light">{pathway === 'TOUS' ? 'Tous Parcours' : currPathway}</Badge>
            </Group>

            <Tabs defaultValue="comps">
              <Tabs.List mb="md">
                <Tabs.Tab value="comps" leftSection={<IconCategory size={16} />}>Compétences ({comps.length})</Tabs.Tab>
                <Tabs.Tab value="acts" leftSection={<IconDatabase size={16} />} color="orange">Activités ({acts.length})</Tabs.Tab>
              </Tabs.List>

              <Tabs.Panel value="comps">
                <Accordion variant="separated">
                  {comps.map((c: any) => (
                    <Accordion.Item key={c.id} value={c.code + c.id}>
                      <Accordion.Control>
                        <Group justify="space-between">
                          <Group><Badge color="blue">{c.code}</Badge><Text fw={600}>{c.label}</Text></Group>
                          <Group gap="xs">
                             <Badge size="xs" color="gray" variant="outline">{c.pathway}</Badge>
                             <ActionIcon size="xs" variant="subtle" onClick={(e) => { e.stopPropagation(); setEditingComp(c); }}><IconPencil size={12} /></ActionIcon>
                          </Group>
                        </Group>
                      </Accordion.Control>
                      <Accordion.Panel>
                        {c.description && (
                            <Box mb="md">
                                <Text size="xs" fw={700} c="blue" mb={4}>CONTEXTE PROFESSIONNEL</Text>
                                <Text size="sm" style={{ whiteSpace: 'pre-wrap' }}>{c.description}</Text>
                                <Divider my="md" />
                            </Box>
                        )}
                        <Grid>
                          <Grid.Col span={6}>
                            <Title order={6} mb="xs" c="dimmed">COMPOSANTES ESSENTIELLES (CE)</Title>
                            <List size="xs" spacing="xs" withPadding>
                                {c.essential_components?.map((ce: any) => (
                                    <List.Item key={ce.id}><b>{ce.code}</b> : {ce.label}</List.Item>
                                ))}
                                {(!c.essential_components || c.essential_components.length === 0) && <Text size="xs" c="dimmed" fs="italic">Aucune CE</Text>}
                            </List>
                          </Grid.Col>
                          <Grid.Col span={6}>
                            <Title order={6} mb="xs" c="dimmed">APPRENTISSAGES CRITIQUES (AC)</Title>
                            <List size="xs" spacing="xs" withPadding>
                                {c.learning_outcomes?.map((lo: any) => (
                                    <List.Item key={lo.id}>
                                        <Group gap={5}>
                                            <Text size="xs"><b>{lo.code}</b> : {lo.label}</Text>
                                            <ActionIcon size="xs" variant="transparent" onClick={() => setInfoItem({...lo, type: 'AC'})}><IconInfoCircle size={12} /></ActionIcon>
                                        </Group>
                                    </List.Item>
                                ))}
                                {(!c.learning_outcomes || c.learning_outcomes.length === 0) && <Text size="xs" c="dimmed" fs="italic">Aucune AC</Text>}
                            </List>
                          </Grid.Col>
                        </Grid>
                      </Accordion.Panel>
                    </Accordion.Item>
                  ))}
                </Accordion>
              </Tabs.Panel>

              <Tabs.Panel value="acts">
                <Grid>
                  {acts.map((a: any) => (
                    <Grid.Col key={a.id} span={6}>
                      <Card withBorder padding="sm">
                        <Group justify="space-between" mb="xs">
                          <Badge color={a.type === 'SAE' ? 'orange' : a.type === 'STAGE' ? 'teal' : (a.type === 'PORTFOLIO' ? 'cyan' : 'grape')}>{a.type}</Badge>
                          <Text fw={700} size="sm">{a.code}</Text>
                          <ActionIcon size="xs" variant="subtle" onClick={() => setEditingAct(a)}><IconPencil size={12} /></ActionIcon>
                        </Group>
                        <Text size="sm" mb="xs" fw={500}>{a.label}</Text>
                        {a.description && (
                            <Text size="xs" c="dimmed" mb="xs" style={{ lineHeight: 1.4 }}>
                                {a.description}
                            </Text>
                        )}
                        <Divider my="xs" />
                        <Stack gap={8}>
                            <div>
                                <Text size="xs" fw={700} c="dimmed" mb={4}>COMPÉTENCES MOBILISÉES (AC)</Text>
                                <Stack gap={4}>
                                    {a.learning_outcomes?.map((lo: any) => (
                                        <Group key={lo.id} justify="space-between" wrap="nowrap">
                                            <Text size="xs" truncate style={{ flex: 1 }}>{lo.label}</Text>
                                            <Badge 
                                                size="xs" 
                                                variant="light" 
                                                color="blue" 
                                                style={{ cursor: 'pointer' }} 
                                                className="hover-badge"
                                                onClick={() => setInfoItem({...lo, type: 'AC'})}
                                            >
                                                {lo.code}
                                            </Badge>
                                        </Group>
                                    ))}
                                    {(!a.learning_outcomes || a.learning_outcomes.length === 0) && <Text size="xs" c="dimmed" fs="italic">Aucun lien AC</Text>}
                                </Stack>
                            </div>
                            {a.resources && (
                                <div>
                                    <Text size="xs" fw={700} c="orange" mb={4}>RESSOURCES MOBILISÉES</Text>
                                    <Stack gap={4}>
                                        {a.resources.split(',').map((rCode: string) => {
                                            const code = rCode.trim();
                                            const resInfo = curriculum.resources?.find((r: any) => r.code === code);
                                            return (
                                                <Group key={code} justify="space-between" wrap="nowrap">
                                                    <Text size="xs" truncate style={{ flex: 1 }}>{resInfo?.label || 'Ressource'}</Text>
                                                    <Badge 
                                                        size="xs" 
                                                        variant="light" 
                                                        color="orange" 
                                                        style={{ cursor: 'pointer' }} 
                                                        className="hover-badge"
                                                        onClick={() => showInfo(resInfo || {code}, 'RES')}
                                                    >
                                                        {code}
                                                    </Badge>
                                                </Group>
                                            );
                                        })}
                                    </Stack>
                                </div>
                            )}
                        </Stack>
                        
                        <Divider my="xs" variant="dotted" />
                        <Group justify="space-between" align="center">
                            <Group gap={4}>
                                {a.owner_id && (
                                    <Badge size="xs" color="yellow" variant="filled" leftSection={<IconCrown size={10} />}>
                                        {professors?.find((p: any) => p.id === a.owner_id)?.full_name?.split(' ').map((n: string) => n[0]).join('') || '?'}
                                    </Badge>
                                )}
                                {a.intervenants?.length > 0 && (
                                    <Badge size="xs" color="gray" variant="light" leftSection={<IconUsers size={10} />}>
                                        {a.intervenants.length}
                                    </Badge>
                                )}
                            </Group>
                            <Text size="xs" c="dimmed">Gouvernance</Text>
                        </Group>
                      </Card>
                    </Grid.Col>
                  ))}
                </Grid>
              </Tabs.Panel>
            </Tabs>
          </Paper>
        );
      })}
    </Container>
  );
}

function SettingsView({ config, onSave }: any) {
  const [localConfig, setLocalConfig] = useState<any[]>([]);

  useEffect(() => {
    // Default structure if empty
    const defaults = [
      { key: 'ldap_url', value: 'ldap://ldap:389', category: 'ldap' },
      { key: 'ldap_base_dn', value: 'dc=univ,dc=fr', category: 'ldap' },
      { key: 'smtp_host', value: 'mail', category: 'mail' },
      { key: 'smtp_port', value: '1025', category: 'mail' },
      { key: 'mistral_api_key', value: '', category: 'ai' }
    ];
    
    const merged = defaults.map(d => {
      const existing = config.find((c: any) => c.key === d.key);
      return existing || d;
    });
    setLocalConfig(merged);
  }, [config]);

  const updateVal = (key: string, val: string) => {
    setLocalConfig(prev => prev.map(c => c.key === key ? { ...c, value: val } : c));
  };

  const categories = [
    { id: 'ldap', label: 'Serveur LDAP', icon: <IconUsers size={16} /> },
    { id: 'mail', label: 'Serveur Mail (SMTP)', icon: <IconUsers size={16} /> },
    { id: 'ai', label: 'IA (Codestral)', icon: <IconDatabase size={16} /> }
  ];

  return (
    <Container size="md">
      <Title order={2} mb="xl">Configuration du Système</Title>
      <Paper withBorder p="md">
        <Tabs defaultValue="ldap">
          <Tabs.List mb="md">
            {categories.map(cat => (
              <Tabs.Tab key={cat.id} value={cat.id} leftSection={cat.icon}>{cat.label}</Tabs.Tab>
            ))}
          </Tabs.List>

          {categories.map(cat => (
            <Tabs.Panel key={cat.id} value={cat.id}>
              <Stack>
                {localConfig.filter(c => c.category === cat.id).map(item => (
                  <TextInput 
                    key={item.key} 
                    label={item.key.replace(/_/g, ' ').toUpperCase()} 
                    value={item.value} 
                    onChange={(e) => updateVal(item.key, e.target.value)}
                  />
                ))}
              </Stack>
            </Tabs.Panel>
          ))}
        </Tabs>
        <Button mt="xl" onClick={() => onSave(localConfig)}>Enregistrer la configuration</Button>
      </Paper>
    </Container>
  );
}

export default App;
