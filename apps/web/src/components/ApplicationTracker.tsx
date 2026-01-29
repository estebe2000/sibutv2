import React, { useState, useEffect } from 'react';
import { Paper, Title, Text, Stack, Group, Badge, ActionIcon, Button, Modal, TextInput, Textarea, Loader, Card, useMantineTheme } from '@mantine/core';
import { IconPlus, IconTrash, IconCalendar, IconExternalLink, IconDotsVertical, IconMessageDots } from '@tabler/icons-react';
import { DragDropContext, Droppable, Draggable } from '@hello-pangea/dnd';
import api from '../services/api';
import { notifications } from '@mantine/notifications';

const COLUMNS = [
    { id: 'APPLIED', title: 'Postulé / En attente', color: 'blue' },
    { id: 'INTERVIEW', title: 'Entretien', color: 'orange' },
    { id: 'REJECTED', title: 'Refusé', color: 'red' },
    { id: 'ACCEPTED', title: 'Accepté !', color: 'green' },
];

export function ApplicationTracker() {
    const [apps, setApps] = useState<any[]>([]);
    const [loading, setLoading] = useState(true);
    const [opened, setOpened] = useState(false);
    const [newApp, setNewApp] = useState({ company_name: '', position_title: '', url: '', notes: '' });

    const fetchApps = async () => {
        try {
            const res = await api.get('/applications/');
            setApps(res.data);
            setLoading(false);
        } catch (e) { console.error(e); }
    };

    useEffect(() => { fetchApps(); }, []);

    const onDragEnd = async (result: any) => {
        const { destination, source, draggableId } = result;
        if (!destination) return;
        if (destination.droppableId === source.droppableId && destination.index === source.index) return;

        const app_id = parseInt(draggableId);
        const new_status = destination.droppableId;

        // Optimistic UI update
        const updatedApps = apps.map(a => a.id === app_id ? { ...a, status: new_status } : a);
        setApps(updatedApps);

        try {
            await api.patch(`/applications/${app_id}/`, { status: new_status });
        } catch (e) {
            notifications.show({ color: 'red', title: 'Erreur', message: 'Échec du changement de statut' });
            fetchApps(); // Rollback
        }
    };

    const handleAdd = async () => {
        try {
            await api.post('/applications/', newApp);
            setOpened(false);
            setNewApp({ company_name: '', position_title: '', url: '', notes: '' });
            fetchApps();
            notifications.show({ color: 'green', title: 'Succès', message: 'Candidature ajoutée' });
        } catch (e) { console.error(e); }
    };

    const handleDelete = async (id: number) => {
        if (!window.confirm("Supprimer cette candidature ?")) return;
        try {
            await api.delete(`/applications/${id}/`);
            fetchApps();
        } catch (e) { console.error(e); }
    };

    if (loading) return <Loader />;

    return (
        <Stack gap="lg">
            <Group justify="space-between">
                <Title order={4}>Mon suivi de recherche</Title>
                <Button leftSection={<IconPlus size={16} />} onClick={() => setOpened(true)}>Ajouter</Button>
            </Group>

            <DragDropContext onDragEnd={onDragEnd}>
                <Group align="flex-start" wrap="nowrap" style={{ overflowX: 'auto', paddingBottom: 20 }}>
                    {COLUMNS.map((col) => (
                        <Paper key={col.id} withBorder p="xs" radius="md" bg="gray.0" style={{ minWidth: 280, flex: 1 }}>
                            <Group justify="space-between" mb="sm">
                                <Text fw={700} size="sm" tt="uppercase" c={col.color}>{col.title}</Text>
                                <Badge color={col.color} variant="light">
                                    {apps.filter(a => a.status === col.id).length}
                                </Badge>
                            </Group>

                            <Droppable droppableId={col.id}>
                                {(provided) => (
                                    <Stack {...provided.droppableProps} ref={provided.innerRef} gap="xs" style={{ minHeight: 100 }}>
                                        {apps.filter(a => a.status === col.id).map((app, index) => (
                                            <Draggable key={app.id.toString()} draggableId={app.id.toString()} index={index}>
                                                {(provided) => (
                                                    <Card 
                                                        withBorder 
                                                        shadow="xs" 
                                                        p="sm" 
                                                        radius="sm"
                                                        ref={provided.innerRef}
                                                        {...provided.draggableProps}
                                                        {...provided.dragHandleProps}
                                                        bg="white"
                                                    >
                                                        <Group justify="space-between" align="flex-start" wrap="nowrap">
                                                            <div>
                                                                <Text fw={700} size="sm">{app.company_name}</Text>
                                                                <Text size="xs" c="dimmed">{app.position_title}</Text>
                                                            </div>
                                                            <ActionIcon variant="subtle" color="red" size="sm" onClick={() => handleDelete(app.id)}>
                                                                <IconTrash size={14} />
                                                            </ActionIcon>
                                                        </Group>
                                                        {app.url && (
                                                            <Button component="a" href={app.url} target="_blank" variant="subtle" size="compact-xs" mt={5} leftSection={<IconExternalLink size={12}/>}>
                                                                Voir l'offre
                                                            </Button>
                                                        )}
                                                    </Card>
                                                )}
                                            </Draggable>
                                        ))}
                                        {provided.placeholder}
                                    </Stack>
                                )}
                            </Droppable>
                        </Paper>
                    ))}
                </Group>
            </DragDropContext>

            <Modal opened={opened} onClose={() => setOpened(false)} title="Nouvelle candidature">
                <Stack>
                    <TextInput label="Entreprise" required value={newApp.company_name} onChange={(e) => setNewApp({...newApp, company_name: e.target.value})} />
                    <TextInput label="Intitulé du poste" required value={newApp.position_title} onChange={(e) => setNewApp({...newApp, position_title: e.target.value})} />
                    <TextInput label="Lien de l'offre (URL)" value={newApp.url} onChange={(e) => setNewApp({...newApp, url: e.target.value})} />
                    <Textarea label="Notes / Contact" value={newApp.notes} onChange={(e) => setNewApp({...newApp, notes: e.target.value})} />
                    <Button onClick={handleAdd}>Enregistrer</Button>
                </Stack>
            </Modal>
        </Stack>
    );
}
