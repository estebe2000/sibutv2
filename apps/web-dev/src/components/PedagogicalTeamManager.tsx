import React, { useState, useEffect } from 'react';
import { Paper, Title, Text, Group, Stack, Table, Avatar, Badge, MultiSelect, Loader } from '@mantine/core';
import { IconSchool, IconCertificate } from '@tabler/icons-react';
import api from '../services/api';

export function PedagogicalTeamManager() {
    const [teachers, setTeachers] = useState<any[]>([]);
    const [groups, setGroups] = useState<any[]>([]);
    const [responsibilities, setResponsibilities] = useState<any[]>([]);
    const [loading, setLoading] = useState(true);

    const fetchData = async () => {
        setLoading(true);
        try {
            const [usersRes, groupsRes, respRes] = await Promise.all([
                api.get('/users'),
                api.get('/groups'),
                api.get('/pedagogy/promotion-responsibilities')
            ]);
            setTeachers(usersRes.data.filter((u: any) => ['PROFESSOR', 'ADMIN', 'SUPER_ADMIN'].includes(u.role)));
            setGroups(groupsRes.data.filter((g: any) => g.name !== "Enseignants"));
            setResponsibilities(respRes.data);
        } catch (e) { console.error(e); }
        setLoading(false);
    };

    useEffect(() => { fetchData(); }, []);

    const handleToggleResp = async (teacherUid: string, groupId: number, isSelected: boolean) => {
        try {
            if (isSelected) {
                await api.post(`/pedagogy/assign-promotion?teacher_uid=${teacherUid}&group_id=${groupId}`);
            } else {
                await api.delete(`/pedagogy/unassign-promotion?teacher_uid=${teacherUid}&group_id=${groupId}`);
            }
            fetchData();
        } catch (e) { console.error(e); }
    };

    if (loading) return <Loader />;

    return (
        <Paper withBorder p="md" radius="md" shadow="sm">
            <Title order={4} mb="lg">Gouvernance : Responsables de Promotion (Directeurs d'Étude)</Title>
            <Table verticalSpacing="sm">
                <Table.Thead>
                    <Table.Tr>
                        <Table.Th>Enseignant</Table.Th>
                        <Table.Th>Promotions sous responsabilité</Table.Th>
                    </Table.Tr>
                </Table.Thead>
                <Table.Tbody>
                    {teachers.map(t => {
                        const myResps = responsibilities.filter(r => r.teacher_uid === t.ldap_uid).map(r => r.group_id.toString());
                        return (
                            <Table.Tr key={t.ldap_uid}>
                                <Table.Td>
                                    <Group gap="sm">
                                        <Avatar radius="xl" color="blue">{t.full_name[0]}</Avatar>
                                        <div>
                                            <Text size="sm" fw={500}>{t.full_name}</Text>
                                            <Badge size="xs" variant="light">{t.role}</Badge>
                                        </div>
                                    </Group>
                                </Table.Td>
                                <Table.Td>
                                    <MultiSelect
                                        placeholder="Assigner des promotions..."
                                        data={groups.map(g => ({ value: g.id.toString(), label: `${g.name} (BUT ${g.year})` }))}
                                        value={myResps}
                                        onChange={(newValues) => {
                                            const added = newValues.filter(v => !myResps.includes(v));
                                            const removed = myResps.filter(v => !newValues.includes(v));
                                            if (added.length > 0) handleToggleResp(t.ldap_uid, parseInt(added[0]), true);
                                            if (removed.length > 0) handleToggleResp(t.ldap_uid, parseInt(removed[0]), false);
                                        }}
                                        searchable
                                        size="xs"
                                        leftSection={<IconSchool size={14} />}
                                    />
                                </Table.Td>
                            </Table.Tr>
                        );
                    })}
                </Table.Tbody>
            </Table>
        </Paper>
    );
}
