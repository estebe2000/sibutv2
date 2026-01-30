import React, { useState, useEffect } from 'react';
import { Container, Paper, Title, Text, Stack, Group, Button, TextInput, Textarea, Badge, ActionIcon, Loader, Center, Card, Divider, Select, Modal, ThemeIcon } from '@mantine/core';
import { IconMessagePlus, IconThumbUp, IconBug, IconBulb, IconMessageDots, IconTrash, IconPlus, IconUser } from '@tabler/icons-react';
import api from '../services/api';
import { notifications } from '@mantine/notifications';
import { useDisclosure } from '@mantine/hooks';

export function FeedbackHubView() {
    const [feedbacks, setFeedbacks] = useState<any[]>([]);
    const [loading, setLoading] = useState(true);
    const [opened, { open, close }] = useDisclosure(false);
    const [newFeedback, setNewFeedback] = useState({ title: '', description: '', type: 'IDEA' });
    const [submitting, setSubmitting] = useState(false);

    useEffect(() => {
        fetchFeedbacks();
    }, []);

    const fetchFeedbacks = async () => {
        try {
            const res = await api.get('/feedback/');
            setFeedbacks(res.data);
        } catch (e) {}
        setLoading(false);
    };

    const handleCreate = async () => {
        if (!newFeedback.title || !newFeedback.description) return;
        setSubmitting(true);
        try {
            await api.post('/feedback/', newFeedback);
            notifications.show({ title: 'Merci !', message: 'Votre retour a été enregistré.', color: 'green' });
            setNewFeedback({ title: '', description: '', type: 'IDEA' });
            close();
            fetchFeedbacks();
        } catch (e) {}
        setSubmitting(false);
    };

    const handleVote = async (id: number) => {
        try {
            const res = await api.post(`/feedback/${id}/vote`);
            if (res.data.status === 'already_voted') {
                notifications.show({ message: 'Vous avez déjà soutenu cette demande.', color: 'orange' });
            } else {
                fetchFeedbacks();
            }
        } catch (e) {}
    };

    const getTypeIcon = (type: string) => {
        switch (type) {
            case 'BUG': return <IconBug size={16} color="red" />; 
            case 'IDEA': return <IconBulb size={16} color="yellow" />; 
            case 'REQUEST': return <IconMessageDots size={16} color="blue" />; 
            default: return null;
        }
    };

    if (loading) return <Center h="50vh"><Loader size="xl" /></Center>;

    return (
        <Container size="xl" py="md">
            <Stack gap="lg">
                <Paper withBorder p="md" radius="md" bg="yellow.0" shadow="xs">
                    <Group justify="space-between">
                        <Group>
                            <ThemeIcon color="yellow" size="lg" radius="md" variant="filled">
                                <IconMessagePlus size={24} />
                            </ThemeIcon>
                            <div>
                                <Title order={3}>Boîte à Idées & Retours Staff</Title>
                                <Text size="xs" c="dimmed">Partagez vos bugs, demandes ou idées pour améliorer Skills Hub.</Text>
                            </div>
                        </Group>
                        <Button leftSection={<IconPlus size={18}/>} color="yellow" onClick={open} variant="filled" c="black">Nouveau Retour</Button>
                    </Group>
                </Paper>

                <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(350px, 1fr))', gap: '20px' }}>
                    {feedbacks.map(fb => (
                        <Card key={fb.id} withBorder shadow="sm" radius="md" padding="lg">
                            <Group justify="space-between" mb="xs">
                                <Badge leftSection={getTypeIcon(fb.type)} variant="light" color={fb.type === 'BUG' ? 'red' : fb.type === 'IDEA' ? 'yellow' : 'blue'}>
                                    {fb.type}
                                </Badge>
                                <Text size="xs" c="dimmed">{new Date(fb.created_at).toLocaleDateString()}</Text>
                            </Group>

                            <Text fw={700} mb="xs">{fb.title}</Text>
                            <Text size="sm" c="dimmed" mb="md" style={{ flexGrow: 1 }}>{fb.description}</Text>

                            <Divider mb="sm" />

                            <Group justify="space-between">
                                <Group gap="xs">
                                    <ThemeIcon size="xs" variant="transparent" color="gray"><IconUser size={12} /></ThemeIcon>
                                    <Text size="xs" fw={500}>{fb.user_name}</Text>
                                </Group>
                                <Button 
                                    variant="light" 
                                    color="yellow" 
                                    size="xs" 
                                    leftSection={<IconThumbUp size={16} />}
                                    onClick={() => handleVote(fb.id)}
                                >
                                    {fb.votes}
                                </Button>
                            </Group>
                        </Card>
                    ))}
                </div>

                {feedbacks.length === 0 && (
                    <Paper withBorder p="xl" radius="md" ta="center">
                        <Text c="dimmed">Aucun retour pour le moment. Soyez le premier !</Text>
                    </Paper>
                )}
            </Stack>

            <Modal opened={opened} onClose={close} title="Partager un retour" centered>
                <Stack>
                    <Select 
                        label="Type de retour" 
                        data={[
                            { value: 'IDEA', label: '💡 Idée d\'amélioration' },
                            { value: 'BUG', label: '🪲 Signalement de Bug' },
                            { value: 'REQUEST', label: '💬 Demande spécifique' }
                        ]}
                        value={newFeedback.type}
                        onChange={(v) => setNewFeedback({...newFeedback, type: v || 'IDEA'})}
                    />
                    <TextInput 
                        label="Titre" 
                        placeholder="Ex: Ajouter un export Excel..." 
                        required 
                        value={newFeedback.title}
                        onChange={(e) => setNewFeedback({...newFeedback, title: e.target.value})}
                    />
                    <Textarea 
                        label="Description" 
                        placeholder="Détaillez votre pensée ou le problème rencontré..." 
                        required 
                        minRows={4}
                        value={newFeedback.description}
                        onChange={(e) => setNewFeedback({...newFeedback, description: e.target.value})}
                    />
                    <Button fullWidth onClick={handleCreate} loading={submitting} color="yellow" c="black">Publier mon retour</Button>
                </Stack>
            </Modal>
        </Container>
    );
}

