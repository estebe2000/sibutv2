import React, { useState, useEffect } from 'react';
import { Paper, Title, Text, Group, Stack, Button, TextInput, NumberInput, Table, ActionIcon, Badge, Divider, Card, Grid, ThemeIcon, Modal, Loader, Center } from '@mantine/core';
import { IconPlus, IconTrash, IconCheck, IconTargetArrow, IconEdit, IconChevronLeft, IconChartBar } from '@tabler/icons-react';
import api from '../services/api';
import { notifications } from '@mantine/notifications';
import { RubricSimulator } from './RubricSimulator';

export function RubricBuilder({ activity }: { activity: any }) {
    const [rubrics, setRubrics] = useState<any[]>([]);
    const [selectedRubricId, setSelectedRubricId] = useState<number | null>(null);
    const [isSimulating, setIsSimulating] = useState(false);
    const [isCreating, setIsCreating] = useState(false);
    const [isRenaming, setIsRenaming] = useState(false);
    const [rubricName, setRubricName] = useState('');
    const [loading, setLoading] = useState(false);

    const fetchRubrics = async () => {
        setLoading(true);
        try {
            const res = await api.get(`/evaluation-builder/${activity.id}/rubrics`);
            setRubrics(Array.isArray(res.data) ? res.data : []);
        } catch (e) { console.error(e); }
        setLoading(false);
    };

    useEffect(() => { fetchRubrics(); }, [activity.id]);

    const handleCreateRubric = async () => {
        if (!rubricName.trim()) return;
        setLoading(true);
        try {
            const res = await api.post(`/evaluation-builder/${activity.id}/rubrics?name=${encodeURIComponent(rubricName)}`);
            await fetchRubrics();
            setSelectedRubricId(res.data.id);
            setIsCreating(false);
            setRubricName('');
        } catch (e) { console.error(e); }
        setLoading(false);
    };

    const handleRenameRubric = async () => {
        if (!selectedRubricId || !rubricName.trim()) return;
        setLoading(true);
        try {
            await api.patch(`/evaluation-builder/rubrics/${selectedRubricId}`, { name: rubricName });
            await fetchRubrics();
            setIsRenaming(false);
            notifications.show({ title: 'Grille renommée', color: 'green' });
        } catch (e) { console.error(e); }
        setLoading(false);
    };

    const handleDeleteRubric = async (id: number) => {
        if (!window.confirm("Supprimer définitivement cette grille ?")) return;
        try {
            await api.delete(`/evaluation-builder/rubrics/${id}`);
            if (selectedRubricId === id) setSelectedRubricId(null);
            fetchRubrics();
        } catch (e) { console.error(e); }
    };

    const handleAddCriterion = async (label: string, weight: number, acId?: number) => {
        if (!selectedRubricId) return;
        setLoading(true);
        try {
            await api.post(`/evaluation-builder/rubrics/${selectedRubricId}/criteria`, {
                label,
                weight,
                ac_id: acId
            });
            await fetchRubrics();
            notifications.show({ title: 'Critère ajouté', color: 'teal', message: label });
        } catch (e) { console.error(e); }
        setLoading(false);
    };

    const handleUpdateCriterion = async (id: number, weight: number) => {
        try {
            await api.patch(`/evaluation-builder/criteria/${id}`, { weight });
            fetchRubrics();
        } catch (e) { console.error(e); }
    };

    const handleDeleteCriterion = async (id: number) => {
        try {
            await api.delete(`/evaluation-builder/criteria/${id}`);
            fetchRubrics();
        } catch (e) { console.error(e); }
    };

    const activeRubric = rubrics.find(r => r.id === selectedRubricId);
    const totalWeight = activeRubric?.criteria?.reduce((acc: number, c: any) => acc + (c.weight || 0), 0) || 0;

    if (isSimulating && activeRubric) {
        return <RubricSimulator rubric={activeRubric} activity={activity} onBack={() => setIsSimulating(false)} />;
    }

    return (
        <Stack gap="lg">
            {!activeRubric ? (
                <Stack>
                    <Group justify="space-between">
                        <Title order={4}>Grilles d'évaluation : {activity.code}</Title>
                        <Button leftSection={<IconPlus size={16}/>} onClick={() => { setRubricName('Nouvelle Grille'); setIsCreating(true); }}>Créer une grille</Button>
                    </Group>
                    
                    {isCreating && (
                        <Paper withBorder p="md" shadow="xs">
                            <Group align="flex-end">
                                <TextInput label="Nom de la grille" style={{flexGrow: 1}} value={rubricName} onChange={(e) => setRubricName(e.target.value)} />
                                <Button onClick={handleCreateRubric} loading={loading}>Valider</Button>
                                <Button variant="subtle" color="gray" onClick={() => setIsCreating(false)}>Annuler</Button>
                            </Group>
                        </Paper>
                    )}

                    {rubrics.length === 0 && !isCreating && (
                        <Paper withBorder p="xl" ta="center" bg="gray.0" radius="md">
                            <Text c="dimmed">Aucune grille définie.</Text>
                        </Paper>
                    )}

                    {rubrics.map(r => (
                        <Card key={r.id} withBorder shadow="xs" padding="md">
                            <Group justify="space-between">
                                <Group>
                                    <ThemeIcon variant="light" color="teal" size="lg"><IconTargetArrow size={20}/></ThemeIcon>
                                    <div>
                                        <Text fw={700}>{r.name}</Text>
                                        <Text size="xs" c="dimmed">{r.criteria?.length || 0} critères - Total {r.total_points} pts</Text>
                                    </div>
                                </Group>
                                <Group>
                                    <Button variant="light" size="xs" onClick={() => setSelectedRubricId(r.id)}>Éditer structure</Button>
                                    <Button variant="light" color="blue" size="xs" leftSection={<IconChartBar size={14}/>} onClick={() => { setSelectedRubricId(r.id); setIsSimulating(true); }}>Simulation</Button>
                                    <ActionIcon color="red" variant="subtle" onClick={() => handleDeleteRubric(r.id)}><IconTrash size={16} /></ActionIcon>
                                </Group>
                            </Group>
                        </Card>
                    ))}
                </Stack>
            ) : (
                <Stack>
                    <Group justify="space-between">
                        <Button variant="subtle" size="xs" leftSection={<IconChevronLeft size={16}/>} onClick={() => setSelectedRubricId(null)}>Liste des grilles</Button>
                        <Group gap="xs">
                            <Title order={4}>{activeRubric.name}</Title>
                            <ActionIcon variant="subtle" size="sm" onClick={() => { setRubricName(activeRubric.name); setIsRenaming(true); }}><IconEdit size={14}/></ActionIcon>
                        </Group>
                        <Group>
                            <Button size="xs" leftSection={<IconChartBar size={14}/>} color="blue" onClick={() => setIsSimulating(true)}>Lancer Simulation</Button>
                            <Badge size="xl" variant="filled" color="blue">Total actuel : {totalWeight} pts</Badge>
                        </Group>
                    </Group>

                    <Grid gutter="xl">
                        <Grid.Col span={{ base: 12, md: 7 }}>
                            <Paper withBorder p="md" radius="md">
                                <Title order={5} mb="md">Contenu de la grille</Title>
                                <Table verticalSpacing="xs">
                                    <Table.Thead>
                                        <Table.Tr><Table.Th>Critère</Table.Th><Table.Th style={{width: 80}}>Pts</Table.Th><Table.Th style={{width: 40}}></Table.Th></Table.Tr>
                                    </Table.Thead>
                                    <Table.Tbody>
                                        {(activeRubric.criteria || []).map((c: any) => (
                                            <Table.Tr key={c.id}>
                                                <Table.Td>
                                                    <Group gap="xs">
                                                        {c.ac_id && <Badge size="xs" color="teal">AC</Badge>}
                                                        <Text size="sm">{c.label}</Text>
                                                    </Group>
                                                </Table.Td>
                                                <Table.Td>
                                                    <NumberInput 
                                                        size="xs" 
                                                        value={c.weight} 
                                                        onChange={(v) => handleUpdateCriterion(c.id, Number(v))} 
                                                        min={0}
                                                        step={0.5}
                                                        style={{ width: 70 }}
                                                    />
                                                </Table.Td>
                                                <Table.Td>
                                                    <ActionIcon color="red" variant="subtle" onClick={() => handleDeleteCriterion(c.id)}><IconTrash size={14}/></ActionIcon>
                                                </Table.Td>
                                            </Table.Tr>
                                        ))}
                                        {(!activeRubric.criteria || activeRubric.criteria.length === 0) && (
                                            <Table.Tr><Table.Td colSpan={3} ta="center" c="dimmed" py="md">La grille est vide.</Table.Td></Table.Tr>
                                        )}
                                    </Table.Tbody>
                                </Table>
                                <Divider my="lg" label="Ajout critère personnalisé" labelPosition="center" />
                                <CustomCriterionForm onAdd={handleAddCriterion} loading={loading} />
                            </Paper>
                        </Grid.Col>

                        <Grid.Col span={{ base: 12, md: 5 }}>
                            <Paper withBorder p="md" radius="md" bg="gray.0">
                                <Title order={5} mb="xs">Bibliothèque d'AC liés</Title>
                                <Text size="xs" c="dimmed" mb="md">Cliquez sur + pour ajouter un apprentissage critique.</Text>
                                <Stack gap="xs">
                                    {(activity.learning_outcomes || []).map((ac: any) => {
                                        const isIn = activeRubric.criteria?.some((c:any) => c.ac_id === ac.id);
                                        return (
                                            <Paper key={ac.id} p="xs" withBorder radius="xs" bg={isIn ? 'gray.1' : 'white'}>
                                                <Group justify="space-between" wrap="nowrap">
                                                    <div style={{flexGrow: 1}}>
                                                        <Text size="xs" fw={700} c="teal">{ac.code}</Text>
                                                        <Text size="xs" lineClamp={1}>{ac.label}</Text>
                                                    </div>
                                                    <ActionIcon 
                                                        size="sm" 
                                                        variant={isIn ? "transparent" : "light"} 
                                                        color="teal" 
                                                        onClick={() => handleAddCriterion(ac.label, 1, ac.id)} 
                                                        disabled={isIn || loading}
                                                    >
                                                        {isIn ? <IconCheck size={14}/> : <IconPlus size={14} />}
                                                    </ActionIcon>
                                                </Group>
                                            </Paper>
                                        );
                                    })}
                                </Stack>
                            </Paper>
                        </Grid.Col>
                    </Grid>
                </Stack>
            )}

            <Modal opened={isRenaming} onClose={() => setIsRenaming(false)} title="Renommer la grille">
                <Stack>
                    <TextInput label="Nouveau nom" value={rubricName} onChange={(e) => setRubricName(e.target.value)} />
                    <Button onClick={handleRenameRubric} loading={loading}>Enregistrer</Button>
                </Stack>
            </Modal>
        </Stack>
    );
}

function CustomCriterionForm({ onAdd, loading }: any) {
    const [label, setLabel] = useState('');
    const [weight, setWeight] = useState<number | string>(1);
    return (
        <Group align="flex-end" grow>
            <TextInput label="Critère" size="xs" value={label} onChange={(e) => setLabel(e.target.value)} />
            <NumberInput label="Points" size="xs" value={weight} onChange={setWeight} style={{maxWidth: 70}} />
            <Button size="xs" disabled={!label.trim() || loading} onClick={() => { onAdd(label, Number(weight)); setLabel(''); }}>Ajouter</Button>
        </Group>
    );
}