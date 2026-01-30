import React, { useState, useEffect } from 'react';
import { Container, Paper, Title, Text, Group, Stack, Table, TextInput, Badge, Loader, Center, ActionIcon, Tabs } from '@mantine/core';
import { IconSearch, IconEye, IconSchool, IconUsers } from '@tabler/icons-react';
import api from '../services/api';

export function AdminPortfolioBrowserView() {
    const [students, setStudents] = useState<any[]>([]);
    const [groups, setGroups] = useState<any[]>([]);
    const [loading, setLoading] = useState(true);
    const [search, setSearch] = useState('');
    const [activeTab, setActiveTab] = useState<string | null>('1');

    useEffect(() => {
        const fetchData = async () => {
            try {
                const [usersRes, groupsRes] = await Promise.all([
                    api.get('/users?role=STUDENT'),
                    api.get('/groups')
                ]);
                setStudents(usersRes.data);
                setGroups(groupsRes.data);
            } catch (e) {
                console.error("Error fetching students", e);
            } finally {
                setLoading(false);
            }
        };
        fetchData();
    }, []);

    const getStudentYear = (groupId: number) => {
        const group = groups.find(g => g.id === groupId);
        return group ? group.year : 0;
    };

    const renderStudentTable = (year: number) => {
        const filtered = students
            .filter(s => {
                const sYear = getStudentYear(s.group_id);
                const matchesYear = sYear === year;
                const matchesSearch = s.full_name.toLowerCase().includes(search.toLowerCase()) || 
                                    s.ldap_uid.toLowerCase().includes(search.toLowerCase());
                return matchesYear && matchesSearch;
            })
            .sort((a, b) => a.full_name.localeCompare(b.full_name));

        return (
            <Table striped highlightOnHover mt="md">
                <Table.Thead>
                    <Table.Tr>
                        <Table.Th>Nom Complet</Table.Th>
                        <Table.Th>Identifiant</Table.Th>
                        <Table.Th>Email</Table.Th>
                        <Table.Th ta="right">Actions</Table.Th>
                    </Table.Tr>
                </Table.Thead>
                <Table.Tbody>
                    {filtered.map(student => (
                        <Table.Tr key={student.id}>
                            <Table.Td><Text fw={500} size="sm">{student.full_name}</Text></Table.Td>
                            <Table.Td><Badge variant="light" size="xs">{student.ldap_uid}</Badge></Table.Td>
                            <Table.Td><Text size="xs" c="dimmed">{student.email}</Text></Table.Td>
                            <Table.Td ta="right">
                                <ActionIcon variant="subtle" color="gray" disabled title="Voir le portfolio (Bientôt)">
                                    <IconEye size={18} />
                                </ActionIcon>
                            </Table.Td>
                        </Table.Tr>
                    ))}
                    {filtered.length === 0 && (
                        <Table.Tr>
                            <Table.Td colSpan={4} ta="center" py="xl">
                                <Text c="dimmed" size="sm">Aucun étudiant trouvé.</Text>
                            </Table.Td>
                        </Table.Tr>
                    )}
                </Table.Tbody>
            </Table>
        );
    };

    if (loading) return <Center h="50vh"><Loader size="xl" /></Center>;

    return (
        <Container size="xl" py="md">
            <Stack gap="lg">
                <Paper withBorder p="md" radius="md" bg="blue.0">
                    <Group justify="space-between">
                        <Group>
                            <IconUsers color="blue" />
                            <Title order={3}>Consultation des Portfolios</Title>
                        </Group>
                        <TextInput 
                            placeholder="Rechercher un étudiant..." 
                            leftSection={<IconSearch size={16}/>} 
                            value={search}
                            onChange={(e) => setSearch(e.target.value)}
                            style={{ width: 300 }}
                        />
                    </Group>
                </Paper>

                <Tabs value={activeTab} onChange={setActiveTab} color="blue" variant="outline">
                    <Tabs.List>
                        <Tabs.Tab value="1" leftSection={<IconSchool size={14} />}>BUT 1</Tabs.Tab>
                        <Tabs.Tab value="2" leftSection={<IconSchool size={14} />}>BUT 2</Tabs.Tab>
                        <Tabs.Tab value="3" leftSection={<IconSchool size={14} />}>BUT 3</Tabs.Tab>
                    </Tabs.List>

                    <Tabs.Panel value="1">{renderStudentTable(1)}</Tabs.Panel>
                    <Tabs.Panel value="2">{renderStudentTable(2)}</Tabs.Panel>
                    <Tabs.Panel value="3">{renderStudentTable(3)}</Tabs.Panel>
                </Tabs>
            </Stack>
        </Container>
    );
}
