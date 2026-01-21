import React, { useState, useEffect } from 'react';
import { Paper, Title, Text, Group, Stack, Button, Modal, TextInput, Select, Table, ActionIcon, Badge, ThemeIcon, Menu } from '@mantine/core';
import { IconUsers, IconPlus, IconTrash, IconEdit, IconDotsVertical, IconMapPin } from '@tabler/icons-react';
import api from '../services/api';
import { GROUP_NAMES_POOL } from '../data/groupNames';

interface Student {
    ldap_uid: string;
    full_name: string;
    email: string;
}

interface ActivityGroup {
    id: number;
    name: string;
    activity_id: number;
    students: Student[];
}

export function ActivityGroupManager({ activity, allStudents }: { activity: any, allStudents: Student[] }) {
    if (!activity) return null;

    const [groups, setGroups] = useState<ActivityGroup[]>([]);
    const [isRenameModalOpen, setIsRenameModalOpen] = useState(false);
    const [selectedGroup, setSelectedGroup] = useState<ActivityGroup | null>(null);
    const [newGroupName, setNewGroupName] = useState('');
    const [loading, setLoading] = useState(false);

    const fetchGroups = async () => {
        try {
            const res = await api.get(`/activity-management/${activity.id}/groups`);
            setGroups(Array.isArray(res.data) ? res.data : []);
        } catch (e) {
            console.error("Erreur chargement groupes", e);
            setGroups([]);
        }
    };

    useEffect(() => {
        fetchGroups();
    }, [activity.id]);

    const handleCreateGroup = async () => {
        setLoading(true);
        
        // Choisir un nom qui n'est pas déjà utilisé dans cette activité
        const existingNames = new Set(groups.map(g => g.name));
        const availableNames = GROUP_NAMES_POOL.filter(s => !existingNames.has(s));
        
        const randomName = availableNames.length > 0 
            ? availableNames[Math.floor(Math.random() * availableNames.length)]
            : `Groupe ${groups.length + 1}`;

        try {
            await api.post(`/activity-management/${activity.id}/groups?name=${encodeURIComponent(randomName)}`);
            fetchGroups();
        } catch (e) { console.error(e); }
        setLoading(false);
    };

    const handleRenameGroup = async () => {
        if (!selectedGroup || !newGroupName) return;
        setLoading(true);
        try {
            await api.patch(`/activity-management/groups/${selectedGroup.id}`, { name: newGroupName });
            setNewGroupName('');
            setSelectedGroup(null);
            setIsRenameModalOpen(false);
            fetchGroups();
        } catch (e) { console.error(e); }
        setLoading(false);
    };

    const handleDeleteGroup = async (groupId: number) => {
        if (!window.confirm("Supprimer ce groupe ?")) return;
        try {
            await api.delete(`/activity-management/groups/${groupId}`);
            fetchGroups();
        } catch (e) { console.error(e); }
    };

    const handleAddStudent = async (groupId: number, studentUid: string) => {
        setLoading(true);
        try {
            await api.post(`/activity-management/groups/${groupId}/students/${studentUid}`);
            await fetchGroups();
        } catch (e) { console.error(e); }
        setLoading(false);
    };

    const handleRemoveStudent = async (groupId: number, studentUid: string) => {
        try {
            await api.delete(`/activity-management/groups/${groupId}/students/${studentUid}`);
            await fetchGroups();
        } catch (e) { console.error(e); }
    };

    const assignedStudentUids = new Set((groups || []).flatMap(g => (g.students || []).map(s => s.ldap_uid)));
    const availableStudents = (allStudents || []).filter(s => s && s.ldap_uid && !assignedStudentUids.has(s.ldap_uid));

    return (
        <Stack gap="md">
            <Group justify="space-between">
                <div>
                    <Title order={4}>Groupes pour {activity.code}</Title>
                    <Text size="sm" c="dimmed">{activity.label}</Text>
                </div>
                <Button 
                    leftSection={<IconPlus size={16} />} 
                    onClick={handleCreateGroup} 
                    loading={loading}
                    variant="gradient"
                    gradient={{ from: 'blue', to: 'cyan' }}
                >
                    Nouveau groupe (Nom aléatoire)
                </Button>
            </Group>

            {groups.length === 0 ? (
                <Paper withBorder p="xl" ta="center" bg="gray.0" radius="md">
                    <Text c="dimmed">Aucun groupe créé. Cliquez sur le bouton ci-dessus pour commencer.</Text>
                </Paper>
            ) : (
                <Stack gap="sm">
                    {groups.map(group => (
                        <Paper key={group.id} withBorder p="md" radius="md" shadow="xs">
                            <Group justify="space-between" mb="sm">
                                <Group>
                                    <ThemeIcon variant="light" color="blue" radius="xl"><IconMapPin size={16}/></ThemeIcon>
                                    <Text fw={700} size="lg">{group.name}</Text>
                                    <Badge size="sm" variant="dot" color="blue">{group.students?.length || 0} membres</Badge>
                                </Group>
                                <Group gap="xs">
                                    <Select
                                        placeholder="Inscrire un étudiant..."
                                        data={availableStudents.map(s => ({ value: s.ldap_uid, label: s.full_name }))}
                                        searchable size="xs"
                                        onChange={(val) => val && handleAddStudent(group.id, val)}
                                        value={null}
                                        style={{ width: 220 }}
                                        disabled={loading}
                                    />
                                    <Menu shadow="md" width={200}>
                                        <Menu.Target>
                                            <ActionIcon variant="subtle" color="gray"><IconDotsVertical size={16}/></ActionIcon>
                                        </Menu.Target>
                                        <Menu.Dropdown>
                                            <Menu.Item 
                                                leftSection={<IconEdit size={14}/>} 
                                                onClick={() => { setSelectedGroup(group); setNewGroupName(group.name); setIsRenameModalOpen(true); }}
                                            >
                                                Renommer manuellement
                                            </Menu.Item>
                                            <Menu.Item 
                                                color="red" 
                                                leftSection={<IconTrash size={14}/>}
                                                onClick={() => handleDeleteGroup(group.id)}
                                            >
                                                Supprimer le groupe
                                            </Menu.Item>
                                        </Menu.Dropdown>
                                    </Menu>
                                </Group>
                            </Group>
                            
                            <Table verticalSpacing="xs">
                                <Table.Tbody>
                                    {(group.students || []).map(student => (
                                        <Table.Tr key={student.ldap_uid}>
                                            <Table.Td size="sm" fw={500}>{student.full_name}</Table.Td>
                                            <Table.Td size="sm" c="dimmed" visibleFrom="xs">{student.email}</Table.Td>
                                            <Table.Td ta="right">
                                                <ActionIcon color="red" variant="subtle" size="sm" onClick={() => handleRemoveStudent(group.id, student.ldap_uid)}>
                                                    <IconTrash size={14} />
                                                </ActionIcon>
                                            </Table.Td>
                                        </Table.Tr>
                                    ))}
                                </Table.Tbody>
                            </Table>
                        </Paper>
                    ))}
                </Stack>
            )}

            {/* Modal Renommer */}
            <Modal opened={isRenameModalOpen} onClose={() => setIsRenameModalOpen(false)} title="Renommer le groupe">
                <Stack>
                    <TextInput label="Nom personnalisé" value={newGroupName} onChange={(e) => setNewGroupName(e.currentTarget.value)} />
                    <Button onClick={handleRenameGroup} loading={loading}>Enregistrer</Button>
                </Stack>
            </Modal>
        </Stack>
    );
}
