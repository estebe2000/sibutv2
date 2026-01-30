import React, { useState, useEffect } from 'react';
import {
  Paper,
  Stack,
  Group,
  Title,
  Text,
  Badge,
  ScrollArea,
  TextInput,
  ActionIcon,
  Modal,
  Button,
  Select,
  Grid,
  FileInput,
  Container,
  Accordion,
  Center,
  Tabs,
  Loader
} from '@mantine/core';
import {
  IconUsers,
  IconDatabase,
  IconTrash,
  IconGripVertical,
  IconPencil,
  IconUpload,
  IconUserPlus,
  IconShieldCheck,
  IconCrown
} from '@tabler/icons-react';
import { notifications } from '@mantine/notifications';
import { DragDropContext, Droppable, Draggable } from '@hello-pangea/dnd';
import api from '../services/api';
import { useStore } from '../store/useStore';
import { ResponsibilitySelector } from '../components/ResponsibilitySelector';
import { PedagogicalTeamManager } from '../components/PedagogicalTeamManager';

const YEAR_COLORS: any = { 1: 'blue', 2: 'grape', 3: 'teal' };

export function DispatcherView() {
  const { config } = useStore();
  const [activeTab, setActiveTab] = useState<string | null>('dispatch');
  const [ldapUsers, setLdapUsers] = useState<any[]>([]);
  const [localKeycloakUsers, setLocalKeycloakUsers] = useState<any[]>([]);
  const [localGroups, setLocalGroups] = useState<any[]>([]);
  const [assignedUsers, setAssignedUsers] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  
  const [ldapSearchQuery, setLdapSearchQuery] = useState('');
  const [ldapLoading, setLdapLoading] = useState(false);
  const [isGroupModalOpen, setIsGroupModalOpen] = useState(false);
  const [newGroup, setNewGroup] = useState({ name: '', year: 1, pathway: 'Tronc Commun', formation_type: 'FI' });
  const [isImportModalOpen, setIsImportModalOpen] = useState(false);
  const [pendingImportFile, setPendingImportFile] = useState<File | null>(null);
  const [importOptions, setImportOptions] = useState({ year: 1, formation_type: 'FI' });
  const [selectedStudent, setSelectedStudent] = useState<any>(null);

  const fetchData = async () => {
    try {
      const [groupsRes, usersRes, kcRes] = await Promise.all([
        api.get('/groups'),
        api.get('/users'),
        api.get('/keycloak/users')
      ]);
      setLocalGroups(groupsRes.data || []);
      setAssignedUsers(usersRes.data || []);
      setLocalKeycloakUsers((kcRes.data || []).filter((u: any) => !u.federationLink));
    } catch (e) { console.error(e); }
    setLoading(false);
  };

  useEffect(() => {
    fetchData();
  }, []);

  useEffect(() => {
    const delayDebounceFn = setTimeout(async () => {
      if (ldapSearchQuery.length >= 3) {
        setLdapLoading(true);
        try {
          const res = await api.get(`/ldap-users/search?q=${ldapSearchQuery}`);
          setLdapUsers(res.data || []);
        } catch (e) { console.error("Search error", e); }
        setLdapLoading(false);
      } else if (ldapSearchQuery.length === 0) {
        setLdapUsers([]);
      }
    }, 500);
    return () => clearTimeout(delayDebounceFn);
  }, [ldapSearchQuery]);

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
      await api.post(`/import/students?year=${importOptions.year}&formation_type=${importOptions.formation_type}`, formData);
      notifications.show({ title: 'Succès', message: 'Étudiants importés' });
      setIsImportModalOpen(false);
      fetchData();
    } catch (e) { notifications.show({ color: 'red', title: 'Erreur', message: 'Échec import' }); }
  };

  const handleCreateGroup = async () => {
    try {
      if ((newGroup as any).id) {
        await api.patch(`/groups/${(newGroup as any).id}`, newGroup);
      } else {
        await api.post('/groups', newGroup);
      }
      setIsGroupModalOpen(false);
      fetchData();
    } catch (e) { notifications.show({ color: 'red', title: 'Erreur' }); }
  };

  const deleteGroup = async (id: number) => {
    if (!window.confirm("Supprimer ce groupe ?")) return;
    try {
      await api.delete(`/groups/${id}`);
      fetchData();
    } catch (e) { notifications.show({ color: 'red', title: 'Erreur' }); }
  };

  const onDragEnd = async (result: any) => {
    const { source, destination, draggableId } = result;
    if (!destination) return;
    const destGroupId = parseInt(destination.droppableId.replace('group-', ''));
    if (isNaN(destGroupId)) return;

    if (source.droppableId === 'ldap-list') {
      // On cherche d'abord dans les locaux Keycloak
      let user = localKeycloakUsers.find(u => u.username === draggableId);
      if (user) {
        await api.post('/users/assign', { 
            ldap_uid: user.username, 
            email: user.email, 
            full_name: `${user.firstName} ${user.lastName}`, 
            role: 'STUDENT', 
            group_id: destGroupId 
        });
      } else {
        // Sinon dans les résultats LDAP
        user = ldapUsers.find(u => u.uid === draggableId);
        if (user) {
            await api.post('/users/assign', { 
                ldap_uid: user.uid, 
                email: user.email, 
                full_name: user.full_name, 
                role: 'STUDENT', 
                group_id: destGroupId 
            });
        }
      }
      fetchData();
    } else if (source.droppableId.startsWith('group-')) {
      const user = assignedUsers.find(u => u.ldap_uid === draggableId);
      if (user) {
        await api.post('/users/assign', { ldap_uid: user.ldap_uid, email: user.email, full_name: user.full_name, role: user.role, group_id: destGroupId });
        fetchData();
      }
    }
  };

  const unassignUser = async (ldapUid: string) => {
    try { await api.post(`/users/unassign?ldap_uid=${ldapUid}`); fetchData(); } catch (e) { fetchData(); }
  };

  if (loading) return <Center h="100vh"><Loader size="lg" /></Center>;

  const activePathwaysStr = config.find((c: any) => c.key === 'ACTIVE_PATHWAYS')?.value || 'BDMRC,BI,MDEE,MMPV,SME';
  const activePathways = ['Tronc Commun', ...activePathwaysStr.split(',').filter(Boolean)];

  return (
    <Container size="xl" h="calc(100vh - 100px)">
      <Tabs value={activeTab} onChange={setActiveTab} variant="pills" mb="md">
        <Tabs.List>
          <Tabs.Tab value="dispatch" leftSection={<IconUsers size={16} />}>Dispatching Étudiants</Tabs.Tab>
          <Tabs.Tab value="pedagogy" leftSection={<IconShieldCheck size={16} />}>Équipe Pédagogique</Tabs.Tab>
        </Tabs.List>
      </Tabs>

      {activeTab === 'dispatch' ? (
        <DragDropContext onDragEnd={onDragEnd}>
          <Modal opened={isGroupModalOpen} onClose={() => setIsGroupModalOpen(false)} title="Promotion">
            <Stack>
              <TextInput label="Nom du groupe" value={newGroup.name} onChange={(e) => setNewGroup({...newGroup, name: e.target.value})} required />
              <Select label="Année" data={['1', '2', '3']} value={newGroup.year.toString()} onChange={(v) => setNewGroup({...newGroup, year: parseInt(v || '1')})} />
              <Select label="Parcours" data={activePathways} value={newGroup.pathway} onChange={(v) => setNewGroup({...newGroup, pathway: v || 'Tronc Commun'})} />
              <Select label="Type" data={[{label: 'Initiale', value: 'FI'}, {label: 'Alternance', value: 'FA'}]} value={newGroup.formation_type} onChange={(v) => setNewGroup({...newGroup, formation_type: v || 'FI'})} />
              <Button onClick={handleCreateGroup}>Valider</Button>
            </Stack>
          </Modal>

          <Modal opened={isImportModalOpen} onClose={() => setIsImportModalOpen(false)} title="Importation">
            <Stack>
              <Select label="Niveau" data={['1', '2', '3']} value={importOptions.year.toString()} onChange={(v) => setImportOptions({...importOptions, year: parseInt(v || '1')})} />
              <Select label="Type" data={['FI', 'FA']} value={importOptions.formation_type} onChange={(v) => setImportOptions({...importOptions, formation_type: v || 'FI'})} />
              <Button onClick={submitStudentImport}>Lancer</Button>
            </Stack>
          </Modal>

          <Group justify="space-between" mb="md">
            <Title order={4}>Répartition des Promotions</Title>
            <Group>
              <FileInput placeholder="Importer (Excel)" size="xs" accept=".xlsx,.csv" leftSection={<IconUpload size={14} />} onChange={handleStudentImport} />
              <Button size="xs" leftSection={<IconUserPlus size={14} />} variant="outline" onClick={() => {
                setNewGroup({ name: '', year: 1, pathway: 'Tronc Commun', formation_type: 'FI' });
                setIsGroupModalOpen(true);
              }}>Nouveau Groupe</Button>
            </Group>
          </Group>

          <Grid h="calc(100% - 100px)">
            <Grid.Col span={4} h={500}>
              <Paper withBorder p="md" h="100%" bg="gray.0">
                <Title order={5} mb="xs">Utilisateurs Disponibles</Title>
                <Text size="10px" c="dimmed" mb="md">Comptes locaux et recherche LDAP (min. 3 car.)</Text>
                <TextInput placeholder="Chercher dans LDAP..." mb="md" value={ldapSearchQuery} onChange={(e) => setLdapSearchQuery(e.target.value)} />
                <Droppable droppableId="ldap-list" isDropDisabled={true}>
                  {(provided) => (
                    <ScrollArea h={400} ref={provided.innerRef} {...provided.droppableProps}>
                      <Stack gap="xs">
                        {/* 1. Comptes Locaux Keycloak */}
                        {localKeycloakUsers
                          .filter(lu => !assignedUsers.find(au => au.ldap_uid === lu.username))
                          .map((user, index) => (
                          <Draggable key={user.username} draggableId={user.username} index={index}>
                            {(p) => (
                              <Paper withBorder p="sm" ref={p.innerRef} {...p.draggableProps} {...p.dragHandleProps} bg="green.0" style={{ ...p.draggableProps.style, borderColor: 'var(--mantine-color-green-2)' }}>
                                <Group justify="space-between">
                                  <Group gap="xs">
                                    <IconGripVertical size={16} color="gray" />
                                    <div>
                                      <Text size="sm" fw={700}>{user.username}</Text>
                                      <Text size="xs" c="dimmed">{user.firstName} {user.lastName}</Text>
                                    </div>
                                  </Group>
                                  <Badge size="xs" color="green">Local</Badge>
                                </Group>
                              </Paper>
                            )}
                          </Draggable>
                        ))}

                        {/* 2. Résultats LDAP */}
                        {ldapUsers.filter(lu => !assignedUsers.find(au => au.ldap_uid === lu.uid)).map((user, index) => (
                          <Draggable key={user.uid} draggableId={user.uid} index={localKeycloakUsers.length + index}>
                            {(p) => (
                              <Paper withBorder p="sm" ref={p.innerRef} {...p.draggableProps} {...p.dragHandleProps} bg="white">
                                <Group justify="space-between">
                                  <Group gap="xs">
                                    <IconGripVertical size={16} color="gray" />
                                    <div>
                                      <Text size="sm" fw={500}>{user.full_name}</Text>
                                      <Text size="xs" c="dimmed">{user.email}</Text>
                                    </div>
                                  </Group>
                                  <Badge size="xs" color="blue">LDAP</Badge>
                                </Group>
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
              <ScrollArea h={600}>
                <Accordion variant="separated">
                  {(localGroups || []).sort((a, b) => a.year - b.year || a.name.localeCompare(b.name)).map(group => (
                    <Accordion.Item key={group.id} value={`group-${group.id}`} mb="xs">
                      <Accordion.Control bg={`${YEAR_COLORS[group.year] || 'blue'}.0`}>
                        <Group justify="space-between">
                          <Group gap="xs">
                            <Text fw={700} size="sm">{group.name}</Text>
                            <Badge color={YEAR_COLORS[group.year]} size="xs">BUT {group.year}</Badge>
                            <Text size="xs" c="dimmed">({assignedUsers.filter(u => u.group_id === group.id).length} étudiants)</Text>
                          </Group>
                          <Group gap={5} onClick={(e) => e.stopPropagation()}>
                            {group.name !== 'Enseignants' && (
                              <>
                                <ActionIcon size="xs" variant="subtle" color="blue" onClick={() => { setNewGroup(group); setIsGroupModalOpen(true); }}><IconPencil size={12} /></ActionIcon>
                                <ActionIcon size="xs" variant="subtle" color="red" onClick={() => deleteGroup(group.id)}><IconTrash size={12} /></ActionIcon>
                              </>
                            )}
                          </Group>
                        </Group>
                      </Accordion.Control>
                      <Accordion.Panel>
                        <Droppable droppableId={`group-${group.id}`}>
                          {(p, snapshot) => (
                            <div ref={p.innerRef} {...p.droppableProps} style={{ minHeight: 50, backgroundColor: snapshot.isDraggingOver ? '#e7f5ff' : 'transparent', padding: 10 }}>
                              <Stack gap={4}>
                                {assignedUsers.filter(u => u.group_id === group.id).map((u, index) => (
                                  <Draggable key={u.ldap_uid} draggableId={u.ldap_uid} index={index}>
                                    {(p2) => (
                                      <Paper withBorder p="xs" ref={p2.innerRef} {...p2.draggableProps} {...p2.dragHandleProps} bg="white">
                                        <Group justify="space-between">
                                          <div><Text size="xs" fw={500}>{u.full_name}</Text><Text size="10px" c="dimmed">{u.email}</Text></div>
                                          <Group gap={4}>
                                            <ActionIcon size="xs" color="teal" variant="subtle" onClick={() => setSelectedStudent(u)}><IconShieldCheck size={12} /></ActionIcon>
                                            <ActionIcon size="xs" color="red" variant="subtle" onClick={() => unassignUser(u.ldap_uid)}><IconTrash size={12} /></ActionIcon>
                                          </Group>
                                        </Group>
                                      </Paper>
                                    )}
                                  </Draggable>
                                ))}
                                {p.placeholder}
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
          
          <Modal opened={!!selectedStudent} onClose={() => setSelectedStudent(null)} title={`Options : ${selectedStudent?.full_name}`}>
            {selectedStudent && <ResponsibilitySelector entityId={selectedStudent.ldap_uid} entityType="STUDENT" professors={[]} onRefresh={fetchData} />}
          </Modal>
        </DragDropContext>
      ) : (
        <PedagogicalTeamManager />
      )}
    </Container>
  );
}
