import React, { useState, useEffect } from 'react';
import { Paper, Title, Text, Group, Stack, Select, Table, Avatar, Badge, ActionIcon, Loader } from '@mantine/core';
import { IconUserStar, IconTrash, IconSearch } from '@tabler/icons-react';
import api from '../services/api';

export function TutorAssignmentManager() {
    const [students, setStudents] = useState<any[]>([]);
    const [teachers, setTeachers] = useState<any[]>([]);
    const [assignments, setAssignments] = useState<Record<string, any>>({});
    const [loading, setLoading] = useState(true);

    const fetchData = async () => {
        setLoading(true);
        try {
            const [usersRes] = await Promise.all([api.get('/users')]);
            const allUsers = usersRes.data;
            const stu = allUsers.filter((u: any) => u.role === 'STUDENT');
            const tea = allUsers.filter((u: any) => ['PROFESSOR', 'ADMIN', 'SUPER_ADMIN'].includes(u.role));
            
            setStudents(stu);
            setTeachers(tea);

            // Charger les tuteurs actuels pour chaque étudiant
            const tuteurs: Record<string, any> = {};
            await Promise.all(stu.map(async (s: any) => {
                try {
                    const res = await api.get(`/activity-management/student/${s.ldap_uid}/tutor`);
                    if (res.data) tuteurs[s.ldap_uid] = res.data;
                } catch(e) {}
            }));
            setAssignments(tuteurs);
        } catch (e) { console.error(e); }
        setLoading(false);
    };

    useEffect(() => { fetchData(); }, []);

    const handleAssign = async (studentUid: string, teacherUid: string) => {
        try {
            await api.post(`/activity-management/students/${studentUid}/tutor/${teacherUid}`);
            fetchData();
        } catch (e) { console.error(e); }
    };

    if (loading) return <Loader />;

    return (
        <Paper withBorder p="md" radius="md" shadow="sm">
            <Title order={4} mb="lg">Assignation des Tuteurs de Stage</Title>
            <Table verticalSpacing="sm">
                <Table.Thead>
                    <Table.Tr>
                        <Table.Th>Étudiant</Table.Th>
                        <Table.Th>Groupe / Parcours</Table.Th>
                        <Table.Th>Tuteur Enseignant</Table.Th>
                    </Table.Tr>
                </Table.Thead>
                <Table.Tbody>
                    {students.map(s => (
                        <Table.Tr key={s.ldap_uid}>
                            <Table.Td>
                                <Group gap="sm">
                                    <Avatar size="sm" radius="xl" color="blue">{s.full_name[0]}</Avatar>
                                    <div>
                                        <Text size="sm" fw={500}>{s.full_name}</Text>
                                        <Text size="xs" c="dimmed">{s.email}</Text>
                                    </div>
                                </Group>
                            </Table.Td>
                            <Table.Td>
                                <Badge size="xs" variant="light">{s.group?.name || 'N/A'}</Badge>
                            </Table.Td>
                            <Table.Td>
                                <Select
                                    placeholder="Choisir un tuteur..."
                                    data={teachers.map(t => ({ value: t.ldap_uid, label: t.full_name }))}
                                    value={assignments[s.ldap_uid]?.ldap_uid || null}
                                    onChange={(val) => val && handleAssign(s.ldap_uid, val)}
                                    searchable
                                    size="xs"
                                    leftSection={<IconUserStar size={14} />}
                                />
                            </Table.Td>
                        </Table.Tr>
                    ))}
                </Table.Tbody>
            </Table>
        </Paper>
    );
}
