import React, { useState, useEffect } from 'react';
import {
  AppShell,
  Text,
  Group,
  Title,
  Paper,
  Stack,
  Button,
  Badge,
  ScrollArea,
  TextInput,
  Select,
  ActionIcon,
  Modal,
  Card,
  ThemeIcon,
  PasswordInput,
  Center,
  Grid,
  FileInput,
  Container,
  Accordion
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
  IconUpload,
  IconUserPlus,
  IconFileText,
  IconCategory
} from '@tabler/icons-react';
import { notifications } from '@mantine/notifications';
import { DragDropContext, Droppable, Draggable } from '@hello-pangea/dnd';
import axios from 'axios';
import { useStore } from './store/useStore';
import { CompetencyEditor } from './views/CompetencyEditor';
import { DiscoveryView } from './views/DiscoveryView';
import { RepartitionView } from './views/RepartitionView';
import { FichesView } from './views/FichesView';
import { FichesPDF2View } from './views/FichesPDF2View';
import { SettingsView } from './views/SettingsView';

// Use relative URL for API to go through Nginx Gateway
const API_URL = '/api';

const YEAR_COLORS: any = {
  0: 'gray',
  1: 'blue',
  2: 'green',
  3: 'grape'
};

function App() {
  console.log("Skills Hub Admin v1.1.0 - Import Modal Active");
  const {
    token, setToken,
    user, setUser,
    curriculum, setCurriculum, fetchCurriculum,
    config, setConfig
  } = useStore();

  // SSO Auto-login via Cookie
  useEffect(() => {
    const getCookie = (name: string) => {
      const value = `; ${document.cookie}`;
      const parts = value.split(`; ${name}=`);
      if (parts.length === 2) return parts.pop()?.split(';').shift();
      return null;
    };

    const ssoToken = getCookie('auth_token');
    if (ssoToken && !token) {
      console.log("SSO Token detected, logging in...");
      setToken(ssoToken);
    }
  }, []);

  const [loginUsername, setLoginUsername] = useState('');
  const [loginPassword, setLoginPassword] = useState('');
  const [loginLoading, setLoginLoading] = useState(false);

  // VIEW STATE
  const [activeTab, setActiveTab] = useState<string | null>('dispatcher');
  const [ldapUsers, setLdapUsers] = useState<any[]>([]);
  const [ldapSearchQuery, setLdapSearchQuery] = useState('');
  const [ldapLoading, setLdapLoading] = useState(false);
  const [localGroups, setLocalGroups] = useState<any[]>([]);
  const [assignedUsers, setAssignedUsers] = useState<any[]>([]);
  const [error, setError] = useState<string | null>(null);

  // Group Creation State
  const [isGroupModalOpen, setIsGroupModalOpen] = useState(false);
  const [newGroup, setNewGroup] = useState({ name: '', year: 1, pathway: 'Tronc Commun', formation_type: 'FI' });

  // Import Options State
  const [isImportModalOpen, setIsImportModalOpen] = useState(false);
  const [pendingImportFile, setPendingImportFile] = useState<File | null>(null);
  const [importOptions, setImportOptions] = useState({ year: 1, formation_type: 'FI' });

  // LDAP Search Logic
  useEffect(() => {
    const delayDebounceFn = setTimeout(async () => {
      if (ldapSearchQuery.length >= 3) {
        setLdapLoading(true);
        try {
          const res = await axios.get(`${API_URL}/ldap-users/search?q=${ldapSearchQuery}`);
          setLdapUsers(res.data);
        } catch (e) { console.error("Search error", e); }
        setLdapLoading(false);
      } else if (ldapSearchQuery.length === 0) {
        fetchData(); // Reset to default list if search is empty
      }
    }, 500);

    return () => clearTimeout(delayDebounceFn);
  }, [ldapSearchQuery]);

  // Axios Interceptor for Auth
  useEffect(() => {
    if (token) {
      axios.defaults.headers.common['Authorization'] = `Bearer ${token}`;
      
      // Extract user from token
      try {
        const payload = JSON.parse(atob(token.split('.')[1]));
        if (payload.sub) setUser({ username: payload.sub });
      } catch (e) { console.error("Error decoding token", e); }

      fetchData();
      fetchCurriculum(API_URL);
    } else {
      delete axios.defaults.headers.common['Authorization'];
      setUser(null);
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
      notifications.show({ title: 'Bienvenue', message: 'Connexion réussie' });
    } catch (e) {
      notifications.show({ color: 'red', title: 'Erreur', message: 'Identifiants incorrects' });
    }
    setLoginLoading(false);
  };

  const handleLogout = () => {
    setToken(null);
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
      setConfig(configRes.data);
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

  const handleStudentImport = (file: File | null) => {
    if (!file) return;
    setPendingImportFile(file);
    setIsImportModalOpen(true);
  };

  const submitStudentImport = async () => {
    if (!pendingImportFile) return;
    const formData = new FormData();
    formData.append('file', pendingImportFile);
    try {
      await axios.post(`${API_URL}/import/students?year=${importOptions.year}&formation_type=${importOptions.formation_type}`, formData);
      notifications.show({ title: 'Succès', message: 'Étudiants importés et assignés' });
      setIsImportModalOpen(false);
      setPendingImportFile(null);
      fetchData();
    } catch (e) {
      notifications.show({ color: 'red', title: 'Erreur', message: 'Échec de l\'importation' });
    }
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
          <Group gap="xl">
            {user && <Text size="sm" fw={500}>Bonjour, {user.username}</Text>}
            <Button variant="default" size="xs" onClick={handleLogout}>Déconnexion</Button>
          </Group>
        </Group>
      </AppShell.Header>
      <AppShell.Navbar p="md">
        <Stack>
          <Button variant={activeTab === 'dispatcher' ? 'light' : 'subtle'} onClick={() => setActiveTab('dispatcher')} leftSection={<IconUsers size={20} />}>Dispatching</Button>
          <Button variant={activeTab === 'curriculum' ? 'light' : 'subtle'} onClick={() => setActiveTab('curriculum')} leftSection={<IconBook size={20} />} color="grape">Référentiel</Button>
          <Button variant={activeTab === 'discovery' ? 'light' : 'subtle'} onClick={() => setActiveTab('discovery')} leftSection={<IconCategory size={20} />} color="teal">Découverte</Button>
          <Button variant={activeTab === 'repartition' ? 'light' : 'subtle'} onClick={() => setActiveTab('repartition')} leftSection={<IconDatabase size={20} />} color="orange">Répartition</Button>
          {/* <Button variant={activeTab === 'fiches' ? 'light' : 'subtle'} onClick={() => setActiveTab('fiches')} leftSection={<IconDownload size={20} />} color="blue">Fiches PDF</Button> */}
          <Button variant={activeTab === 'fiches2' ? 'light' : 'subtle'} onClick={() => setActiveTab('fiches2')} leftSection={<IconFileText size={20} />} color="cyan">Fiches PDF 2</Button>
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
                  <Select label="Parcours" data={['Tronc Commun', 'BI', 'BDMRC', 'MDEE', 'MMPV', 'SME']} value={newGroup.pathway} onChange={(v) => setNewGroup({...newGroup, pathway: v || 'Tronc Commun'})} />
                  <Select label="Type" data={[{label: 'Initiale', value: 'FI'}, {label: 'Alternance', value: 'FA'}]} value={newGroup.formation_type} onChange={(v) => setNewGroup({...newGroup, formation_type: v || 'FI'})} />
                  <Button onClick={handleCreateGroup}>Valider</Button>
                </Stack>
              </Modal>

              <Modal opened={isImportModalOpen} onClose={() => setIsImportModalOpen(false)} title="Configuration de l'importation">
                <Stack>
                  <Text size="sm">Fichier : <b>{pendingImportFile?.name}</b></Text>
                  <Select 
                    label="Niveau de BUT" 
                    data={[{label: 'BUT 1', value: '1'}, {label: 'BUT 2', value: '2'}, {label: 'BUT 3', value: '3'}]} 
                    value={importOptions.year.toString()} 
                    onChange={(v) => setImportOptions({...importOptions, year: parseInt(v || '1')})} 
                  />
                  <Select 
                    label="Type de formation" 
                    data={[{label: 'Initiale (FI)', value: 'FI'}, {label: 'Alternance (FA)', value: 'FA'}]} 
                    value={importOptions.formation_type} 
                    onChange={(v) => setImportOptions({...importOptions, formation_type: v || 'FI'})} 
                  />
                  <Button onClick={submitStudentImport}>Lancer l'importation</Button>
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
                    <Title order={5} mb="xs">Annuaire LDAP</Title>
                    <TextInput 
                      placeholder="Chercher (Nom, UID...)" 
                      mb="md" 
                      value={ldapSearchQuery} 
                      onChange={(e) => setLdapSearchQuery(e.target.value)} 
                      rightSection={ldapLoading ? <Center><Badge size="xs" variant="subtle">...</Badge></Center> : null}
                    />
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
                    <Accordion variant="separated">
                      {localGroups.sort((a, b) => a.year - b.year || a.name.localeCompare(b.name)).map(group => (
                        <Accordion.Item key={group.id} value={`group-${group.id}`} mb="xs">
                          <Accordion.Control bg={`${YEAR_COLORS[group.year]}.0`}>
                            <Group justify="space-between" pr="md">
                              <Group gap="xs">
                                <Text fw={700} size="sm">{group.name}</Text>
                                <Badge color={YEAR_COLORS[group.year]} size="xs">BUT {group.year}</Badge>
                                <Badge variant="outline" color="gray" size="xs">{group.formation_type}</Badge>
                                <Text size="xs" c="dimmed">({assignedUsers.filter(u => u.group_id === group.id).length} étudiants)</Text>
                              </Group>
                              <Group gap={5} onClick={(e) => e.stopPropagation()}>
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
                          </Accordion.Control>
                          <Accordion.Panel>
                            <Droppable droppableId={`group-${group.id}`}>
                              {(provided, snapshot) => (
                                <div ref={provided.innerRef} {...provided.droppableProps} style={{ 
                                  minHeight: '50px',
                                  backgroundColor: snapshot.isDraggingOver ? 'var(--mantine-color-blue-0)' : 'transparent',
                                  padding: '10px',
                                  borderRadius: '8px'
                                }}>
                                  <Stack gap={4}>
                                    {assignedUsers.filter(u => u.group_id === group.id).map((u, index) => (
                                      <Draggable key={u.ldap_uid} draggableId={u.ldap_uid} index={index}>
                                        {(provided) => (
                                          <Paper withBorder p="xs" ref={provided.innerRef} {...provided.draggableProps} {...provided.dragHandleProps} bg="white">
                                            <Group justify="space-between">
                                              <div>
                                                <Text size="xs" fw={500}>{u.full_name}</Text>
                                                <Text size="10px" c="dimmed">{u.email}</Text>
                                              </div>
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
                                    {assignedUsers.filter(u => u.group_id === group.id).length === 0 && (
                                      <Center p="xs"><Text size="xs" c="dimmed italic">Glissez des étudiants ici</Text></Center>
                                    )}
                                  </Stack>
                                </div>
                              )}
                            </Droppable>
                          </Accordion.Panel>
                        </Accordion.Item>
                      ))}
                    </Accordion>
                  </ScrollArea>
                </Grid.Col>
              </Grid>
            </Container>
          ) : activeTab === 'curriculum' ? (
            <CompetencyEditor 
                curriculum={curriculum} 
                onRefresh={() => fetchCurriculum(API_URL)}
                professors={assignedUsers.filter(u => u.role === 'PROFESSOR' || u.role === 'ADMIN' || u.role === 'SUPER_ADMIN')} 
            />
          ) : activeTab === 'discovery' ? (
            <DiscoveryView curriculum={curriculum} />
          ) : activeTab === 'repartition' ? (
            <RepartitionView curriculum={curriculum} />
          ) : activeTab === 'fiches' ? (
            <FichesView />
          ) : activeTab === 'fiches2' ? (
            <FichesPDF2View curriculum={curriculum} />
          ) : <SettingsView config={config} onSave={handleSaveConfig} />}
        </DragDropContext>
      </AppShell.Main>
    </AppShell>
  );
}





export default App;
