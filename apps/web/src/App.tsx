import React, { useState, useEffect } from 'react';
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
  Loader,
  Table
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

const renderRichText = (text: string, curriculum: any, showInfo: any, setActiveTab: any) => {
    if (!text) return null;
    return text.split('\n').map((line: string, lineIdx: number) => {
        const trimmedLine = line.trim();
        if (!trimmedLine) return <Box key={lineIdx} h={10} />;

        // 1. Header Handling (###)
        if (trimmedLine.startsWith('###')) {
            return (
                <Title order={6} key={lineIdx} mt="sm" c="blue" tt="uppercase">
                    {trimmedLine.replace('###', '').trim()}
                </Title>
            );
        }

        // 2. Inline Content Parsing (Badges)
        const renderInline = (text: string) => {
            if (!text) return '';
            
            // Regex to match badges only (R1.01, etc.)
            const parts = text.split(/(\b[R|S]\d+\.[\w\.]+\b|\bSAÉ?\s\d+\.[\w\.]+\b)/g);
            
            return parts.map((part, i) => {
                if (!part) return null;

                // Handle Resource Badge
                const resMatch = part.match(/\b(R\d+\.[\w\.]+)\b/);
                if (resMatch) {
                    const code = resMatch[1];
                    const resInfo = curriculum.resources?.find((r: any) => r.code === code);
                    return (
                        <Badge 
                            key={i} size="xs" color="teal" variant="light" 
                            style={{ cursor: 'pointer', textTransform: 'none', verticalAlign: 'middle' }}
                            onClick={(e) => { e.stopPropagation(); showInfo(resInfo || {code}, 'RES'); }}
                        >
                            {code}
                        </Badge>
                    );
                }

                // Handle Activity Badge
                const actMatch = part.match(/\b(SAÉ?\s\d+\.[\w\.]+)\b/);
                if (actMatch) {
                    const code = actMatch[1];
                    return (
                        <Badge 
                            key={i} size="xs" color="orange" variant="light" 
                            style={{ cursor: 'pointer', verticalAlign: 'middle' }}
                            onClick={(e) => { 
                                e.stopPropagation(); 
                                window.dispatchEvent(new CustomEvent('switch-to-activities', { detail: code }));
                            }}
                        >
                            {code}
                        </Badge>
                    );
                }

                return part;
            });
        };

        // 3. List Item Handling (•)
        if (trimmedLine.startsWith('•')) {
            return (
                <Group key={lineIdx} gap="xs" wrap="nowrap" align="flex-start" style={{ paddingLeft: 10 }}>
                    <Text size="sm" c="blue">•</Text>
                    <Text size="sm" style={{ flex: 1 }}>
                        {renderInline(trimmedLine.substring(1).trim())}
                    </Text>
                </Group>
            );
        }

        // 4. Standard Paragraph
        return (
            <Text key={lineIdx} size="sm" style={{ lineHeight: 1.6 }}>
                {renderInline(trimmedLine)}
            </Text>
        );
    });
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
          <Button variant={activeTab === 'discovery' ? 'light' : 'subtle'} onClick={() => setActiveTab('discovery')} leftSection={<IconCategory size={20} />} color="teal">Découverte</Button>
          <Button variant={activeTab === 'repartition' ? 'light' : 'subtle'} onClick={() => setActiveTab('repartition')} leftSection={<IconDatabase size={20} />} color="orange">Répartition</Button>
          <Button variant={activeTab === 'fiches' ? 'light' : 'subtle'} onClick={() => setActiveTab('fiches')} leftSection={<IconDownload size={20} />} color="blue">Fiches PDF</Button>
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
                onRefresh={fetchCurriculum} 
                professors={assignedUsers.filter(u => u.role === 'PROFESSOR' || u.role === 'ADMIN' || u.role === 'SUPER_ADMIN')} 
            />
          ) : activeTab === 'discovery' ? (
            <DiscoveryView curriculum={curriculum} />
          ) : activeTab === 'repartition' ? (
            <RepartitionView curriculum={curriculum} />
          ) : activeTab === 'fiches' ? (
            <FichesView />
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
  
  const [activeTabs, setActiveTabs] = useState<Record<number, string | null>>({ 1: 'comps', 2: 'comps', 3: 'comps' });
  const [expandedResource, setExpandedResource] = useState<string | null>(null);
  const [expandedActivity, setExpandedActivity] = useState<string | null>(null);
  const [expandedComp, setExpandedComp] = useState<string | null>(null);

  const getLevelFromCode = (code: string) => {
    const m = code.match(/[R|S|SAE]\s?(\d)/);
    if (!m) return 1;
    const digit = parseInt(m[1]);
    if (digit <= 2) return 1;
    if (digit <= 4) return 2;
    return 3;
  };

  useEffect(() => {
    const compHandler = (e: any) => {
        const code = e.detail;
        const lvl = getLevelFromCode(code);
        setActiveTabs(prev => ({ ...prev, [lvl]: 'comps' }));
        const comp = curriculum.competences.find((c: any) => c.code === code);
        if (comp) {
            setExpandedComp(comp.code + comp.id);
            setTimeout(() => {
                const el = document.getElementById(`comp-accordion-${comp.code + comp.id}`);
                if (el) el.scrollIntoView({ behavior: 'smooth', block: 'center' });
            }, 200);
        }
    };
    const resHandler = (e: any) => {
        const code = e.detail;
        const lvl = getLevelFromCode(code);
        setActiveTabs(prev => ({ ...prev, [lvl]: 'ress' }));
        
        const res = curriculum.resources.find((r: any) => r.code === code);
        if (res) {
            setExpandedResource(res.code + res.id);
            setTimeout(() => {
                const el = document.getElementById(`accordion-${res.code + res.id}`);
                if (el) el.scrollIntoView({ behavior: 'smooth', block: 'center' });
            }, 200);
        }
    };
    const actHandler = (e: any) => {
        const code = e.detail;
        const lvl = getLevelFromCode(code);
        setActiveTabs(prev => ({ ...prev, [lvl]: 'acts' }));

        const searchCode = code.replace('SAÉ', 'SAE').trim();
        const act = curriculum.activities.find((a: any) => a.code === searchCode);
        if (act) {
            const val = act.code + act.id;
            setExpandedActivity(val);
            setTimeout(() => {
                const el = document.getElementById(`act-accordion-${val}`);
                if (el) el.scrollIntoView({ behavior: 'smooth', block: 'center' });
            }, 200);
        }
    };
    window.addEventListener('switch-to-comp', compHandler);
    window.addEventListener('switch-to-resources', resHandler);
    window.addEventListener('switch-to-activities', actHandler);
    return () => {
        window.removeEventListener('switch-to-comp', compHandler);
        window.removeEventListener('switch-to-resources', resHandler);
        window.removeEventListener('switch-to-activities', actHandler);
    };
  }, [curriculum]);

  const pathways = ['TOUS', 'Tronc Commun', 'BI', 'BDMRC', 'MDEE', 'MMPV', 'SME'];
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

  const showInfo = async (item: any, type: 'RES' | 'AC', pathway?: string) => {
    setInfoLoading(true);
    setInfoItem({ ...item, type });
    try {
        if (type === 'RES') {
            const url = pathway 
                ? `${API_URL}/resources/${item.code.trim()}?pathway=${encodeURIComponent(pathway)}` 
                : `${API_URL}/resources/${item.code.trim()}`;
            const res = await axios.get(url);
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
      {/* INFO MODAL - ADAPTIVE VERSION */}
      <Modal opened={!!infoItem} onClose={() => setInfoItem(null)} title={infoItem?.code || "Infos"} size={infoItem?.type === 'AC' ? "lg" : "md"}>
        {infoLoading ? <Center p="xl"><Loader /></Center> : infoItem && (
            <Stack>
                <Title order={4} c="blue">{infoItem.label || infoItem.code}</Title>
                
                {infoItem.type === 'RES' && (infoItem.hours > 0 || infoItem.hours_details) && (
                    <Badge color="blue" variant="filled" leftSection={<IconClock size={12} />}>
                        Volume Horaire : {infoItem.hours_details || `${infoItem.hours}h`}
                    </Badge>
                )}
                
                <Divider />
                
                {infoItem.error ? <Text color="red">{infoItem.error}</Text> : (
                    <>
                        {infoItem.type === 'AC' ? (
                            // FULL SHEET FOR AC
                            <Box>
                                {renderRichText(infoItem.description, curriculum, showInfo, setActiveTabs)}
                            </Box>
                        ) : (
                            // LIGHT VERSION FOR RESOURCE
                            <>
                                {infoItem.description && (
                                    <Box>
                                        <Text size="sm" fw={700} mb={4}>Résumé :</Text>
                                        <Box>
                                            {renderRichText(infoItem.description.includes('Mots clés :') ? infoItem.description.split('Mots clés :')[0] : infoItem.description, curriculum, showInfo, setActiveTabs)}
                                        </Box>
                                    </Box>
                                )}

                                {infoItem.learning_outcomes?.length > 0 && (
                                    <Box mt="md">
                                        <Text size="sm" fw={700} mb={4}>AC Liés :</Text>
                                        <Group gap={5}>
                                            {infoItem.learning_outcomes.map((lo: any) => (
                                                <Badge key={lo.id} size="xs" variant="outline">{lo.code}</Badge>
                                            ))}
                                        </Group>
                                    </Box>
                                )}
                                
                                <Button 
                                    fullWidth 
                                    variant="light" 
                                    mt="lg" 
                                                                    onClick={() => {
                                                                        const code = infoItem.code;
                                                                        setInfoItem(null); 
                                                                        window.dispatchEvent(new CustomEvent('switch-to-resources', { detail: code }));
                                                                    }}                                >
                                    Voir la fiche complète (Menu Ressources)
                                </Button>
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

        const acts = (curriculum.activities?.filter((a: any) => {
            if (a.level !== lvl) return false;
            if (pathway === 'TOUS') return true;
            return a.pathway === currPathway || a.pathway === 'Tronc Commun';
        }) || []).sort((a: any, b: any) => {
            // 1. Sort by Semester
            if (a.semester !== b.semester) return a.semester - b.semester;
            
            // 2. Sort by Type (SAE first, then PORTFOLIO, then STAGE)
            const typeOrder: any = { 'SAE': 1, 'PORTFOLIO': 2, 'STAGE': 3, 'PROJET': 4 };
            const typeA = typeOrder[a.type] || 99;
            const typeB = typeOrder[b.type] || 99;
            if (typeA !== typeB) return typeA - typeB;
            
            // 3. Sort by Code
            return a.code.localeCompare(b.code);
        });

        if (comps.length === 0 && acts.length === 0) return null;

        return (
          <Paper key={lvl} withBorder p="md" mb="xl" shadow="sm">
            <Group justify="space-between" mb="md">
              <Title order={3} c="blue">BUT {lvl}</Title>
              <Badge size="lg" variant="light">{pathway === 'TOUS' ? 'Tous Parcours' : currPathway}</Badge>
            </Group>

            <Tabs value={activeTabs[lvl]} onChange={(v) => setActiveTabs(prev => ({ ...prev, [lvl]: v }))}>
              <Tabs.List mb="md">
                <Tabs.Tab value="comps" leftSection={<IconCategory size={16} />}>Compétences ({comps.length})</Tabs.Tab>
                <Tabs.Tab value="acts" leftSection={<IconDatabase size={16} />} color="orange">Activités ({acts.length})</Tabs.Tab>
                <Tabs.Tab value="ress" leftSection={<IconBook size={16} />} color="teal">Ressources ({curriculum.resources?.filter((r: any) => {
                            if (!r.code) return false;
                            const codePrefix = parseInt(r.code.replace('R', '').split('.')[0]);
                            if (isNaN(codePrefix)) return false;
                            
                            // Level Filter
                            let matchLevel = false;
                            if (lvl === 1 && (codePrefix === 1 || codePrefix === 2)) matchLevel = true;
                            if (lvl === 2 && (codePrefix === 3 || codePrefix === 4)) matchLevel = true;
                            if (lvl === 3 && (codePrefix === 5 || codePrefix === 6)) matchLevel = true;
                            if (!matchLevel) return false;

                            // Pathway Filter
                            const currPathway = lvl === 1 ? 'Tronc Commun' : pathway;
                            if (pathway === 'TOUS') return true;
                            return r.pathway === currPathway || r.pathway === 'Tronc Commun';
                        }).length})</Tabs.Tab>
              </Tabs.List>

              <Tabs.Panel value="comps">
                <Accordion variant="separated" value={expandedComp} onChange={setExpandedComp}>
                  {comps.map((c: any) => (
                    <Accordion.Item key={c.id} value={c.code + c.id} id={`comp-accordion-${c.code + c.id}`}>
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
                        <Stack gap="lg">
                            {c.situations_pro && (
                                <Box>
                                    <Text size="xs" fw={700} c="blue" mb={4} tt="uppercase">Situations Professionnelles (Contextes)</Text>
                                    <Paper withBorder p="sm" bg="blue.0">
                                        <List size="sm" spacing="xs">
                                            {c.situations_pro.split('\n').map((s: string, i: number) => (
                                                <List.Item key={i}>{s.trim()}</List.Item>
                                            ))}
                                        </List>
                                    </Paper>
                                </Box>
                            )}

                            <Box>
                                <Text size="xs" fw={700} c="dimmed" mb={4} tt="uppercase">Composantes Essentielles (Critères Qualité)</Text>
                                <List size="sm" spacing="xs" withPadding>
                                    {c.essential_components?.map((ce: any) => (
                                        <List.Item key={ce.id}><b>{ce.code}</b> : {ce.label}</List.Item>
                                    ))}
                                </List>
                            </Box>

                            <Box>
                                <Text size="xs" fw={700} c="blue" mb={8} tt="uppercase">Apprentissages Critiques (Détails des attentes)</Text>
                                <Accordion variant="contained" chevronPosition="right">
                                    {c.learning_outcomes?.sort((a: any, b: any) => a.code.localeCompare(b.code)).map((lo: any) => (
                                        <Accordion.Item key={lo.id} value={lo.code}>
                                            <Accordion.Control>
                                                <Group gap="xs">
                                                    <Badge size="sm" variant="filled">{lo.code}</Badge>
                                                    <Text size="sm" fw={500}>{lo.label}</Text>
                                                </Group>
                                            </Accordion.Control>
                                            <Accordion.Panel>
                                                <Box p="xs">
                                                    {lo.description ? (
                                                        renderRichText(lo.description, curriculum, showInfo, setActiveTabs)
                                                    ) : (
                                                        <Text size="sm" c="dimmed" fs="italic">Détails de compréhension à venir...</Text>
                                                    )}
                                                </Box>
                                            </Accordion.Panel>
                                        </Accordion.Item>
                                    ))}
                                </Accordion>
                            </Box>
                        </Stack>
                      </Accordion.Panel>
                    </Accordion.Item>
                  ))}
                </Accordion>
              </Tabs.Panel>

              <Tabs.Panel value="acts">
                <Accordion variant="separated" value={expandedActivity} onChange={setExpandedActivity}>
                  {acts.map((a: any) => (
                    <Accordion.Item key={a.id} value={a.code + a.id} id={`act-accordion-${a.code + a.id}`}>
                      <Accordion.Control>
                        <Group justify="space-between" wrap="nowrap">
                            <Group gap="sm" wrap="nowrap">
                                <Badge color={a.type === 'SAE' ? 'orange' : a.type === 'STAGE' ? 'teal' : (a.type === 'PORTFOLIO' ? 'cyan' : 'grape')} size="sm" w={80} style={{ flexShrink: 0 }}>{a.type}</Badge>
                                <Text fw={600} size="sm" truncate>{a.code} : {a.label}</Text>
                            </Group>
                            <Group gap="xs" wrap="nowrap" style={{ flexShrink: 0 }}>
                                {a.hours > 0 && (
                                    <Badge size="xs" variant="light" color="gray" leftSection={<IconClock size={10} />}>{a.hours}h</Badge>
                                )}
                                <ActionIcon size="xs" variant="subtle" onClick={(e) => { e.stopPropagation(); setEditingAct(a); }}><IconPencil size={12} /></ActionIcon>
                            </Group>
                        </Group>
                      </Accordion.Control>
                      <Accordion.Panel>
                        <Grid>
                            <Grid.Col span={12}>
                                {a.description && (
                                    <Box mb="sm">
                                        <Text size="xs" fw={700} c="dimmed" mb={4}>OBJECTIFS ET CONTEXTE</Text>
                                        <Text size="sm" style={{ whiteSpace: 'pre-wrap', lineHeight: 1.5 }}>{a.description}</Text>
                                    </Box>
                                )}
                            </Grid.Col>
                            
                            <Grid.Col span={6}>
                                <Text size="xs" fw={700} c="orange" mb={4}>RESSOURCES MOBILISÉES</Text>
                                <Group gap={6}>
                                    {a.resources ? a.resources.split(',').map((rCode: string) => {
                                        const code = rCode.trim();
                                        const resInfo = curriculum.resources?.find((r: any) => r.code === code);
                                        return (
                                            <Badge 
                                                key={code}
                                                size="sm" 
                                                variant="light" 
                                                color="orange" 
                                                style={{ cursor: 'pointer', textTransform: 'none' }} 
                                                className="hover-badge"
                                                onClick={() => showInfo(resInfo || {code}, 'RES', a.pathway)}
                                                leftSection={<IconBook size={10} />}
                                            >
                                                {code}
                                            </Badge>
                                        );
                                    }) : <Text size="xs" c="dimmed" fs="italic">Aucune ressource</Text>}
                                </Group>
                            </Grid.Col>

                            <Grid.Col span={6}>
                                <Text size="xs" fw={700} c="blue" mb={4}>COMPÉTENCES (AC)</Text>
                                <Group gap={6}>
                                    {a.learning_outcomes?.length > 0 ? a.learning_outcomes.map((lo: any) => (
                                        <Badge 
                                            key={lo.id}
                                            size="sm" 
                                            variant="light" 
                                            color="blue" 
                                            style={{ cursor: 'pointer' }} 
                                            className="hover-badge"
                                            onClick={() => setInfoItem({...lo, type: 'AC'})}
                                        >
                                            {lo.code}
                                        </Badge>
                                    )) : <Text size="xs" c="dimmed" fs="italic">Aucun AC lié</Text>}
                                </Group>
                            </Grid.Col>

                            <Grid.Col span={12}>
                                <Divider my="xs" variant="dotted" />
                                <Group gap="xl">
                                    <Group gap={4}>
                                        <IconCrown size={14} color="gold" />
                                        <Text size="xs" c="dimmed">Responsable : {professors?.find((p: any) => p.id === a.owner_id)?.full_name || 'Non assigné'}</Text>
                                    </Group>
                                    <Group gap={4}>
                                        <IconUsers size={14} color="gray" />
                                        <Text size="xs" c="dimmed">Intervenants : {a.intervenants?.length || 0}</Text>
                                    </Group>
                                </Group>
                            </Grid.Col>
                        </Grid>
                      </Accordion.Panel>
                    </Accordion.Item>
                  ))}
                </Accordion>
              </Tabs.Panel>

              <Tabs.Panel value="ress">
                <Accordion variant="separated" value={expandedResource} onChange={setExpandedResource}>
                    {curriculum.resources
                        ?.filter((r: any) => {
                            if (!r.code) return false;
                            
                            // 1. Filter by Level
                            const codePrefix = parseInt(r.code.replace('R', '').split('.')[0]);
                            if (isNaN(codePrefix)) return false;
                            if (lvl === 1 && (codePrefix !== 1 && codePrefix !== 2)) return false;
                            if (lvl === 2 && (codePrefix !== 3 && codePrefix !== 4)) return false;
                            if (lvl === 3 && (codePrefix !== 5 && codePrefix !== 6)) return false;

                            // 2. Filter by Pathway
                            const currPathway = lvl === 1 ? 'Tronc Commun' : pathway;
                            if (pathway === 'TOUS') return true;
                            // Resources from BUT 1 are usually Tronc Commun
                            // Resources from BUT 2/3 are tagged by pathway OR Tronc Commun
                            return r.pathway === currPathway || r.pathway === 'Tronc Commun';
                        })
                        .sort((a: any, b: any) => {
                            // Extract semester and index from code R{sem}.{pathway}.{index} or R{sem}.{index}
                            // Examples: R3.01, R3.SME.15
                            const parseResCode = (code: string) => {
                                const parts = code.replace('R', '').split('.');
                                const sem = parseInt(parts[0]) || 0;
                                // Last part is usually the index
                                const idx = parseInt(parts[parts.length - 1]) || 0;
                                return { sem, idx };
                            };
                            
                            const valA = parseResCode(a.code);
                            const valB = parseResCode(b.code);
                            
                            if (valA.sem !== valB.sem) return valA.sem - valB.sem;
                            return valA.idx - valB.idx;
                        })
                        .map((r: any) => (
                        <Accordion.Item key={r.id} value={r.code + r.id} id={`accordion-${r.code + r.id}`}>
                            <Accordion.Control>
                                <Group justify="space-between" wrap="nowrap">
                                    <Group gap="sm" wrap="nowrap">
                                        <Badge color="teal" size="sm" w={60} style={{ flexShrink: 0 }}>{r.code}</Badge>
                                        <Text fw={600} size="sm" truncate>{r.label}</Text>
                                    </Group>
                                    <Group gap="xs" wrap="nowrap" style={{ flexShrink: 0 }}>
                                        {r.hours > 0 && (
                                            <Badge size="xs" variant="light" color="gray" leftSection={<IconClock size={10} />}>{r.hours}h</Badge>
                                        )}
                                        <Button size="compact-xs" variant="light" onClick={(e) => { e.stopPropagation(); showInfo(r, 'RES'); }}>Détail</Button>
                                    </Group>
                                </Group>
                            </Accordion.Control>
                            <Accordion.Panel>
                                <Stack gap="md">
                                    {(r.hours > 0 || r.hours_details) && (
                                        <Group>
                                            <Badge size="lg" color="blue" variant="filled" leftSection={<IconClock size={14} />}>Volume Horaire : {r.hours_details || `${r.hours}h`}</Badge>
                                        </Group>
                                    )}

                                    {r.description && (
                                        <Box>
                                            <Text size="xs" fw={700} c="dimmed" mb={4}>DESCRIPTIF & CONTRIBUTION</Text>
                                            <Text size="sm" style={{ whiteSpace: 'pre-wrap' }}>{r.description.includes('Mots clés :') ? r.description.split('Mots clés :')[0] : r.description}</Text>
                                        </Box>
                                    )}
                                    
                                    {r.content && (
                                        <Box>
                                            <Text size="xs" fw={700} c="dark" mb={4}>CONTENU PÉDAGOGIQUE</Text>
                                            <Text size="sm" style={{ whiteSpace: 'pre-wrap', lineHeight: 1.6, paddingLeft: 10, borderLeft: '2px solid #eee' }}>{r.content}</Text>
                                        </Box>
                                    )}

                                    {r.targeted_competencies && (
                                        <Box>
                                            <Text size="xs" fw={700} c="teal" mb={4}>COMPÉTENCES CIBLÉES</Text>
                                            <List size="xs" spacing={2} icon={<ThemeIcon color="teal" size={6} radius="xl"><IconPlus size={4}/></ThemeIcon>}>
                                                {r.targeted_competencies.split(',').map((comp: string, idx: number) => (
                                                    <List.Item key={idx}>{comp.trim()}</List.Item>
                                                ))}
                                            </List>
                                        </Box>
                                    )}

                                    {r.learning_outcomes?.length > 0 && (
                                        <Box>
                                            <Text size="xs" fw={700} c="blue" mb={4}>APPRENTISSAGES CRITIQUES CIBLÉS</Text>
                                            <List size="xs" spacing={2} icon={<ThemeIcon color="blue" size={6} radius="xl"><IconPlus size={4}/></ThemeIcon>}>
                                                {r.learning_outcomes.map((lo: any) => (
                                                    <List.Item key={lo.id}>
                                                        <b>{lo.code}</b> : {lo.label}
                                                    </List.Item>
                                                ))}
                                            </List>
                                        </Box>
                                    )}
                                    
                                    {r.description && r.description.includes('Mots clés :') && (
                                        <Box>
                                            <Text size="xs" fw={700} c="grape" mb={4}>MOTS CLÉS</Text>
                                            <Text size="sm" c="dimmed">{r.description.split('Mots clés :')[1].split('Volume')[0]}</Text>
                                        </Box>
                                    )}
                                </Stack>
                            </Accordion.Panel>
                        </Accordion.Item>
                    ))}
                </Accordion>
              </Tabs.Panel>
            </Tabs>
          </Paper>
        );
      })}
    </Container>
  );
}

function RepartitionView({ curriculum }: any) {
  if (!curriculum || !curriculum.activities) return <Center p="xl"><Loader /></Center>;
  
  const [pathway, setPathway] = useState('SME');
  const [semester, setSemester] = useState('1');
  
  const pathways = ['BI', 'BDMRC', 'MDEE', 'MMPV', 'SME'];
  const semesters = ['1', '2', '3', '4', '5', '6'];

  const structureData = [
    { label: "Nbre d'heures d'enseignement (ressources + SAÉ)", s1: 375, s2: 375, s3: 355, s4: 225, s5: 365, s6: 105, total: 1800 },
    { label: "Dont % d'adaptation locale (max 40%)", s1: "27 %", s2: "27 %", s3: "36 %", s4: "40 %", s5: "37 %", s6: "48 %", total: "33 %" },
    { label: "Nbre d'heures d'enseignement définies localement", s1: 100, s2: 100, s3: 125, s4: 90, s5: 135, s6: 50, total: 600 },
    { label: "Nbre heures d'enseignement SAÉ définies localement", s1: 60, s2: 75, s3: 100, s4: 75, s5: 100, s6: 40, total: 450 },
    { label: "Nbre heures d'enseignement à définir localement (Res ou SAÉ)", s1: 40, s2: 25, s3: 25, s4: 15, s5: 35, s6: 10, total: 150 },
    { label: "Nbre heures d'enseignement ressources nationales", s1: 275, s2: 275, s3: 230, s4: 135, s5: 230, s6: 55, total: 1200 },
    { label: "Nbre heures de TP définies nationalement", s1: 86, s2: 77, s3: 61, s4: 40, s5: 72, s6: 17, total: 523 },
    { label: "Nbre heures de TP à définir localement", s1: 35, s2: 45, s3: 35, s4: 35, s5: 15, s6: 5, total: 170 },
    { label: "Nbre d'heures de projet tutoré", s1: 50, s2: 100, s3: 85, s4: 115, s5: 125, s6: 125, total: 600 },
    { label: "Nbre de semaines de stage", s1: 0, s2: "2 à 4", s3: 0, s4: 8, s5: 0, s6: "14 à 16", total: "24 à 26" },
  ];

  const semInt = parseInt(semester);
  const isCommon = semInt <= 2;

  const acts = (curriculum.activities?.filter((a: any) => a.semester === semInt && (isCommon || a.pathway === pathway || a.pathway === 'Tronc Commun')) || [])
                .sort((a: any, b: any) => a.code.localeCompare(b.code));
  
  const ress = (curriculum.resources?.filter((r: any) => {
      if (!r.code) return false;
      const codePrefix = parseInt(r.code.replace('R', '').split('.')[0]);
      if (codePrefix !== semInt) return false;
      return isCommon || r.pathway === pathway || r.pathway === 'Tronc Commun';
  }) || []).sort((a: any, b: any) => {
      const parseResCode = (code: string) => {
          const parts = code.replace('R', '').split('.');
          return parseInt(parts[parts.length - 1]) || 0;
      };
      return parseResCode(a.code) - parseResCode(b.code);
  });

  const lvl = semInt <= 2 ? 1 : (semInt <= 4 ? 2 : 3);
  const comps = (curriculum.competences?.filter((c: any) => c.level === lvl && (isCommon || c.pathway === pathway || c.pathway === 'Tronc Commun')) || [])
                .sort((a: any, b: any) => a.code.localeCompare(b.code));

  return (
    <Container size="xl">
      <Title order={2} mb="xl">Structure et Répartition des Heures</Title>
      
      <Tabs defaultValue="structure" variant="pills" mb="xl">
          <Tabs.List>
              <Tabs.Tab value="structure" leftSection={<IconClock size={16} />}>Tableau de Structure</Tabs.Tab>
              <Tabs.Tab value="cross" leftSection={<IconDatabase size={16} />}>Tableau Croisé (Matrice AC)</Tabs.Tab>
          </Tabs.List>

          <Tabs.Panel value="structure" pt="xl">
            <Paper withBorder shadow="md" radius="md" p="md">
                <ScrollArea>
                <Table striped highlightOnHover withBorder withColumnBorders verticalSpacing="sm">
                    <Table.Thead>
                    <Table.Tr bg="blue.7">
                        <Table.Th style={{ color: 'white' }}>Semestres</Table.Th>
                        <Table.Th style={{ color: 'white', textAlign: 'center' }}>S1</Table.Th>
                        <Table.Th style={{ color: 'white', textAlign: 'center' }}>S2</Table.Th>
                        <Table.Th style={{ color: 'white', textAlign: 'center' }}>S3</Table.Th>
                        <Table.Th style={{ color: 'white', textAlign: 'center' }}>S4</Table.Th>
                        <Table.Th style={{ color: 'white', textAlign: 'center' }}>S5</Table.Th>
                        <Table.Th style={{ color: 'white', textAlign: 'center' }}>S6</Table.Th>
                        <Table.Th style={{ color: 'white', textAlign: 'center' }}>TOTAL</Table.Th>
                    </Table.Tr>
                    </Table.Thead>
                    <Table.Tbody>
                    {structureData.map((row, idx) => (
                        <Table.Tr key={idx}>
                        <Table.Td fw={row.label.includes('TOTAL') ? 700 : 500}>{row.label}</Table.Td>
                        <Table.Td style={{ textAlign: 'center' }}>{row.s1}</Table.Td>
                        <Table.Td style={{ textAlign: 'center' }}>{row.s2}</Table.Td>
                        <Table.Td style={{ textAlign: 'center' }}>{row.s3}</Table.Td>
                        <Table.Td style={{ textAlign: 'center' }}>{row.s4}</Table.Td>
                        <Table.Td style={{ textAlign: 'center' }}>{row.s5}</Table.Td>
                        <Table.Td style={{ textAlign: 'center' }}>{(row as any).s6}</Table.Td>
                        <Table.Td style={{ textAlign: 'center', backgroundColor: '#f8f9fa' }} fw={700}>{row.total}</Table.Td>
                        </Table.Tr>
                    ))}
                    </Table.Tbody>
                </Table>
                </ScrollArea>
            </Paper>
          </Tabs.Panel>

          <Tabs.Panel value="cross" pt="xl">
              <Group mb="xl" gap="xl">
                  <Select label="Semestre" data={semesters} value={semester} onChange={(v) => setSemester(v || '1')} style={{ width: 120 }} />
                  {semInt > 2 && <Select label="Parcours" data={pathways} value={pathway} onChange={(v) => setPathway(v || 'SME')} style={{ width: 200 }} />}
              </Group>

              <Paper withBorder shadow="md" radius="md" p="md" bg="gray.0">
                  <ScrollArea h={600}>
                      <Table withBorder withColumnBorders verticalSpacing="xs" style={{ minWidth: 1000 }}>
                          <Table.Thead>
                              <Table.Tr bg="dark.6">
                                  <Table.Th style={{ color: 'white', minWidth: 250 }}>Apprentissages Critiques (AC)</Table.Th>
                                  {acts.map(a => (
                                      <Table.Th key={a.id} style={{ color: 'white', textAlign: 'center', fontSize: '10px' }}>
                                          <Box style={{ transform: 'rotate(-45deg)', height: 80, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                                              {a.code}
                                          </Box>
                                      </Table.Th>
                                  ))}
                                  {ress.map(r => (
                                      <Table.Th key={r.id} style={{ color: 'white', textAlign: 'center', fontSize: '10px' }}>
                                          <Box style={{ transform: 'rotate(-45deg)', height: 80, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                                              {r.code}
                                          </Box>
                                      </Table.Th>
                                  ))}
                              </Table.Tr>
                          </Table.Thead>
                          <Table.Tbody>
                              {comps.map(c => (
                                  <React.Fragment key={c.id}>
                                      <Table.Tr bg="blue.0">
                                          <Table.Td colSpan={1 + acts.length + ress.length} fw={700} size="sm">
                                              {c.code} : {c.label}
                                          </Table.Td>
                                      </Table.Tr>
                                      {c.learning_outcomes?.map((lo: any) => (
                                          <Table.Tr key={lo.id} bg="white">
                                              <Table.Td style={{ fontSize: '11px' }}><b>{lo.code}</b> : {lo.label}</Table.Td>
                                              {acts.map(a => {
                                                  const isLinked = a.learning_outcomes?.some((alc: any) => lo.code.startsWith(alc.code.substring(0,7)));
                                                  return <Table.Td key={a.id} style={{ textAlign: 'center' }}>{isLinked ? <Badge color="orange" size="xs">X</Badge> : null}</Table.Td>
                                              })}
                                              {ress.map(r => {
                                                  const isLinked = r.learning_outcomes?.some((rlc: any) => lo.code.startsWith(rlc.code.substring(0,7)));
                                                  return <Table.Td key={r.id} style={{ textAlign: 'center' }}>{isLinked ? <Badge color="teal" size="xs">X</Badge> : null}</Table.Td>
                                              })}
                                          </Table.Tr>
                                      ))}
                                  </React.Fragment>
                              ))}
                              
                              <Table.Tr bg="gray.1">
                                  <Table.Td fw={700}>Volume Horaire (H)</Table.Td>
                                  {acts.map(a => <Table.Td key={a.id} style={{ textAlign: 'center', fontSize: '10px' }}>{a.hours > 0 ? a.hours : '-'}</Table.Td>)}
                                  {ress.map(r => <Table.Td key={r.id} style={{ textAlign: 'center', fontSize: '10px' }}>{r.hours}</Table.Td>)}
                              </Table.Tr>
                              <Table.Tr bg="gray.1">
                                  <Table.Td fw={700}>Dont TP (H)</Table.Td>
                                  {acts.map(a => <Table.Td key={a.id} style={{ textAlign: 'center' }}>-</Table.Td>)}
                                  {ress.map(r => {
                                      const tpMatch = r.hours_details?.match(/(\d+)\s*heures\s*de\s*TP/i);
                                      return <Table.Td key={r.id} style={{ textAlign: 'center', fontSize: '10px' }}>{tpMatch ? tpMatch[1] : '-'}</Table.Td>
                                  })}
                              </Table.Tr>
                          </Table.Tbody>
                      </Table>
                  </ScrollArea>
              </Paper>
          </Tabs.Panel>
      </Tabs>

      <Box mt="md">
          <Text size="xs" c="dimmed" italic>Source : Programme National B.U.T. Techniques de Commercialisation - Page 63 et tableaux croisés par semestre.</Text>
      </Box>
    </Container>
  );
}

function FichesView() {
  const [fiches, setFiches] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [pathwayFilter, setPathwayFilter] = useState('TOUS');
  const [semesterFilter, setSemesterFilter] = useState('TOUS');

  const pathways = ['TOUS', 'Tronc Commun', 'BI', 'BDMRC', 'MDEE', 'MMPV', 'SME'];
  const semesters = ['TOUS', 'S1', 'S2', 'S3', 'S4', 'S5', 'S6'];

  useEffect(() => {
    fetchFiches();
  }, []);

  const fetchFiches = async () => {
    setLoading(true);
    try {
      const res = await axios.get(`${API_URL}/fiches/list`);
      setFiches(res.data);
    } catch (e) {
      notifications.show({ title: 'Erreur', message: 'Impossible de charger la liste des fiches', color: 'red' });
    }
    setLoading(false);
  };

  const filtered = fiches.filter(f => {
    const matchesSearch = f.name.toLowerCase().includes(search.toLowerCase()) || f.code?.toLowerCase().includes(search.toLowerCase());
    const matchesPathway = pathwayFilter === 'TOUS' || f.pathway === pathwayFilter;
    const matchesSemester = semesterFilter === 'TOUS' || f.semester === semesterFilter;
    return matchesSearch && matchesPathway && matchesSemester;
  });

  return (
    <Container size="xl">
      <Group justify="space-between" mb="xl">
        <Title order={2}>Fiches Pédagogiques PDF</Title>
        <Button variant="outline" onClick={fetchFiches} loading={loading}>Actualiser la liste</Button>
      </Group>

      <Paper withBorder p="md" shadow="sm" radius="md" mb="xl">
        <Grid align="flex-end">
          <Grid.Col span={4}>
            <TextInput label="Rechercher une fiche" placeholder="Ex: Marketing, SAE 1.01..." value={search} onChange={(e) => setSearch(e.target.value)} />
          </Grid.Col>
          <Grid.Col span={3}>
            <Select label="Filtrer par Parcours" data={pathways} value={pathwayFilter} onChange={(v) => setPathwayFilter(v || 'TOUS')} />
          </Grid.Col>
          <Grid.Col span={3}>
            <Select label="Filtrer par Semestre" data={semesters} value={semesterFilter} onChange={(v) => setSemesterFilter(v || 'TOUS')} />
          </Grid.Col>
          <Grid.Col span={2}>
            <Text size="xs" c="dimmed" ta="right">{filtered.length} fiches trouvées</Text>
          </Grid.Col>
        </Grid>
      </Paper>

      <Paper withBorder shadow="md" radius="md" p={0} style={{ overflow: 'hidden' }}>
        <ScrollArea h={600}>
          <Table striped highlightOnHover>
            <Table.Thead bg="gray.1">
              <Table.Tr>
                <Table.Th>Sem.</Table.Th>
                <Table.Th>Fiche</Table.Th>
                <Table.Th>Parcours</Table.Th>
                <Table.Th style={{ textAlign: 'right' }}>Actions</Table.Th>
              </Table.Tr>
            </Table.Thead>
            <Table.Tbody>
              {loading ? (
                <Table.Tr><Table.Td colSpan={4}><Center p="xl"><Loader size="sm" /></Center></Table.Td></Table.Tr>
              ) : filtered.length === 0 ? (
                <Table.Tr><Table.Td colSpan={4}><Center p="xl"><Text c="dimmed">Aucune fiche trouvée</Text></Center></Table.Td></Table.Tr>
              ) : filtered.map((f, i) => (
                <Table.Tr key={i}>
                  <Table.Td><Badge variant="light" color="blue">{f.semester}</Badge></Table.Td>
                  <Table.Td>
                    <Group gap="xs">
                      <IconBook size={16} color="gray" />
                      <Text size="sm" fw={500}>{f.name}</Text>
                    </Group>
                  </Table.Td>
                  <Table.Td><Text size="xs">{f.pathway}</Text></Table.Td>
                  <Table.Td>
                    <Group gap="xs" justify="flex-end">
                      <Button 
                        size="compact-xs" 
                        variant="subtle" 
                        component="a" 
                        href={`${API_URL}${f.url}`} 
                        target="_blank"
                        leftSection={<IconInfoCircle size={12} />}
                      >
                        Aperçu
                      </Button>
                      <Button 
                        size="compact-xs" 
                        variant="light" 
                        component="a" 
                        href={`${API_URL}${f.url}`} 
                        download
                        leftSection={<IconDownload size={12} />}
                      >
                        Télécharger
                      </Button>
                    </Group>
                  </Table.Td>
                </Table.Tr>
              ))}
            </Table.Tbody>
          </Table>
        </ScrollArea>
      </Paper>
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

function DiscoveryView({ curriculum }: any) {
  if (!curriculum || !curriculum.competences) return <Center p="xl"><Loader /></Center>;

  const [pathway, setPathway] = useState('SME');
  const [selectedCompCode, setSelectedCompCode] = useState('C1');
  const [infoItem, setInfoItem] = useState<any>(null);
  const [infoLoading, setInfoLoading] = useState(false);

  const pathways = ['BI', 'BDMRC', 'MDEE', 'MMPV', 'SME'];
  const years = [1, 2, 3];
  const compCodes = ['C1', 'C2', 'C3', 'C4', 'C5'];

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

  const getCompInfo = (code: string, year: number) => {
    const p = (code === 'C1' || code === 'C2' || code === 'C3' || year === 1) ? 'Tronc Commun' : pathway;
    if (code === 'C3' && year === 3) return null;

    const comp = curriculum.competences.find((c: any) => 
        c.code.startsWith(code) && 
        c.level === year && 
        (c.pathway === p || (year > 1 && c.pathway === pathway && c.code.startsWith(code)))
    );

    const focusMapping: any = {
        'C1': { 1: 'Construire une offre simple', 2: 'Offre complexe ou innovante', 3: 'Solution client étendue' },
        'C2': { 1: 'Préparer l\'entretien de vente', 2: 'Mener un entretien simple', 3: 'Mener une vente complexe' },
        'C3': { 1: 'Structurer un plan de com', 2: 'Élaborer un plan de com', 3: '' },
        'SME': {
            'C4': { 2: 'Déployer l\'image de marque', 3: 'Construire la stratégie de marque' },
            'C5': { 2: 'Élaborer un événement simple', 3: 'Élaborer un évènement complexe' }
        },
        'MMPV': {
            'C4': { 2: 'Gérer l\'équipe (opérationnel)', 3: 'Mobiliser l\'équipe (stratégique)' },
            'C5': { 2: 'Contribuer à la dynamique', 3: 'Manager la dynamique' }
        },
        'MDEE': {
            'C4': { 2: 'Participer au projet digital', 3: 'Développer le projet digital' },
            'C5': { 2: 'Partie prenante e-business', 3: 'Responsable e-business' }
        },
        'BI': {
            'C4': { 2: 'Assistant dév import/export', 3: 'Chargé de dév import/export' },
            'C5': { 2: 'Commercialiser offre simple', 3: 'Commercialiser offre complexe' }
        },
        'BDMRC': {
            'C4': { 2: 'Membre équipe commerciale', 3: 'Responsable équipe commerciale' },
            'C5': { 2: 'Membre équipe relation client', 3: 'Responsable équipe relation client' }
        }
    };

    let focus = "";
    if (code === 'C1' || code === 'C2' || code === 'C3') focus = focusMapping[code][year];
    else if (focusMapping[pathway] && focusMapping[pathway][code]) focus = focusMapping[pathway][code][year];

    if (!comp) return null;
    
    // Sort ACs by code alphabetically
    if (comp.learning_outcomes) {
        comp.learning_outcomes.sort((a: any, b: any) => a.code.localeCompare(b.code));
    }
    
    return { comp, focus };
  };

  const selectedData = {
      code: selectedCompCode,
      title: selectedCompCode === 'C1' ? 'Marketing' : 
             selectedCompCode === 'C2' ? 'Vente' : 
             selectedCompCode === 'C3' ? 'Communication' : 
             selectedCompCode === 'C4' ? (pathway === 'SME' ? 'Branding' : pathway === 'MMPV' ? 'Management' : pathway === 'MDEE' ? 'Marketing Digital' : pathway === 'BI' ? 'Stratégie Inter' : 'Business Dév') :
             (pathway === 'SME' ? 'Evénementiel' : pathway === 'MMPV' ? 'Retail' : pathway === 'MDEE' ? 'E-Business' : pathway === 'BI' ? 'Opérations Inter' : 'Relation Client'),
      baseInfo: (getCompInfo(selectedCompCode, 2) || getCompInfo(selectedCompCode, 1))?.comp,
      levels: [
          getCompInfo(selectedCompCode, 1),
          getCompInfo(selectedCompCode, 2),
          getCompInfo(selectedCompCode, 3)
      ].filter(l => l !== null) as any[]
  };

  return (
    <Container size="xl">
      <Group justify="space-between" mb="xl">
        <Stack gap={0}>
            <Title order={2}>Roadmap de Formation</Title>
            <Text c="dimmed">Découvrez la progression des compétences par parcours</Text>
        </Stack>
        <Select 
            label="Choisir un parcours"
            data={pathways} 
            value={pathway} 
            onChange={(v) => setPathway(v || 'SME')}
            style={{ width: 250 }}
        />
      </Group>

      <Paper withBorder p="md" shadow="md" radius="md" bg="white">
        <Grid gutter="md">
            <Grid.Col span={3}></Grid.Col>
            {years.map(y => (
                <Grid.Col span={3} key={y}>
                    <Paper p="xs" shadow="xs" radius="md" bg="blue.7" style={{ textAlign: 'center' }}>
                        <Text fw={700} c="white">BUT {y}</Text>
                    </Paper>
                </Grid.Col>
            ))}

            {compCodes.map(code => (
                <Grid.Col span={12} key={code}>
                    <Grid gutter="md" align="stretch">
                        <Grid.Col span={3}>
                            <Paper p="sm" h="100%" withBorder shadow="xs" radius="md" 
                                   onClick={() => setSelectedCompCode(code)}
                                   style={{ 
                                       display: 'flex', alignItems: 'center', cursor: 'pointer',
                                       backgroundColor: selectedCompCode === code ? 'var(--mantine-color-blue-0)' : 'white',
                                       borderColor: selectedCompCode === code ? 'var(--mantine-color-blue-6)' : 'var(--mantine-color-gray-3)'
                                   }}>
                                <Group gap="sm">
                                    <Badge size="lg" radius="sm" variant="filled" color={code === 'C4' || code === 'C5' ? 'teal' : 'blue'}>{code}</Badge>
                                    <Text fw={700} size="sm">
                                        {code === 'C1' ? 'Marketing' : 
                                         code === 'C2' ? 'Vente' : 
                                         code === 'C3' ? 'Communication' : 
                                         code === 'C4' ? (pathway === 'SME' ? 'Branding' : pathway === 'MMPV' ? 'Management' : pathway === 'MDEE' ? 'Marketing Digital' : pathway === 'BI' ? 'Stratégie Inter' : 'Business Dév') :
                                         (pathway === 'SME' ? 'Evénementiel' : pathway === 'MMPV' ? 'Retail' : pathway === 'MDEE' ? 'E-Business' : pathway === 'BI' ? 'Opérations Inter' : 'Relation Client')}
                                    </Text>
                                </Group>
                            </Paper>
                        </Grid.Col>
                        {years.map(y => {
                            const info = getCompInfo(code, y);
                            if (!info) return <Grid.Col span={3} key={y}></Grid.Col>;
                            return (
                                <Grid.Col span={3} key={y}>
                                    <Card withBorder shadow="sm" radius="md" h="100%" padding="xs" 
                                          onClick={() => setSelectedCompCode(code)}
                                          style={{ 
                                              cursor: 'pointer',
                                              borderLeft: `4px solid var(--mantine-color-${code === 'C4' || code === 'C5' ? 'teal' : 'blue'}-6)`,
                                              backgroundColor: selectedCompCode === code ? 'var(--mantine-color-gray-0)' : 'white'
                                          }}>
                                        <Stack gap={4}>
                                            <Text size="xs" fw={700} c="dimmed">Niveau {y}</Text>
                                            <Text size="sm" fw={600} style={{ lineHeight: 1.2 }}>{info.focus}</Text>
                                        </Stack>
                                    </Card>
                                </Grid.Col>
                            );
                        })}
                    </Grid>
                </Grid.Col>
            ))}
        </Grid>
      </Paper>

      {/* DETAILED FICHE (PAGE 18 STYLE) */}
      <Paper withBorder mt={50} shadow="xl" radius="lg" p={0} style={{ overflow: 'hidden' }}>
          <Group bg={selectedCompCode === 'C4' || selectedCompCode === 'C5' ? 'teal.7' : 'blue.7'} p="xl" justify="space-between">
              <Group gap="xl">
                  <ThemeIcon size={60} radius="md" color="white" c={selectedCompCode === 'C4' || selectedCompCode === 'C5' ? 'teal.7' : 'blue.7'}>
                      <Title order={2}>{selectedCompCode}</Title>
                  </ThemeIcon>
                  <Stack gap={0}>
                      <Title order={2} c="white" tt="uppercase">{selectedData.title}</Title>
                      <Text size="lg" c="white" fw={500} style={{ opacity: 0.9 }}>{selectedData.baseInfo?.description || 'Référentiel de compétences'}</Text>
                  </Stack>
              </Group>
          </Group>

          <Grid gutter={0}>
              {/* Situations Pro & CE */}
              <Grid.Col span={12} p="xl" bg="gray.0">
                  <Grid gutter="xl">
                      <Grid.Col span={6}>
                          <Group mb="md">
                              <ThemeIcon color="blue" variant="light"><IconUsers size={18} /></ThemeIcon>
                              <Text fw={700} tt="uppercase">Situations Professionnelles</Text>
                          </Group>
                          <Paper withBorder p="md" radius="md" bg="white">
                              {selectedData.baseInfo?.situations_pro ? (
                                  <List spacing="sm" size="sm" icon={<ThemeIcon color="blue" size={6} radius="xl"><IconPlus size={4}/></ThemeIcon>}>
                                      {selectedData.baseInfo.situations_pro.split('\n').map((s: string, i: number) => (
                                          <List.Item key={i}>{s.trim()}</List.Item>
                                      ))}
                                  </List>
                              ) : <Text c="dimmed" fs="italic">Non définies</Text>}
                          </Paper>
                      </Grid.Col>
                      <Grid.Col span={6}>
                          <Group mb="md">
                              <ThemeIcon color="teal" variant="light"><IconShieldCheck size={18} /></ThemeIcon>
                              <Text fw={700} tt="uppercase">Composantes Essentielles</Text>
                          </Group>
                          <Paper withBorder p="md" radius="md" bg="white">
                              <List spacing="xs" size="xs">
                                  {selectedData.baseInfo?.essential_components?.map((ce: any) => (
                                      <List.Item key={ce.id}><b>{ce.code}</b> : {ce.label}</List.Item>
                                  ))}
                              </List>
                          </Paper>
                      </Grid.Col>
                  </Grid>
              </Grid.Col>

              {/* Learning Outcomes Table (The heart of page 18) */}
              <Grid.Col span={12} p="xl">
                  <Title order={4} mb="xl" c="blue" tt="uppercase" style={{ textAlign: 'center' }}>Progression des Apprentissages Critiques (AC)</Title>
                  <Grid gutter="md" justify="center">
                      {selectedData.levels.map((lvlData: any, idx: number) => (
                          <Grid.Col span={selectedData.levels.length === 2 ? 6 : 4} key={idx}>
                              <Paper withBorder h="100%" shadow="sm" radius="md">
                                  <Paper p="xs" bg="blue.7" style={{ borderRadius: '8px 8px 0 0', textAlign: 'center' }}>
                                      <Text c="white" fw={700} size="sm">NIVEAU {lvlData.comp.level}</Text>
                                      <Text c="white" size="xs" italic>{lvlData.focus}</Text>
                                  </Paper>
                                  <Stack p="md" gap="xs">
                                      {lvlData.comp?.learning_outcomes?.sort((a: any, b: any) => a.code.localeCompare(b.code)).map((lo: any) => (
                                          <Paper key={lo.id} withBorder p="xs" bg="gray.0" style={{ cursor: 'pointer' }}
                                                 onClick={() => showInfo(lo, 'AC')}>
                                              <Group gap="xs" wrap="nowrap" align="flex-start">
                                                  <Badge size="xs" variant="filled" style={{ flexShrink: 0 }}>{lo.code}</Badge>
                                                  <Text size="xs" fw={500}>{lo.label}</Text>
                                              </Group>
                                          </Paper>
                                      ))}
                                  </Stack>
                              </Paper>
                          </Grid.Col>
                      ))}
                  </Grid>
              </Grid.Col>
          </Grid>
      </Paper>

      {/* MODAL FOR DISCOVERY */}
      <Modal opened={!!infoItem} onClose={() => setInfoItem(null)} title={infoItem?.code || "Infos"} size={infoItem?.type === 'AC' ? "lg" : "md"}>
        {infoLoading ? <Center p="xl"><Loader /></Center> : infoItem && (
            <Stack>
                <Title order={4} c="blue">{infoItem.label || infoItem.code}</Title>
                <Divider />
                {infoItem.error ? <Text color="red">{infoItem.error}</Text> : (
                    <Box>
                        {infoItem.type === 'AC' ? (
                            renderRichText(infoItem.description, curriculum, showInfo, () => {})
                        ) : (
                            <Box>
                                <Text size="sm" fw={700} mb={4}>Résumé :</Text>
                                <Box>
                                    {renderRichText(infoItem.description?.includes('Mots clés :') ? infoItem.description.split('Mots clés :')[0] : infoItem.description, curriculum, showInfo, () => {})}
                                </Box>
                            </Box>
                        )}
                    </Box>
                )}
            </Stack>
        )}
      </Modal>
    </Container>
  );
}

export default App;

