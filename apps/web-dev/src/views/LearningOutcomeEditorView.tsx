import React, { useState, useEffect } from 'react';
import { 
    Container, Paper, Title, Text, Group, Stack, TextInput, 
    Textarea, Button, Table, Badge, ActionIcon, Modal, 
    ScrollArea, Select, Loader, Box
} from '@mantine/core';
import * as TablerIcons from '@tabler/icons-react';
import { notifications } from '@mantine/notifications';
import api from '../services/api';

export function LearningOutcomeEditorView() {
    // On utilise les alias pour les icones
    const IconPencil = TablerIcons.IconPencil;
    const IconSearch = TablerIcons.IconSearch;
    const IconDeviceFloppy = TablerIcons.IconDeviceFloppy;
    const IconInfoCircle = TablerIcons.IconInfoCircle;
    const [competencies, setCompetencies] = useState<any[]>([]);
    const [loading, setLoading] = useState(true);
    const [search, setSearch] = useState('');
    const [selectedLO, setSelectedLO] = useState<any>(null);
    const [isEditModalOpen, setIsGroupModalOpen] = useState(false);
    const [editData, setEditData] = useState({ label: '', description: '' });

    const fetchData = async () => {
        setLoading(true);
        try {
            const res = await api.get('/competencies');
            setCompetencies(res.data);
        } catch (e) {
            notifications.show({ color: 'red', title: 'Erreur', message: 'Impossible de charger le référentiel' });
        }
        setLoading(false);
    };

    useEffect(() => { fetchData(); }, []);

    const allLOs = competencies.flatMap(c => 
        c.learning_outcomes.map((lo: any) => ({
            ...lo,
            compCode: c.code,
            compLabel: c.label
        }))
    );

    const filteredLOs = allLOs.filter(lo => 
        lo.code.toLowerCase().includes(search.toLowerCase()) || 
        lo.label.toLowerCase().includes(search.toLowerCase())
    );

    const handleEdit = (lo: any) => {
        setSelectedLO(lo);
        setEditData({ label: lo.label, description: lo.description || '' });
        setIsGroupModalOpen(true);
    };

    const handleSave = async () => {
        try {
            await api.patch(`/learning-outcomes/${selectedLO.id}`, editData);
            notifications.show({ color: 'green', title: 'Succès', message: 'Apprentissage critique mis à jour' });
            setIsGroupModalOpen(false);
            fetchData();
        } catch (e) {
            notifications.show({ color: 'red', title: 'Erreur', message: 'Échec de la sauvegarde' });
        }
    };

    if (loading) return <Container p="xl"><Loader size="xl" /></Container>;

    return (
        <Container size="xl" py="xl">
            <Stack gap="lg">
                <Group justify="space-between">
                    <div>
                        <Title order={2}>Éditeur du Référentiel (AC)</Title>
                        <Text c="dimmed">Affinez les intitulés et descriptifs pédagogiques des Apprentissages Critiques.</Text>
                    </div>
                    <TextInput 
                        placeholder="Rechercher un code ou un nom..." 
                        leftSection={<IconSearch size={16} />}
                        value={search}
                        onChange={(e) => setSearch(e.target.value)}
                        w={300}
                    />
                </Group>

                <Paper withBorder radius="md">
                    <ScrollArea h="calc(100vh - 250px)">
                        <Table verticalSpacing="sm" highlightOnHover>
                            <Table.Thead bg="gray.0">
                                <Table.Tr>
                                    <Table.Th w={120}>Code</Table.Th>
                                    <Table.Th w={150}>Compétence</Table.Th>
                                    <Table.Th>Intitulé Pédagogique</Table.Th>
                                    <Table.Th w={100}>Niveau</Table.Th>
                                    <Table.Th w={80}>Actions</Table.Th>
                                </Table.Tr>
                            </Table.Thead>
                            <Table.Tbody>
                                {filteredLOs.map((lo) => (
                                    <Table.Tr key={lo.id}>
                                        <Table.Td><Badge variant="outline" color="blue">{lo.code}</Badge></Table.Td>
                                        <Table.Td>
                                            <Text size="xs" fw={700}>{lo.compCode}</Text>
                                            <Text size="10px" c="dimmed" lineClamp={1}>{lo.compLabel}</Text>
                                        </Table.Td>
                                        <Table.Td>
                                            <Text size="sm" fw={500}>{lo.label}</Text>
                                            <Text size="xs" c="dimmed" lineClamp={1}>{lo.description || 'Aucune description'}</Text>
                                        </Table.Td>
                                        <Table.Td><Badge size="xs" color="gray">BUT {lo.level}</Badge></Table.Td>
                                        <Table.Td>
                                            <ActionIcon variant="subtle" color="blue" onClick={() => handleEdit(lo)}>
                                                <IconPencil size={18} />
                                            </ActionIcon>
                                        </Table.Td>
                                    </Table.Tr>
                                ))}
                            </Table.Tbody>
                        </Table>
                    </ScrollArea>
                </Paper>
            </Stack>

            <Modal 
                opened={isEditModalOpen} 
                onClose={() => setIsGroupModalOpen(false)} 
                title={`Modifier ${selectedLO?.code}`}
                size="xl"
            >
                <Stack gap="md">
                    <TextInput 
                        label="Intitulé de l'Apprentissage Critique"
                        value={editData.label}
                        onChange={(e) => setEditData({...editData, label: e.target.value})}
                        required
                    />
                    <Textarea 
                        label="Description Pédagogique"
                        description="Ce texte apparaîtra dans les détails des fiches PDF. Vous pouvez utiliser le formatage type Markdown."
                        placeholder="Au niveau X, l'étudiant doit être capable de... ### Ressources mobilisées... ### Critères d'évaluation..."
                        value={editData.description}
                        onChange={(e) => setEditData({...editData, description: e.target.value})}
                        minRows={10}
                        autosize
                    />
                    <Group justify="flex-end" mt="md">
                        <Button variant="default" onClick={() => setIsGroupModalOpen(false)}>Annuler</Button>
                        <Button leftSection={<IconDeviceFloppy size={18} />} onClick={handleSave}>Enregistrer</Button>
                    </Group>
                </Stack>
            </Modal>
        </Container>
    );
}
