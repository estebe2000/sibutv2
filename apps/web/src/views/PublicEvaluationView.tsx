import React, { useState, useEffect } from 'react';
import { Container, Paper, Title, Text, Stack, Slider, Button, Group, Loader, Alert, Textarea, Center, ThemeIcon } from '@mantine/core';
import { IconShieldCheck, IconCheck, IconAlertCircle, IconBriefcase } from '@tabler/icons-react';
import api from '../services/api';

export function PublicEvaluationView({ token }: { token: string }) {
    const [data, setData] = useState<any>(null);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState<string | null>(null);
    const [evaluations, setEvaluations] = useState<any[]>([]);
    const [submitting, setSubmitting] = useState(false);
    const [done, setDone] = useState(false);

    useEffect(() => {
        api.get(`/public-eval/${token}`)
            .then(res => {
                setData(res.data);
                // Initialiser les scores à 0
                const initialEvals = res.data.rubric.criteria.map((c: any) => ({
                    criterion_id: c.id,
                    score: 50,
                    comment: ''
                }));
                setEvaluations(initialEvals);
                setLoading(false);
            })
            .catch(e => {
                setError(e.response?.data?.detail || "Lien invalide ou expiré");
                setLoading(false);
            });
    }, [token]);

    const handleSubmit = async () => {
        setSubmitting(true);
        try {
            await api.post(`/public-eval/${token}`, evaluations);
            setDone(true);
        } catch (e) {
            setError("Échec de l'envoi de l'évaluation");
        }
        setSubmitting(false);
    };

    if (loading) return <Center h="100vh"><Stack align="center"><Loader /><Text>Chargement de la grille d'évaluation...</Text></Stack></Center>;

    if (error) return (
        <Center h="100vh">
            <Alert icon={<IconAlertCircle size={16} />} title="Erreur" color="red" variant="filled">
                {error}
            </Alert>
        </Center>
    );

    if (done) return (
        <Center h="100vh">
            <Paper shadow="xl" p="xl" radius="md" withBorder ta="center">
                <ThemeIcon size={80} radius="xl" color="green" mb="md"><IconCheck size={50} /></ThemeIcon>
                <Title order={2} mb="xs">Merci !</Title>
                <Text c="dimmed">Votre évaluation pour <b>{data.student_name}</b> a été enregistrée avec succès.</Text>
            </Paper>
        </Center>
    );

    return (
        <Container size="sm" py="xl">
            <Stack gap="xl">
                <Paper shadow="sm" p="lg" radius="md" withBorder bg="blue.0">
                    <Group>
                        <IconBriefcase color="#228be6" />
                        <div>
                            <Title order={3}>Évaluation de Stage Professionnel</Title>
                            <Text size="sm" c="dimmed">Étudiant : {data.student_name} | Entreprise : {data.company}</Text>
                        </div>
                    </Group>
                </Paper>

                <Title order={4}>{data.rubric.name}</Title>

                {data.rubric.criteria.map((c: any, index: number) => (
                    <Paper key={c.id} p="md" withBorder>
                        <Stack gap="xs">
                            <Text fw={700}>{c.label}</Text>
                            {c.description && <Text size="xs" c="dimmed">{c.description}</Text>}
                            <Group align="flex-end" mt="md">
                                <Stack gap={0} flex={1}>
                                    <Text size="xs" mb={5} fw={500}>Niveau d'acquisition : {evaluations[index].score}%</Text>
                                    <Slider 
                                        value={evaluations[index].score}
                                        onChange={(val) => {
                                            const newEvals = [...evaluations];
                                            newEvals[index].score = val;
                                            setEvaluations(newEvals);
                                        }}
                                        marks={[
                                            { value: 0, label: 'Non acquis' },
                                            { value: 50, label: 'En cours' },
                                            { value: 100, label: 'Maîtrisé' },
                                        ]}
                                    />
                                </Stack>
                            </Group>
                            <Textarea 
                                placeholder="Commentaire optionnel..."
                                mt="lg"
                                size="xs"
                                value={evaluations[index].comment}
                                onChange={(e) => {
                                    const newEvals = [...evaluations];
                                    newEvals[index].comment = e.target.value;
                                    setEvaluations(newEvals);
                                }}
                            />
                        </Stack>
                    </Paper>
                ))}

                <Button fullWidth size="lg" color="green" onClick={handleSubmit} loading={submitting}>
                    Valider l'évaluation finale
                </Button>
            </Stack>
        </Container>
    );
}
