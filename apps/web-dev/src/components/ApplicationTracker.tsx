import React, { useState, useEffect } from 'react';
import { Paper, Title, Text, Stack, Group, Badge, ActionIcon, Button, Modal, TextInput, Textarea, Loader, Card, useMantineTheme, Menu, Accordion } from '@mantine/core';
import { IconPlus, IconTrash, IconCalendar, IconExternalLink, IconDotsVertical, IconMessageDots, IconChevronRight, IconSelector } from '@tabler/icons-react';
import { DragDropContext, Droppable, Draggable } from '@hello-pangea/dnd';
import api from '../services/api';
import { notifications } from '@mantine/notifications';
import { useMediaQuery } from '@mantine/hooks';

const COLUMNS = [
    { id: 'APPLIED', title: 'Postulé / En attente', color: 'blue' },
    { id: 'INTERVIEW', title: 'Entretien', color: 'orange' },
    { id: 'REJECTED', title: 'Refusé', color: 'red' },
    { id: 'ACCEPTED', title: 'Accepté !', color: 'green' },
];

export function ApplicationTracker() {
    const isMobile = useMediaQuery('(max-width: 768px)');
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

    const updateStatus = async (app_id: number, new_status: string) => {
        const updatedApps = apps.map(a => a.id === app_id ? { ...a, status: new_status } : a);
        setApps(updatedApps);
        try {
            await api.patch(`/applications/${app_id}/`, { status: new_status });
        } catch (e) {
            notifications.show({ color: 'red', title: 'Erreur', message: 'Échec du changement de statut' });
            fetchApps();
        }
    };

    const onDragEnd = async (result: any) => {
        const { destination, source, draggableId } = result;
        if (!destination) return;
        if (destination.droppableId === source.droppableId && destination.index === source.index) return;
        updateStatus(parseInt(draggableId), destination.droppableId);
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

    const renderCard = (app: any, isDraggable = true) => (
        <Card withBorder shadow="xs" p="sm" radius="sm" bg="white">
            <Stack gap={5}>
                <Group justify="space-between" align="flex-start" wrap="nowrap">
                    <div style={{ flex: 1, minWidth: 0 }}>
                        <Text fw={700} size="sm" truncate>{app.company_name}</Text>
                        <Text size="xs" c="dimmed" truncate>{app.position_title}</Text>
                    </div>
                    <Group gap={5} wrap="nowrap">
                        {isMobile && (
                            <Menu shadow="md" width={200} position="bottom-end">
                                <Menu.Target>
                                    <ActionIcon variant="light" color="blue" size="sm">
                                        <IconSelector size={14} />
                                    </ActionIcon>
                                </Menu.Target>
                                <Menu.Dropdown>
                                    <Menu.Label>Changer le statut</Menu.Label>
                                    {COLUMNS.map(col => (
                                        <Menu.Item 
                                            key={col.id} 
                                            onClick={() => updateStatus(app.id, col.id)}
                                            disabled={app.status === col.id}
                                            leftSection={<div style={{ width: 10, height: 10, borderRadius: 5, backgroundColor: `var(--mantine-color-${col.color}-6)` }} />}
                                        >
                                            {col.title}
                                        </Menu.Item>
                                    ))}
                                    <Menu.Divider />
                                    <Menu.Item color="red" leftSection={<IconTrash size={14} />} onClick={() => handleDelete(app.id)}>
                                        Supprimer
                                    </Menu.Item>
                                </Menu.Dropdown>
                            </Menu>
                        )}
                        {!isMobile && (
                            <ActionIcon variant="subtle" color="red" size="sm" onClick={() => handleDelete(app.id)}>
                                <IconTrash size={14} />
                            </ActionIcon>
                        )}
                    </Group>
                </Group>
                
                {app.notes && (
                    <Text size="xs" c="dimmed" lineClamp={1} italic>
                        "{app.notes}"
                    </Text>
                )}

                {app.url && (
                    <Button component="a" href={app.url} target="_blank" variant="subtle" size="compact-xs" fullWidth justify="start" leftSection={<IconExternalLink size={12}/>}>
                        Lien de l'offre
                    </Button>
                )}
            </Stack>
        </Card>
    );

    if (loading) return <Loader />;

    return (
        <Stack gap="lg">
            <Group justify="space-between">
                <Title order={isMobile ? 5 : 4}>Suivi de mes candidatures</Title>
                <Button size={isMobile ? "xs" : "sm"} leftSection={<IconPlus size={16} />} onClick={() => setOpened(true)}>Ajouter</Button>
            </Group>

            {isMobile ? (
                <Accordion variant="separated" defaultValue="APPLIED">
                    {COLUMNS.map((col) => {
                        const colApps = apps.filter(a => a.status === col.id);
                        return (
                            <Accordion.Item key={col.id} value={col.id}>
                                <Accordion.Control 
                                    icon={<div style={{ width: 12, height: 12, borderRadius: 6, backgroundColor: `var(--mantine-color-${col.color}-6)` }} />}
                                >
                                    <Group justify="space-between" pr="md">
                                        <Text size="sm" fw={700} c={col.color}>{col.title}</Text>
                                        <Badge color={col.color} size="xs" variant="light">{colApps.length}</Badge>
                                    </Group>
                                </Accordion.Control>
                                <Accordion.Panel>
                                    <Stack gap="xs">
                                        {colApps.length === 0 ? (
                                            <Text size="xs" c="dimmed" ta="center" py="md">Aucune candidature</Text>
                                        ) : (
                                            colApps.map(app => renderCard(app, false))
                                        )}
                                    </Stack>
                                </Accordion.Panel>
                            </Accordion.Item>
                        );
                    })}
                </Accordion>
            ) : (
                <DragDropContext onDragEnd={onDragEnd}>
                    <Group align="flex-start" wrap="nowrap" style={{ overflowX: 'auto', paddingBottom: 20 }}>
                        {COLUMNS.map((col) => (
                            <Paper key={col.id} withBorder p="xs" radius="md" bg="gray.0" style={{ minWidth: 250, flex: 1 }}>
                                <Group justify="space-between" mb="sm">
                                    <Text fw={700} size="sm" tt="uppercase" c={col.color}>{col.title}</Text>
                                    <Badge color={col.color} variant="light">
                                        {apps.filter(a => a.status === col.id).length}
                                    </Badge>
                                </Group>

                                <Droppable droppableId={col.id}>
                                    {(provided) => (
                                        <Stack {...provided.droppableProps} ref={provided.innerRef} gap="xs" style={{ minHeight: 150 }}>
                                            {apps.filter(a => a.status === col.id).map((app, index) => (
                                                <Draggable key={app.id.toString()} draggableId={app.id.toString()} index={index}>
                                                    {(provided) => (
                                                        <div 
                                                            ref={provided.innerRef}
                                                            {...provided.draggableProps}
                                                            {...provided.dragHandleProps}
                                                        >
                                                            {renderCard(app)}
                                                        </div>
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
            )}

            <Modal opened={opened} onClose={() => setOpened(false)} title="Nouvelle candidature" size={isMobile ? "100%" : "md"}>
                <Stack>
                    <TextInput label="Entreprise" required placeholder="Ex: Google, PME Locale..." value={newApp.company_name} onChange={(e) => setNewApp({...newApp, company_name: e.target.value})} />
                    <TextInput label="Intitulé du poste" required placeholder="Ex: Alternant Marketing, Stage Vente..." value={newApp.position_title} onChange={(e) => setNewApp({...newApp, position_title: e.target.value})} />
                    <TextInput label="Lien de l'offre (URL)" placeholder="https://..." value={newApp.url} onChange={(e) => setNewApp({...newApp, url: e.target.value})} />
                    <Textarea label="Notes / Contact" placeholder="Nom du recruteur, date de relance..." minRows={3} value={newApp.notes} onChange={(e) => setNewApp({...newApp, notes: e.target.value})} />
                    <Button fullWidth onClick={handleAdd} size="md" mt="md">Enregistrer la candidature</Button>
                </Stack>
            </Modal>
        </Stack>
    );
}
