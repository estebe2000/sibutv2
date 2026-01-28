import React, { useState, useEffect } from 'react';
import { Container, Paper, Title, Text, Stack, Group, TextInput, Table, Switch, ActionIcon, Modal, Button, Badge, Loader, Center } from '@mantine/core';
import { IconBriefcase, IconSearch, IconEdit, IconCheck, IconX, IconPhone, IconMail, IconWorld } from '@tabler/icons-react';
import api from '../services/api';
import { notifications } from '@mantine/notifications';

export function CompanyCodexView() {
    const [companies, setCompanies] = useState<any[]>([]);
    const [search, setSearch] = useState('');
    const [loading, setLoading] = useState(true);
    const [editingCompany, setEditingCompany] = useState<any | null>(null);
    const [stats, setStats] = useState<Record<number, number>>({});

    const fetchCompanies = async () => {
        setLoading(true);
        try {
            const res = await api.get(`/companies?search=${search}`);
            setCompanies(res.data);
            setLoading(false);
            
            // Fetch stats for each company
            res.data.forEach(async (c: any) => {
                const sRes = await api.get(`/companies/${c.id}/stats`);
                setStats(prev => ({ ...prev, [c.id]: sRes.data.total_interns }));
            });
        } catch (e) {
            console.error(e);
            setLoading(false);
        }
    };

    useEffect(() => {
        const timer = setTimeout(fetchCompanies, 300);
        return () => clearTimeout(timer);
    }, [search]);

    const handleToggleInterns = async (company: any) => {
        try {
            await api.patch(`/companies/${company.id}`, { accepts_interns: !company.accepts_interns });
            fetchCompanies();
        } catch (e) {
            notifications.show({ color: 'red', title: 'Erreur', message: 'Impossible de mettre à jour' });
        }
    };

    const handleSaveEdit = async () => {
        try {
            await api.patch(`/companies/${editingCompany.id}`, editingCompany);
            setEditingCompany(null);
            fetchCompanies();
            notifications.show({ color: 'green', title: 'Succès', message: 'Entreprise mise à jour' });
        } catch (e) {
            notifications.show({ color: 'red', title: 'Erreur', message: 'Impossible de sauvegarder' });
        }
    };

    return (
        <Container size="xl" py="md">
            <Stack gap="lg">
                <Paper withBorder p="md" radius="md" bg="blue.0">
                    <Group justify="space-between">
                        <Group>
                            <IconBriefcase color="#228be6" />
                            <Title order={3}>Codex Entreprises</Title>
                        </Group>
                        <TextInput 
                            placeholder="Rechercher une entreprise..." 
                            leftSection={<IconSearch size={16} />}
                            value={search}
                            onChange={(e) => setSearch(e.target.value)}
                            w={300}
                        />
                    </Group>
                </Paper>

                <Paper withBorder radius="md" p="md">
                    {loading ? (
                        <Center h={200}><Loader /></Center>
                    ) : (
                        <Table striped highlightOnHover verticalSpacing="sm">
                            <Table.Thead>
                                <Table.Tr>
                                    <Table.Th>Entreprise</Table.Th>
                                    <Table.Th>Coordonnées</Table.Th>
                                    <Table.Th>Stagiaires</Table.Th>
                                    <Table.Th>Statut</Table.Th>
                                    <Table.Th>Actions</Table.Th>
                                </Table.Tr>
                            </Table.Thead>
                            <Table.Tbody>
                                {companies.map((c) => (
                                    <Table.Tr key={c.id}>
                                        <Table.Td>
                                            <Text fw={700}>{c.name}</Text>
                                            <Text size="xs" c="dimmed">{c.address || 'Pas d\'adresse'}</Text>
                                        </Table.Td>
                                        <Table.Td>
                                            <Stack gap={2}>
                                                {c.email && <Group gap={5}><IconMail size={12} /><Text size="xs">{c.email}</Text></Group>}
                                                {c.phone && <Group gap={5}><IconPhone size={12} /><Text size="xs">{c.phone}</Text></Group>}
                                                {c.website && <Group gap={5}><IconWorld size={12} /><Text size="xs">{c.website}</Text></Group>}
                                            </Stack>
                                        </Table.Td>
                                        <Table.Td>
                                            <Badge color="blue" variant="light">{stats[c.id] || 0} stagiaires</Badge>
                                        </Table.Td>
                                        <Table.Td>
                                            <Switch 
                                                label={c.accepts_interns ? "Accepte" : "N'accepte plus"}
                                                checked={c.accepts_interns}
                                                onChange={() => handleToggleInterns(c)}
                                                size="xs"
                                                color="green"
                                            />
                                        </Table.Td>
                                        <Table.Td>
                                            <ActionIcon variant="subtle" onClick={() => setEditingCompany(c)}>
                                                <IconEdit size={18} />
                                            </ActionIcon>
                                        </Table.Td>
                                    </Table.Tr>
                                ))}
                            </Table.Tbody>
                        </Table>
                    )}
                </Paper>
            </Stack>

            <Modal opened={!!editingCompany} onClose={() => setEditingCompany(null)} title="Modifier l'entreprise" size="lg">
                {editingCompany && (
                    <Stack>
                        <TextInput label="Nom" value={editingCompany.name} onChange={(e) => setEditingCompany({...editingCompany, name: e.target.value})} />
                        <TextInput label="Adresse" value={editingCompany.address || ''} onChange={(e) => setEditingCompany({...editingCompany, address: e.target.value})} />
                        <Group grow>
                            <TextInput label="Email" value={editingCompany.email || ''} onChange={(e) => setEditingCompany({...editingCompany, email: e.target.value})} />
                            <TextInput label="Téléphone" value={editingCompany.phone || ''} onChange={(e) => setEditingCompany({...editingCompany, phone: e.target.value})} />
                        </Group>
                        <TextInput label="Site Web" value={editingCompany.website || ''} onChange={(e) => setEditingCompany({...editingCompany, website: e.target.value})} />
                        <Group justify="flex-end" mt="md">
                            <Button variant="default" onClick={() => setEditingCompany(null)}>Annuler</Button>
                            <Button onClick={handleSaveEdit}>Enregistrer</Button>
                        </Group>
                    </Stack>
                )}
            </Modal>
        </Container>
    );
}
