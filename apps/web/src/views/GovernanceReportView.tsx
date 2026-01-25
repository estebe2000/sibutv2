import React, { useState, useEffect } from 'react';
import { Container, Paper, Title, Text, Stack, Group, Table, Button, Loader, Center, Badge, ActionIcon, TextInput } from '@mantine/core';
import { IconFileSpreadsheet, IconDownload, IconSearch, IconShieldLock, IconBook, IconSchool, IconUsers } from '@tabler/icons-react';
import { Tabs } from '@mantine/core';
import api from '../services/api';

export function GovernanceReportView() {
    const [data, setData] = useState<any[]>([]);
    const [loading, setLoading] = useState(true);
    const [search, setSearch] = useState('');
    const [activeTab, setActiveTab] = useState<string | null>('RESOURCE');

    useEffect(() => {
        fetchData();
    }, []);

    const fetchData = async () => {
        try {
            const res = await api.get('/pedagogy/governance-report');
            setData(res.data);
            setLoading(false);
        } catch (e) { console.error(e); setLoading(false); }
    };

    const renderTable = (type: string) => {
        const filtered = data.filter(item => 
            item.entity_type === type &&
            (item.user_name.toLowerCase().includes(search.toLowerCase()) || 
             item.entity_label.toLowerCase().includes(search.toLowerCase()) ||
             item.entity_id.toLowerCase().includes(search.toLowerCase()))
        ).sort((a, b) => a.entity_label.localeCompare(b.entity_label));

        return (
            <Stack gap="md" mt="md">
import { IconFileSpreadsheet, IconDownload, IconSearch, IconShieldLock, IconBook, IconSchool, IconUsers, IconDatabase, IconTable } from '@tabler/icons-react';
import { Tabs, Menu } from '@mantine/core';
--
                <Group justify="space-between">
                    <Text size="sm" c="dimmed">{filtered.length} élément(s) trouvé(s)</Text>
                    <Group>
                        <Menu shadow="md" width={200}>
                            <Menu.Target>
                                <Button variant="outline" color="blue" size="xs" leftSection={<IconDownload size={14}/>}>Exporter les données</Button>
                            </Menu.Target>
                            <Menu.Dropdown>
                                <Menu.Label>Format de fichier</Menu.Label>
                                <Menu.Item 
                                    leftSection={<IconFileSpreadsheet size={14} />} 
                                    component="a" 
                                    href={`/api/pedagogy/governance-report/export/csv?type=${type}`}
                                >
                                    Fichier CSV (Excel)
                                </Menu.Item>
                                <Menu.Item 
                                    leftSection={<IconDatabase size={14} />} 
                                    component="a" 
                                    href={`/api/pedagogy/governance-report/export/json?type=${type}`}
                                >
                                    Fichier JSON
                                </Menu.Item>
                            </Menu.Dropdown>
                        </Menu>

                        <Button 
                            color="red" 
                            size="xs"
                            leftSection={<IconDownload size={14}/>}
                            component="a"
                            href={`/api/pedagogy/governance-report/pdf?type=${type}`}
                            target="_blank"
                        >
                            Exporter Rapport PDF
                        </Button>
                    </Group>
                </Group>
                <Paper withBorder p="md" radius="md">
                    <Table striped highlightOnHover>
                        <Table.Thead>
                            <Table.Tr>
                                <Table.Th>Entité (Code/ID)</Table.Th>
                                <Table.Th>Rôle</Table.Th>
                                <Table.Th>Enseignant</Table.Th>
                                <Table.Th>Email</Table.Th>
                            </Table.Tr>
                        </Table.Thead>
                        <Table.Tbody>
                            {filtered.map((item, i) => (
                                <Table.Tr key={i}>
                                    <Table.Td><Text fw={700} size="sm">{item.entity_label}</Text></Table.Td>
                                    <Table.Td>
                                        <Badge color={item.role === 'OWNER' ? 'blue' : 'gray'} size="xs">
                                            {item.role === 'OWNER' ? 'Responsable' : item.role === 'TUTOR' ? 'Tuteur' : 'Intervenant'}
                                        </Badge>
                                    </Table.Td>
                                    <Table.Td><Text size="sm">{item.user_name}</Text></Table.Td>
                                    <Table.Td><Text size="xs" c="dimmed">{item.user_email}</Text></Table.Td>
                                </Table.Tr>
                            ))}
                            {filtered.length === 0 && (
                                <Table.Tr><Table.Td colSpan={4} ta="center">Aucune donnée.</Table.Td></Table.Tr>
                            )}
                        </Table.Tbody>
                    </Table>
                </Paper>
            </Stack>
        );
    };

    if (loading) return <Center h="50vh"><Loader /></Center>;

    return (
        <Container size="xl" py="md">
            <Stack gap="lg">
                <Paper withBorder p="md" radius="md" bg="indigo.0">
                    <Group justify="space-between">
                        <Group>
                            <IconShieldLock color="indigo" />
                            <Title order={3}>Gouvernance du Département</Title>
                        </Group>
                        <TextInput 
                            placeholder="Rechercher..." 
                            leftSection={<IconSearch size={16}/>} 
                            value={search}
                            onChange={(e) => setSearch(e.target.value)}
                            style={{ width: 300 }}
                        />
                    </Group>
                </Paper>

                <Tabs value={activeTab} onChange={setActiveTab} variant="outline" color="indigo">
                    <Tabs.List>
                        <Tabs.Tab value="RESOURCE" leftSection={<IconBook size={16} />}>Ressources (R)</Tabs.Tab>
                        <Tabs.Tab value="ACTIVITY" leftSection={<IconSchool size={16} />}>SAÉ et Activités</Tabs.Tab>
                        <Tabs.Tab value="STUDENT" leftSection={<IconUsers size={16} />}>Tutorat de Stage</Tabs.Tab>
                    </Tabs.List>

                    <Tabs.Panel value="RESOURCE">{renderTable('RESOURCE')}</Tabs.Panel>
                    <Tabs.Panel value="ACTIVITY">{renderTable('ACTIVITY')}</Tabs.Panel>
                    <Tabs.Panel value="STUDENT">{renderTable('STUDENT')}</Tabs.Panel>
                </Tabs>
            </Stack>
        </Container>
    );
}
