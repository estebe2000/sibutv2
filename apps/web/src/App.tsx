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
  FileInput
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

// Detect API URL
const API_URL = window.location.hostname === 'localhost' 
  ? 'http://localhost:8000' 
  : `http://${window.location.hostname}:8000`;

const YEAR_COLORS: any = {
  0: 'gray',
  1: 'blue',
  2: 'green',
  3: 'grape'
};

function App() {
  const {
    token, setToken,
    user, setUser,
    curriculum, setCurriculum, fetchCurriculum,
    config, setConfig
  } = useStore();

  const [loginUsername, setLoginUsername] = useState('');
  const [loginPassword, setLoginPassword] = useState('');
  const [loginLoading, setLoginLoading] = useState(false);

  // VIEW STATE
  const [activeTab, setActiveTab] = useState<string | null>('dispatcher');
  const [ldapUsers, setLdapUsers] = useState<any[]>([]);
  const [localGroups, setLocalGroups] = useState<any[]>([]);
  const [assignedUsers, setAssignedUsers] = useState<any[]>([]);
  const [error, setError] = useState<string | null>(null);

  // Group Creation State
  const [isGroupModalOpen, setIsGroupModalOpen] = useState(false);
  const [newGroup, setNewGroup] = useState({ name: '', year: 1, pathway: 'Tronc Commun', formation_type: 'FI' });

  // Axios Interceptor for Auth
  useEffect(() => {
    if (token) {
      axios.defaults.headers.common['Authorization'] = `Bearer ${token}`;
      fetchData();
      fetchCurriculum(API_URL);
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

function DiscoveryView({ curriculum }: any) {
  if (!curriculum || !curriculum.competences || curriculum.competences.length === 0) return <Center p="xl"><Stack align="center"><Loader /><Text>Chargement du référentiel...</Text></Stack></Center>;
  const [pathway, setPathway] = useState('SME');
  const [selectedCompCode, setSelectedCompCode] = useState('C1');
  const [infoItem, setInfoItem] = useState<any>(null);
  const years = [1, 2, 3];
  const compCodes = ['C1', 'C2', 'C3', 'C4', 'C5'];

  const getCompInfo = (code: string, year: number) => {
    const comp = curriculum.competences.find((c: any) => c.code.startsWith(code) && c.level === year && (year === 1 || c.pathway === pathway || c.pathway === 'Tronc Commun'));
    if (comp && comp.learning_outcomes) comp.learning_outcomes.sort((a: any, b: any) => a.code.localeCompare(b.code));
    return comp;
  };

  const selectedData = {
      title: selectedCompCode === 'C1' ? 'Marketing' : selectedCompCode === 'C2' ? 'Vente' : selectedCompCode === 'C3' ? 'Communication' : 'Spécialisation',
      comp: getCompInfo(selectedCompCode, 1)
  };

  return (
    <Container size="xl">
      <Group justify="space-between" mb="xl">
        <Title order={2}>Roadmap de Formation</Title>
        <Select data={['BI', 'BDMRC', 'MDEE', 'MMPV', 'SME']} value={pathway} onChange={(v) => setPathway(v || 'SME')} />
      </Group>
      
      <Grid gutter="md">
        {compCodes.map(code => (
            <Grid.Col span={12} key={code}>
                <Paper withBorder p="sm">
                    <Grid align="center">
                        <Grid.Col span={2}><Badge size="xl" radius="sm" fullWidth>{code}</Badge></Grid.Col>
                        {years.map(y => {
                            const c = getCompInfo(code, y);
                            return (
                                <Grid.Col span={3} key={y}>
                                    <Card withBorder padding="xs" shadow={selectedCompCode === code ? "md" : "none"} 
                                          style={{ cursor: 'pointer', border: selectedCompCode === code ? '2px solid blue' : '1px solid #eee' }}
                                          onClick={() => setSelectedCompCode(code)}>
                                        <Text size="xs" fw={700}>Niveau {y}</Text>
                                        <Text size="sm" truncate>{c?.label || "Non défini"}</Text>
                                    </Card>
                                </Grid.Col>
                            );
                        })}
                    </Grid>
                </Paper>
            </Grid.Col>
        ))}
      </Grid>

      {selectedCompCode && (
          <Paper withBorder mt="xl" p="xl" radius="lg" shadow="xl">
              <Title order={2} mb="xl" c="blue">{selectedCompCode} : {selectedData.title}</Title>
              <Grid gutter="xl">
                  {years.map(y => {
                      const c = getCompInfo(selectedCompCode, y);
                      return (
                          <Grid.Col span={4} key={y}>
                              <Paper withBorder h="100%" radius="md" bg="gray.0">
                                  <Paper p="xs" bg="blue.7" style={{ borderRadius: '8px 8px 0 0' }}><Text c="white" fw={700} ta="center">BUT {y}</Text></Paper>
                                  <Stack p="md" gap="xs">
                                      {c?.learning_outcomes?.map((lo: any) => (
                                          <Paper key={lo.id} withBorder p="xs" shadow="xs" style={{ cursor: 'pointer' }} onClick={() => setInfoItem(lo)}>
                                              <Group wrap="nowrap" gap="xs">
                                                  <Badge size="xs" variant="filled">{lo.code}</Badge>
                                                  <Text size="xs" fw={500}>{lo.label}</Text>
                                              </Group>
                                          </Paper>
                                      ))}
                                  </Stack>
                              </Paper>
                          </Grid.Col>
                      );
                  })}
              </Grid>
          </Paper>
      )}

      <Modal opened={!!infoItem} onClose={() => setInfoItem(null)} title={infoItem?.code} size="lg">
          <Stack>
              <Title order={4} c="blue">{infoItem?.label}</Title>
              <Divider />
              <Box>{infoItem?.description ? renderRichText(infoItem.description, curriculum, () => {}, () => {}) : "Détails à venir..."}</Box>
          </Stack>
      </Modal>
    </Container>
  );
}

function RepartitionView({ curriculum }: any) {
  const data = [
    { label: "Enseignement (h)", s1: 375, s2: 375, s3: 355, s4: 225, s5: 365, s6: 105, total: 1800 },
    { label: "Projet tutoré (h)", s1: 50, s2: 100, s3: 85, s4: 115, s5: 125, s6: 125, total: 600 }
  ];
  return (
    <Container size="xl">
      <Title order={2} mb="xl">Répartition des Heures</Title>
      <Paper withBorder p="md" shadow="sm"><Table striped highlightOnHover withBorder withColumnBorders>
        <Table.Thead bg="blue.7"><Table.Tr><Table.Th style={{color:'white'}}>Semestres</Table.Th><Table.Th style={{color:'white'}}>S1</Table.Th><Table.Th style={{color:'white'}}>S2</Table.Th><Table.Th style={{color:'white'}}>S3</Table.Th><Table.Th style={{color:'white'}}>S4</Table.Th><Table.Th style={{color:'white'}}>S5</Table.Th><Table.Th style={{color:'white'}}>S6</Table.Th><Table.Th style={{color:'white'}}>TOTAL</Table.Th></Table.Tr></Table.Thead>
        <Table.Tbody>{data.map((r, i) => (<Table.Tr key={i}><Table.Td fw={500}>{r.label}</Table.Td><Table.Td>{r.s1}</Table.Td><Table.Td>{r.s2}</Table.Td><Table.Td>{r.s3}</Table.Td><Table.Td>{r.s4}</Table.Td><Table.Td>{r.s5}</Table.Td><Table.Td>{r.s6}</Table.Td><Table.Td fw={700} bg="blue.0">{r.total}</Table.Td></Table.Tr>))}</Table.Tbody>
      </Table></Paper>
    </Container>
  );
}

function FichesView() {
  const [fiches, setFiches] = useState<any[]>([]);
  useEffect(() => { axios.get(`${API_URL}/fiches/list`).then(r => setFiches(r.data)); }, []);
  return (
    <Container size="xl">
      <Title order={2} mb="xl">Fiches PDF Statiques</Title>
      <Table striped withBorder><Table.Thead><Table.Tr><Table.Th>Semestre</Table.Th><Table.Th>Fiche</Table.Th><Table.Th>Action</Table.Th></Table.Tr></Table.Thead>
      <Table.Tbody>{fiches.map((f, i) => (<Table.Tr key={i}><Table.Td><Badge>{f.semester}</Badge></Table.Td><Table.Td>{f.name}</Table.Td><Table.Td><Button component="a" href={`${API_URL}${f.url}`} target="_blank" size="xs">Ouvrir</Button></Table.Td></Table.Tr>))}</Table.Tbody></Table>
    </Container>
  );
}

function FichesPDF2View({ curriculum }: any) {
  const [search, setSearch] = useState('');
  const [typeFilter, setTypeFilter] = useState('TOUS');
  const [pathwayFilter, setPathwayFilter] = useState('TOUS');
  const [semesterFilter, setSemesterFilter] = useState('TOUS');

  const pathways = ['TOUS', 'Tronc Commun', 'BI', 'BDMRC', 'MDEE', 'MMPV', 'SME'];
  const types = ['TOUS', 'SAE', 'STAGE', 'PORTFOLIO', 'RESSOURCE'];
  const semesters = ['TOUS', '1', '2', '3', '4', '5', '6'];

  const allItems = [
    ...(curriculum.activities || []).map((a: any) => ({ ...a, it: 'ACT', displayType: a.type })),
    ...(curriculum.resources || []).map((r: any) => {
        const semMatch = r.code.match(/R(\d)/);
        const sem = semMatch ? semMatch[1] : '0';
        return { ...r, it: 'RES', displayType: 'RESSOURCE', semester: parseInt(sem) };
    })
  ];

  const filtered = allItems.filter((item: any) => {
    const matchesSearch = item.code.toLowerCase().includes(search.toLowerCase()) || 
                          item.label.toLowerCase().includes(search.toLowerCase());
    const matchesType = typeFilter === 'TOUS' || (typeFilter === 'RESSOURCE' ? item.it === 'RES' : item.displayType === typeFilter);
    const matchesPathway = pathwayFilter === 'TOUS' || item.pathway === pathwayFilter;
    const matchesSemester = semesterFilter === 'TOUS' || item.semester.toString() === semesterFilter;
    return matchesSearch && matchesType && matchesPathway && matchesSemester;
  });

  return (
    <Container size="xl">
      <Title order={2} mb="xl">Génération de PDF à la volée</Title>
      <Paper withBorder p="md" shadow="sm" radius="md" mb="xl">
        <Grid align="flex-end">
          <Grid.Col span={3}><TextInput label="Rechercher" placeholder="Code..." value={search} onChange={(e) => setSearch(e.target.value)} /></Grid.Col>
          <Grid.Col span={2}><Select label="Type" data={types} value={typeFilter} onChange={(v) => setTypeFilter(v || 'TOUS')} /></Grid.Col>
          <Grid.Col span={3}><Select label="Parcours" data={pathways} value={pathwayFilter} onChange={(v) => setPathwayFilter(v || 'TOUS')} /></Grid.Col>
          <Grid.Col span={2}><Select label="Semestre" data={semesters} value={semesterFilter} onChange={(v) => setSemesterFilter(v || 'TOUS')} /></Grid.Col>
          <Grid.Col span={2}><Text size="xs" c="dimmed" ta="right">{filtered.length} éléments</Text></Grid.Col>
        </Grid>
      </Paper>
      <Paper withBorder p={0} shadow="sm"><Table striped highlightOnHover>
      <Table.Thead bg="gray.1"><Table.Tr><Table.Th>Type</Table.Th><Table.Th>Sem.</Table.Th><Table.Th>Code</Table.Th><Table.Th>Libellé</Table.Th><Table.Th style={{textAlign:'right'}}>Action</Table.Th></Table.Tr></Table.Thead>
      <Table.Tbody>{filtered.map((item: any, i: number) => (<Table.Tr key={i}>
          <Table.Td><Badge color={item.it === 'RES' ? 'teal' : 'orange'} size="sm" variant="light">{item.displayType}</Badge></Table.Td>
          <Table.Td><Badge variant="outline" size="xs">S{item.semester}</Badge></Table.Td>
          <Table.Td fw={700} size="sm">{item.code}</Table.Td><Table.Td>{item.label}</Table.Td>
          <Table.Td><Group justify="flex-end"><Button size="xs" variant="light" leftSection={<IconFileText size={12}/>} onClick={() => window.open(`${API_URL}/${item.it === 'RES' ? 'resources' : 'activities'}/${item.id}/pdf`, '_blank')}>Générer PDF</Button></Group></Table.Td>
      </Table.Tr>))}</Table.Tbody></Table></Paper>
    </Container>
  );
}

function SettingsView({ config, onSave }: any) {
  const [localConfig, setLocalConfig] = useState<any[]>([]);
  useEffect(() => {
    const defaults = [
      { key: 'inst_name', value: 'BUT TC - Skills Hub', category: 'identity' },
      { key: 'inst_logo_url', value: '', category: 'identity' },
      { key: 'inst_address', value: '', category: 'identity' },
      { key: 'inst_contact_email', value: '', category: 'identity' },
      { key: 'ldap_url', value: 'ldap://ldap:389', category: 'ldap' },
      { key: 'smtp_host', value: 'mail', category: 'mail' }
    ];
    setLocalConfig(defaults.map(d => config.find((c: any) => c.key === d.key) || d));
  }, [config]);
  const updateVal = (key: string, val: string) => setLocalConfig(prev => prev.map(c => c.key === key ? { ...c, value: val } : c));
  return (
    <Container size="md">
      <Title order={2} mb="xl">Configuration du Système</Title>
      <Stack>{localConfig.map(item => (<TextInput key={item.key} label={item.key.replace(/_/g, ' ').toUpperCase()} value={item.value} onChange={(e) => updateVal(item.key, e.target.value)} />))}<Button onClick={() => onSave(localConfig)}>Enregistrer la configuration</Button></Stack>
    </Container>
  );
}

export default App;
