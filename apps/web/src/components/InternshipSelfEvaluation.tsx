import React, { useState, useEffect } from 'react';
import { Paper, Title, Text, Stack, Slider, Button, Group, Loader, Textarea, Divider, ThemeIcon } from '@mantine/core';
import { IconCheck, IconDeviceFloppy, IconChartBar, IconDownload, IconTrophy } from '@tabler/icons-react';
import { RadarChart } from '@mantine/charts';
import api from '../services/api';
import { notifications } from '@mantine/notifications';

export function InternshipSelfEvaluation({ studentUid }: { studentUid: string }) {
    const [rubric, setRubric] = useState<any>(null);
    const [evaluations, setEvaluations] = useState<any[]>([]);
    const [loading, setLoading] = useState(true);
    const [saving, setSaving] = useState(false);
    const [internshipId, setInternshipId] = useState<number | null>(null);
    const [isFinalized, setIsFinalized] = useState(false);
    const [allEvals, setAllEvals] = useState<any[]>([]);

    useEffect(() => {
        const fetchRubricAndEvals = async () => {
            try {
                const internRes = await api.get(`/internships/${studentUid}`);
                setInternshipId(internRes.data.id);
                setIsFinalized(internRes.data.is_finalized);
                
                const allActivitiesRes = await api.get('/evaluation-builder/activities');
                const stageActivity = allActivitiesRes.data.find((a: any) => a.type === 'STAGE');
                
                if (stageActivity && stageActivity.rubrics.length > 0) {
                    const r = stageActivity.rubrics[0];
                    setRubric(r);
                    
                    const evalRes = await api.get(`/internships/${studentUid}/evaluations`);
                    setAllEvals(evalRes.data);
                    const myEvals = evalRes.data.filter((e: any) => e.evaluator_role === 'STUDENT');

                    const initialEvals = r.criteria.map((c: any) => {
                        const existing = myEvals.find((e: any) => e.criterion_id === c.id);
                        return {
                            criterion_id: c.id,
                            score: existing ? existing.score : 50,
                            comment: existing ? existing.comment : ''
                        };
                    });
                    setEvaluations(initialEvals);
                }
                setLoading(false);
            } catch (e) { console.error(e); setLoading(false); }
        };
        fetchRubricAndEvals();
    }, [studentUid]);

    const handleSave = async () => {
        setSaving(true);
        try {
            await api.post(`/internships/${studentUid}/evaluate`, {
                role: "STUDENT",
                evaluations: evaluations
            });
            notifications.show({ title: 'Succès', message: 'Auto-évaluation enregistrée', color: 'green' });
        } catch (e) {
            notifications.show({ title: 'Erreur', message: 'Échec de la sauvegarde', color: 'red' });
        }
        setSaving(false);
    };

    if (loading) return <Loader size="sm" />;
    if (!rubric) return null;

    if (isFinalized) {
        const chartData = rubric.criteria.map((c: any) => ({
            criterion: c.label.length > 25 ? c.label.substring(0, 22) + '...' : c.label,
            Etudiant: allEvals.find(e => e.criterion_id === c.id && e.evaluator_role === 'STUDENT')?.score || 0,
            Pro: allEvals.find(e => e.criterion_id === c.id && e.evaluator_role === 'PRO')?.score || 0,
            Prof: allEvals.find(e => e.criterion_id === c.id && e.evaluator_role === 'TEACHER')?.score || 0,
        }));

        return (
            <Paper withBorder p="xl" radius="md" mt="md" shadow="md" bg="green.0">
                <Stack align="center" gap="xl">
                    <Group>
                        <ThemeIcon size={50} radius="xl" color="green" variant="filled"><IconTrophy size={30} /></ThemeIcon>
                        <div>
                            <Title order={3}>Bilan de Stage Finalisé</Title>
                            <Text c="dimmed" size="sm">Votre évaluation tripartite est disponible ci-dessous.</Text>
                        </div>
                    </Group>

                    <Paper withBorder p="lg" bg="white" w="100%" radius="md">
                        <Title order={5} ta="center" mb="xl">Synthèse des Compétences (%)</Title>
                        <div style={{ height: 400, width: '100%', minWidth: 300 }}>
                            <RadarChart
                                h={350}
                                data={chartData}
                                dataKey="criterion"
                                withLegend
                                gridColor="gray.2"
                                series={[
                                    { name: 'Etudiant', color: 'blue.4', opacity: 0.1 },
                                    { name: 'Pro', color: 'orange.4', opacity: 0.1 },
                                    { name: 'Prof', color: 'green.7', opacity: 0.4 },
                                ]}
                                radarProps={{ isAnimationActive: true }}
                            />
                        </div>
                    </Paper>

                    <Button 
                        size="lg" 
                        color="green" 
                        leftSection={<IconDownload size={20}/>}
                        component="a"
                        href={`${api.defaults.baseURL}/internships/${studentUid}/pdf`}
                        target="_blank"
                        variant="filled"
                    >
                        Télécharger le Rapport Complet (PDF)
                    </Button>
                </Stack>
            </Paper>
        );
    }

    return (
        <Paper withBorder p="md" radius="md" mt="md">
            <Stack gap="md">
                <Title order={4}>Mon Auto-Évaluation</Title>
                <Text size="xs" c="dimmed">Évaluez votre propre progression sur les critères définis pour ce stage.</Text>
                
                {rubric.criteria.map((c: any, index: number) => (
                    <div key={c.id}>
                        <Text size="sm" fw={500}>{c.label}</Text>
                        <Slider 
                            value={evaluations[index].score}
                            onChange={(val) => {
                                const newEvals = [...evaluations];
                                newEvals[index].score = val;
                                setEvaluations(newEvals);
                            }}
                            mb="xs"
                        />
                        <Textarea 
                            placeholder="Vos commentaires / preuves..."
                            size="xs"
                            value={evaluations[index].comment || ''}
                            onChange={(e) => {
                                const newEvals = [...evaluations];
                                newEvals[index].comment = e.target.value;
                                setEvaluations(newEvals);
                            }}
                            mb="lg"
                        />
                    </div>
                ))}
                
                <Button leftSection={<IconDeviceFloppy size={16}/>} onClick={handleSave} loading={saving}>
                    Enregistrer mon auto-évaluation
                </Button>
            </Stack>
        </Paper>
    );
}