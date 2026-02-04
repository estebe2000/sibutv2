import React, { useState, useEffect } from 'react';
import { Container, Paper, Title, Text, Stack, Group, Badge, ActionIcon, Button, Select, TextInput, Loader, Accordion, Avatar } from '@mantine/core';
import { IconFile, IconEye, IconSearch, IconFilter, IconFolder, IconBriefcase, IconTarget, IconUser } from '@tabler/icons-react';
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

    // Grouping Logic
    const groupedFiles = files.reduce((acc: any, file: any) => {
        // Filter logic inside reducer
        const matchesSearch = file.filename.toLowerCase().includes(search.toLowerCase()) || file.student_uid.toLowerCase().includes(search.toLowerCase());
        const matchesType = typeFilter ? file.entity_type === typeFilter : true;

        if (!matchesSearch || !matchesType) return acc;

        if (!acc[file.student_uid]) {
            acc[file.student_uid] = { ACTIVITY: [], INTERNSHIP: [], PPP: [] };
        }
        
        // Group by Type
        const type = file.entity_type || 'ACTIVITY';
        if (!acc[file.student_uid][type]) acc[file.student_uid][type] = [];
        acc[file.student_uid][type].push(file);
        
        return acc;
    }, {});

    const getTypeIcon = (type: string) => {
        switch(type) {
            case 'INTERNSHIP': return <IconBriefcase size={16} />;
            case 'PPP': return <IconUser size={16} />;
            default: return <IconTarget size={16} />;
        }
    };

    const getTypeLabel = (type: string) => {
        switch(type) {
            case 'INTERNSHIP': return 'Stages';
            case 'PPP': return 'Projet Pro (PPP)';
            default: return 'SAÉ & Activités';
        }
    };

    return (
        <Container size="xl" py="md">
            <Stack gap="lg">
                <Group justify="space-between">
                    <Title order={3}>Médiathèque des Preuves</Title>
                    <Button onClick={loadFiles} variant="light" size="xs">Actualiser</Button>
                </Group>

                <Paper p="md" withBorder radius="md">
                    <Group mb="lg">
                        <TextInput 
                            placeholder="Rechercher un étudiant..." 
                            leftSection={<IconSearch size={14} />} 
                            value={search}
                            onChange={(e) => setSearch(e.currentTarget.value)}
                            style={{ flex: 1 }}
                        />
                        <Select 
                            placeholder="Type de preuve" 
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
                        <Accordion variant="separated" radius="md">
                            {Object.entries(groupedFiles).map(([studentUid, types]: [string, any]) => (
                                <Accordion.Item key={studentUid} value={studentUid}>
                                    <Accordion.Control icon={<Avatar color="blue" radius="xl">{studentUid.substring(0, 2).toUpperCase()}</Avatar>}>
                                        <Group justify="space-between" pr="md">
                                            <Text fw={500}>{studentUid}</Text>
                                            <Badge variant="light" color="gray">
                                                {Object.values(types).flat().length} fichiers
                                            </Badge>
                                        </Group>
                                    </Accordion.Control>
                                    <Accordion.Panel>
                                        <Stack gap="md">
                                            {Object.entries(types).map(([type, files]: [string, any]) => (
                                                files.length > 0 && (
                                                    <Paper key={type} withBorder p="sm" bg="gray.0">
                                                        <Group gap="xs" mb="xs">
                                                            {getTypeIcon(type)}
                                                            <Text size="sm" fw={700} tt="uppercase" c="dimmed">{getTypeLabel(type)}</Text>
                                                        </Group>
                                                        <Stack gap="xs">
                                                            {files.map((file: any) => (
                                                                <Group key={file.id} justify="space-between" wrap="nowrap">
                                                                    <Group gap="sm" wrap="nowrap" style={{ overflow: 'hidden' }}>
                                                                        <IconFile size={14} style={{ flexShrink: 0 }} />
                                                                        <Text size="sm" truncate>{file.filename}</Text>
                                                                    </Group>
                                                                    <Group gap="xs" wrap="nowrap">
                                                                        <Text size="xs" c="dimmed" style={{ whiteSpace: 'nowrap' }}>
                                                                            {dayjs(file.uploaded_at).format('DD/MM/YYYY')}
                                                                        </Text>
                                                                        <ActionIcon size="sm" variant="subtle" color="blue" onClick={() => handleView(file.id, file.filename)}>
                                                                            <IconEye size={14} />
                                                                        </ActionIcon>
                                                                    </Group>
                                                                </Group>
                                                            ))}
                                                        </Stack>
                                                    </Paper>
                                                )
                                            ))}
                                        </Stack>
                                    </Accordion.Panel>
                                </Accordion.Item>
                            ))}
                        </Accordion>
                    )}
                    
                    {Object.keys(groupedFiles).length === 0 && !loading && (
                        <Text c="dimmed" ta="center" py="xl">Aucun fichier trouvé</Text>
                    )}
                </Paper>
            </Stack>
        </Container>
    );
}
