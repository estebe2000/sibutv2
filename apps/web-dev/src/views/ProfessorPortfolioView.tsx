import React, { useState, useEffect } from 'react';
import { Container, Paper, Title, Text, Stack, Group, Table, Badge, ActionIcon, Button, Select, TextInput, Loader } from '@mantine/core';
import { IconFile, IconEye, IconDownload, IconSearch, IconFilter } from '@tabler/icons-react';
import api from '../services/api';
import dayjs from 'dayjs';

export function ProfessorPortfolioView() {
    const [files, setFiles] = useState<any[]>([]);
    const [loading, setLoading] = useState(true);
    const [search, setSearch] = useState('');
    const [typeFilter, setTypeFilter] = useState<string | null>(null);

    useEffect(() => {
        loadFiles();
    }, []);

    const loadFiles = async () => {
        setLoading(true);
        try {
            const res = await api.get('/portfolio/files/all');
            setFiles(res.data);
        } catch (error) {
            console.error(error);
        } finally {
            setLoading(false);
        }
    };

    const handleView = async (fileId: number, filename: string) => {
        try {
            setLoading(true);
            // On demande un lien magique Nextcloud
            const response = await api.get(`/portfolio/share-link/${fileId}`);
            
            if (response.data && response.data.url) {
                window.open(response.data.url, '_blank');
            } else {
                alert("Impossible de générer le lien de visualisation.");
            }
        } catch (error) {
            console.error("Erreur de lien", error);
            alert("Erreur lors de l'accès à Nextcloud.");
        } finally {
            setLoading(false);
        }
    };

    const filteredFiles = files.filter(f => {
        const matchesSearch = f.filename.toLowerCase().includes(search.toLowerCase()) || f.student_uid.toLowerCase().includes(search.toLowerCase());
        const matchesType = typeFilter ? f.entity_type === typeFilter : true;
        return matchesSearch && matchesType;
    });

    return (
        <Container size="xl" py="md">
            <Stack gap="lg">
                <Group justify="space-between">
                    <Title order={3}>Médiathèque des Preuves</Title>
                    <Button onClick={loadFiles} variant="light" size="xs">Actualiser</Button>
                </Group>

                <Paper p="md" withBorder radius="md">
                    <Group mb="md">
                        <TextInput 
                            placeholder="Rechercher étudiant ou fichier..." 
                            leftSection={<IconSearch size={14} />} 
                            value={search}
                            onChange={(e) => setSearch(e.currentTarget.value)}
                            style={{ flex: 1 }}
                        />
                        <Select 
                            placeholder="Type" 
                            data={[{ value: 'ACTIVITY', label: 'SAÉ' }, { value: 'INTERNSHIP', label: 'Stage' }, { value: 'PPP', label: 'PPP' }]}
                            value={typeFilter}
                            onChange={setTypeFilter}
                            clearable
                            leftSection={<IconFilter size={14} />}
                        />
                    </Group>

                    {loading ? (
                        <Group justify="center" p="xl"><Loader /></Group>
                    ) : (
                        <Table striped highlightOnHover>
                            <Table.Thead>
                                <Table.Tr>
                                    <Table.Th>Étudiant</Table.Th>
                                    <Table.Th>Fichier</Table.Th>
                                    <Table.Th>Type</Table.Th>
                                    <Table.Th>Date</Table.Th>
                                    <Table.Th>Action</Table.Th>
                                </Table.Tr>
                            </Table.Thead>
                            <Table.Tbody>
                                {filteredFiles.map((file) => (
                                    <Table.Tr key={file.id}>
                                        <Table.Td><Badge variant="dot" color="blue">{file.student_uid}</Badge></Table.Td>
                                        <Table.Td>
                                            <Group gap="xs">
                                                <IconFile size={14} color="gray" />
                                                <Text size="sm">{file.filename}</Text>
                                            </Group>
                                        </Table.Td>
                                        <Table.Td>
                                            <Badge color={file.entity_type === 'INTERNSHIP' ? 'orange' : 'violet'} size="sm" variant="light">
                                                {file.entity_type}
                                            </Badge>
                                        </Table.Td>
                                        <Table.Td><Text size="xs" c="dimmed">{dayjs(file.uploaded_at).format('DD/MM/YYYY HH:mm')}</Text></Table.Td>
                                        <Table.Td>
                                            <ActionIcon variant="subtle" color="blue" onClick={() => handleView(file.id, file.filename)}>
                                                <IconEye size={16} />
                                            </ActionIcon>
                                        </Table.Td>
                                    </Table.Tr>
                                ))}
                            </Table.Tbody>
                        </Table>
                    )}
                </Paper>
            </Stack>
        </Container>
    );
}
