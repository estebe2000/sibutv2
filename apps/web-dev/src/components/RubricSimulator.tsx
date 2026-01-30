import React, { useState } from 'react';
import { Paper, Title, Text, Group, Stack, Button, Slider, Textarea, Badge, Divider, Grid, Box, ThemeIcon, Alert } from '@mantine/core';
import { IconChevronLeft, IconInfoCircle, IconCalculator, IconMessageDots, IconChartBar } from '@tabler/icons-react';

export function RubricSimulator({ rubric, activity, onBack }: { rubric: any, activity: any, onBack: () => void }) {
    // État de la simulation : { criterionId: { percent: number, comment: str } }
    const [ratings, setRatings] = useState<Record<number, { percent: number, comment: string }>>(
        rubric.criteria.reduce((acc: any, c: any) => ({ ...acc, [c.id]: { percent: 50, comment: '' } }), {})
    );
    const [globalComment, setGlobalComment] = useState('');

    const updateRating = (id: number, percent: number) => {
        setRatings({ ...ratings, [id]: { ...ratings[id], percent } });
    };

    const updateComment = (id: number, comment: string) => {
        setRatings({ ...ratings, [id]: { ...ratings[id], comment } });
    };

    // Calcul de la note finale
    const totalPoints = rubric.criteria.reduce((acc: number, c: any) => acc + (c.weight || 0), 0);
    const simulatedScore = rubric.criteria.reduce((acc: number, c: any) => {
        const rating = ratings[c.id];
        return acc + ((c.weight || 0) * (rating.percent / 100));
    }, 0);

    const getTrackColor = (val: number) => {
        if (val < 35) return 'red';
        if (val < 65) return 'orange';
        return 'teal';
    };

    return (
        <Stack gap="lg">
            <Group justify="space-between">
                <Button variant="subtle" leftSection={<IconChevronLeft size={16}/>} onClick={onBack}>Retour aux grilles</Button>
                <Title order={3} c="blue">Simulateur : {rubric.name}</Title>
                <Paper withBorder px="md" py="xs" bg="blue.0" radius="md">
                    <Group gap="xs">
                        <IconCalculator size={20} color="blue" />
                        <Text fw={700} size="xl">
                            Note : {simulatedScore.toFixed(2)} / {totalPoints}
                        </Text>
                    </Group>
                </Paper>
            </Group>

            <Alert icon={<IconInfoCircle size={16} />} title={`Activité : ${activity.code}`} color="indigo" variant="light">
                <Text size="sm">{activity.label}</Text>
                <Text size="xs" mt="xs" c="dimmed">{activity.description}</Text>
                <Text size="sm" mt="sm" fw={700}>Évalué : ÉLÈVE XXXXXX</Text>
            </Alert>

            <Grid gutter="xl">
                {/* Liste des critères */}
                <Grid.Col span={8}>
                    <Stack gap="xl">
                        {rubric.criteria.map((c: any) => (
                            <Paper key={c.id} withBorder p="md" radius="md" shadow="xs" style={{ position: 'relative', overflow: 'hidden' }}>
                                {/* Fond avec colonnes repères */}
                                <Box style={{ 
                                    position: 'absolute', top: 0, left: 0, right: 0, bottom: 0, 
                                    display: 'flex', zIndex: 0, opacity: 0.05, pointerEvents: 'none' 
                                }}>
                                    <Box style={{ flex: 1, borderRight: '1px solid black' }} />
                                    <Box style={{ flex: 1, borderRight: '1px solid black' }} />
                                    <Box style={{ flex: 1, borderRight: '1px solid black' }} />
                                    <Box style={{ flex: 1 }} />
                                </Box>

                                <Stack gap="xs" style={{ position: 'relative', zIndex: 1 }}>
                                    <Group justify="space-between">
                                        <Group gap="xs">
                                            {c.ac_id && <Badge color="teal" size="xs">AC</Badge>}
                                            <Text fw={600} size="sm">{c.label}</Text>
                                        </Group>
                                        <Badge variant="outline" color="gray">{c.weight} pts</Badge>
                                    </Group>

                                    <Group grow align="center" gap="xl">
                                        <Box style={{ flexGrow: 1 }}>
                                            <Slider
                                                value={ratings[c.id].percent}
                                                onChange={(v) => updateRating(c.id, v)}
                                                color={getTrackColor(ratings[c.id].percent)}
                                                marks={[
                                                    { value: 0, label: '0%' },
                                                    { value: 25, label: 'Insuffisant' },
                                                    { value: 50, label: 'Fragile' },
                                                    { value: 75, label: 'Satisfaisant' },
                                                    { value: 100, label: 'Très bien' },
                                                ]}
                                                step={5}
                                                mb="xl"
                                            />
                                        </Box>
                                        <Box style={{ width: 100, textAlign: 'right' }}>
                                            <Text fw={700} c={getTrackColor(ratings[c.id].percent)}>
                                                {((c.weight * ratings[c.id].percent) / 100).toFixed(2)} pts
                                            </Text>
                                            <Text size="xs" c="dimmed">{ratings[c.id].percent}%</Text>
                                        </Box>
                                    </Group>

                                    <Textarea 
                                        placeholder="Commentaire sur ce critère..." 
                                        size="xs" 
                                        variant="filled"
                                        value={ratings[c.id].comment}
                                        onChange={(e) => updateComment(c.id, e.target.value)}
                                        leftSection={<IconMessageDots size={14}/>}
                                    />
                                </Stack>
                            </Paper>
                        ))}
                    </Stack>
                </Grid.Col>

                {/* Bilan Global */}
                <Grid.Col span={4}>
                    <Stack style={{ position: 'sticky', top: 20 }}>
                        <Paper withBorder p="md" radius="md" bg="gray.0">
                            <Title order={5} mb="sm">Bilan de l'évaluation</Title>
                            <Divider mb="md" />
                            <Stack gap="xs">
                                <Group justify="space-between">
                                    <Text size="sm">Critères évalués :</Text>
                                    <Text size="sm" fw={700}>{rubric.criteria.length}</Text>
                                </Group>
                                <Group justify="space-between">
                                    <Text size="sm">Moyenne réussite :</Text>
                                    <Text size="sm" fw={700} color="blue">
                                        {(rubric.criteria.reduce((acc:number, c:any) => acc + ratings[c.id].percent, 0) / rubric.criteria.length).toFixed(0)} %
                                    </Text>
                                </Group>
                            </Stack>

                            <Textarea 
                                label="Commentaire global"
                                placeholder="Observations générales sur la prestation..." 
                                mt="xl"
                                minRows={6}
                                value={globalComment}
                                onChange={(e) => setGlobalComment(e.target.value)}
                            />

                            <Button fullWidth mt="xl" leftSection={<IconChartBar size={16}/>} disabled>
                                Enregistrer (Bientôt disponible)
                            </Button>
                        </Paper>
                    </Stack>
                </Grid.Col>
            </Grid>
        </Stack>
    );
}
