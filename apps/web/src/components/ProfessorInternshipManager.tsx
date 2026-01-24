import React, { useState, useEffect } from 'react';
import { Stack, Group, TextInput, Button, Divider, Text, Paper, Title, Select, Textarea, Timeline, Alert, Slider, Badge } from '@mantine/core';
import { DateInput } from '@mantine/dates';
import { IconDeviceFloppy, IconPlus, IconTruck, IconPhone, IconVideo, IconLink, IconMail, IconTrash, IconCirclePlus } from '@tabler/icons-react';
import api from '../services/api';
import { notifications } from '@mantine/notifications';

export function ProfessorInternshipManager({ student }: { student: any }) {
    const [data, setData] = useState<any>(null);
    const [visits, setVisits] = useState<any[]>([]);
    const [loading, setLoading] = useState(true);
    const [newVisit, setNewVisit] = useState({ date: new Date(), type: 'SITE', report_content: '' });
    const [generatingLink, setGeneratingLink] = useState(false);
    const [evaluations, setEvaluations] = useState<any[]>([]);
    const [rubric, setRubric] = useState<any>(null);
    const [teacherScores, setTeacherScores] = useState<any[]>([]);
    const [history, setHistory] = useState<any[]>([]);

    const fetchData = async () => {
        setLoading(true);
        try {
            const [internRes, visitsRes, evalRes, allRubricsRes, historyRes] = await Promise.all([
                api.get(`/internships/${student.ldap_uid}`),
                api.get(`/internships/${student.ldap_uid}/visits`),
                api.get(`/internships/${student.ldap_uid}/evaluations`),
                api.get('/evaluation-builder/activities'),
                api.get(`/internships/${student.ldap_uid}/history`)
            ]);
            setData(internRes.data);
            setVisits(visitsRes.data);
            setEvaluations(evalRes.data);
            setHistory(historyRes.data.filter((i: any) => !i.is_active));
            
            const stageActivity = allRubricsRes.data.find((a: any) => a.type === 'STAGE');
            if (stageActivity && stageActivity.rubrics.length > 0) {
                const r = stageActivity.rubrics[0];
                setRubric(r);
                const initialScores = r.criteria.map((c: any) => {
                    const existing = evalRes.data.find((e: any) => e.evaluator_role === 'TEACHER' && e.criterion_id === c.id);
                    return { 
                        criterion_id: c.id, 
                        score: existing ? existing.score : 50,
                        comment: existing ? existing.comment : '' 
                    };
                });
                setTeacherScores(initialScores);
            }
            setLoading(false);
        } catch (e) { console.error(e); setLoading(false); }
    };

    useEffect(() => {
        fetchData();
    }, [student.ldap_uid]);

    const handleSaveTeacherEval = async () => {
        try {
            await api.post(`/internships/${student.ldap_uid}/evaluate`, {
                role: "TEACHER",
                evaluations: teacherScores,
                finalize: true
            });
            setData({...data, is_finalized: true});
            notifications.show({ title: 'Succès', message: 'Évaluation finale validée' });
        } catch (e) { console.error(e); }
    };

    const handleSaveDates = async () => {
        try {
            await api.patch(`/internships/${student.ldap_uid}`, {
                start_date: data.start_date,
                end_date: data.end_date
            });
            notifications.show({ title: 'Succès', message: 'Dates enregistrées' });
        } catch (e) { console.error(e); }
    };

    const handleAddVisit = async () => {
        try {
            const res = await api.post(`/internships/${student.ldap_uid}/visits`, newVisit);
            setVisits([...visits, res.data]);
            setNewVisit({ date: new Date(), type: 'SITE', report_content: '' });
            notifications.show({ title: 'Succès', message: 'Visite ajoutée' });
        } catch (e) { console.error(e); }
    };

    const handleCreateNew = async () => {
        if (!window.confirm("Archiver ce stage et en créer un nouveau ?")) return;
        try {
            await api.post(`/internships/${student.ldap_uid}/new`);
            fetchData();
        } catch (e) { console.error(e); }
    };

    const handleDelete = async () => {
        if (!window.confirm("Supprimer définitivement ?")) return;
        try {
            await api.delete(`/internships/${data.id}`);
            fetchData();
        } catch (e) { console.error(e); }
    };

    const handleGenerateLink = async () => {
        setGeneratingLink(true);
        try {
            const res = await api.post(`/internships/${student.ldap_uid}/generate-token`);
            setData({ ...data, evaluation_token: res.data.token });
        } catch (e) { console.error(e); }
        setGeneratingLink(false);
    };

    const getScoreByRole = (criterionId: number, role: string) => {
        const ev = evaluations.find(e => e.evaluator_role === role && e.criterion_id === criterionId);
        return ev ? ev.score : null;
    };

    const getCommentByRole = (criterionId: number, role: string) => {
        const ev = evaluations.find(e => e.evaluator_role === role && e.criterion_id === criterionId);
        return ev ? ev.comment : null;
    };

    const calculateFinalGrade = () => {
        if (!rubric) return 0;
        const totalPoints = rubric.criteria.reduce((acc: number, c: any) => acc + (c.weight || 0), 0);
        const actualPoints = rubric.criteria.reduce((acc: number, c: any, idx: number) => {
            const score = teacherScores[idx]?.score || 0;
            return acc + ((c.weight || 0) * (score / 100));
        }, 0);
        if (totalPoints === 0) return 0;
        return (actualPoints / totalPoints) * 20;
    };

    const getVisitIcon = (type: string) => {
        if (type === 'SITE') return <IconTruck size={12} />;
        if (type === 'PHONE') return <IconPhone size={12} />;
        return <IconVideo size={12} />;
    };

    if (loading) return <Text>Chargement...</Text>;

    return (
        <Stack gap="md">
            <Paper withBorder p="xs" bg="gray.0">
                <Group justify="space-between">
                    <Button variant="outline" color="blue" size="xs" leftSection={<IconCirclePlus size={14}/>} onClick={handleCreateNew}>
                        Nouveau Stage
                    </Button>
                    <Button variant="subtle" color="red" size="xs" leftSection={<IconTrash size={14}/>} onClick={handleDelete}>
                        Effacer ce stage
                    </Button>
                </Group>
            </Paper>

            <Paper withBorder p="sm" bg="blue.0">
                <Title order={5} mb="xs">Calendrier du Stage</Title>
                <Group grow>
                    <DateInput label="Début" value={data.start_date ? new Date(data.start_date) : null} onChange={(d) => setData({...data, start_date: d})} />
                    <DateInput label="Fin" value={data.end_date ? new Date(data.end_date) : null} onChange={(d) => setData({...data, end_date: d})} />
                </Group>
                <Button fullWidth mt="md" size="xs" onClick={handleSaveDates} leftSection={<IconDeviceFloppy size={14}/>}>
                    Fixer les dates
                </Button>
            </Paper>

            <Divider label="Visites" labelPosition="center" />
            <Paper withBorder p="sm" bg="gray.0">
                <Stack gap="xs">
                    <Group grow align="flex-end">
                        <DateInput label="Date" value={newVisit.date} onChange={(d) => d && setNewVisit({...newVisit, date: d})} size="xs" />
                        <Select label="Type" value={newVisit.type} onChange={(v) => setNewVisit({...newVisit, type: v || 'SITE'})} data={[{value:'SITE', label:'Sur place'}, {value:'PHONE', label:'Tél'}, {value:'VISIO', label:'Visio'}]} size="xs" />
                    </Group>
                    <Textarea label="Rapport" value={newVisit.report_content} onChange={(e) => setNewVisit({...newVisit, report_content: e.target.value})} size="xs" />
                    <Button onClick={handleAddVisit} size="xs" color="green" leftSection={<IconPlus size={14}/>}>Ajouter</Button>
                </Stack>
            </Paper>

            {visits.length > 0 && (
                <Timeline active={visits.length - 1} bulletSize={24} lineWidth={2}>
                    {visits.map((v, i) => (
                        <Timeline.Item key={i} bullet={getVisitIcon(v.type)} title={new Date(v.date).toLocaleDateString()}>
                            <Text size="sm">{v.report_content}</Text>
                        </Timeline.Item>
                    ))}
                </Timeline>
            )}

            <Divider label="Synthèse Évaluations" labelPosition="center" />
            {rubric && (
                <Paper withBorder p="md" mb="md" bg="blue.0" radius="md">
                    <Group justify="space-between">
                        <Title order={5}>Note Finale Calculée</Title>
                        <Badge size="xl" color="blue" variant="filled">
                            {calculateFinalGrade().toFixed(2)} / 20
                        </Badge>
                    </Group>
                </Paper>
            )}

            {rubric ? (
                <Stack gap="md">
                    {rubric.criteria.map((c: any, idx: number) => {
                        const sScore = getScoreByRole(c.id, 'STUDENT');
                        const pScore = getScoreByRole(c.id, 'PRO');
                        const sComm = getCommentByRole(c.id, 'STUDENT');
                        const pComm = getCommentByRole(c.id, 'PRO');
                        return (
                            <Paper key={c.id} withBorder p="xs" bg="gray.0">
                                <Text size="sm" fw={600} mb="xs">{c.label} ({c.weight} pts)</Text>
                                <Stack gap={5}>
                                    <Group grow>
                                        <div><Text size="10px" c="blue" fw={700}>Élève: {sScore??'N/A'}%</Text>{sComm && <Text size="10px" fs="italic" c="dimmed">{sComm}</Text>}</div>
                                        <div><Text size="10px" c="orange" fw={700}>Pro: {pScore??'N/A'}%</Text>{pComm && <Text size="10px" fs="italic" c="dimmed">{pComm}</Text>}</div>
                                    </Group>
                                    <Divider variant="dashed" my={5} />
                                    <Slider label={(v)=>`Prof: ${v}%`} value={teacherScores[idx]?.score || 0} onChange={(v)=>{const n=[...teacherScores]; n[idx].score=v; setTeacherScores(n);}} color="green" />
                                    <Textarea placeholder="Commentaire prof..." size="xs" value={teacherScores[idx]?.comment || ''} onChange={(e)=>{const n=[...teacherScores]; n[idx].comment=e.target.value; setTeacherScores(n);}} />
                                </Stack>
                            </Paper>
                        );
                    })}
                    <Button color={data.is_finalized ? "gray" : "green"} size="xs" onClick={handleSaveTeacherEval} disabled={data.is_finalized} leftSection={<IconDeviceFloppy size={14}/>}>
                        {data.is_finalized ? "Déjà finalisée" : "Valider l'évaluation finale"}
                    </Button>
                </Stack>
            ) : <Text size="xs" c="dimmed" ta="center">Pas de grille définie.</Text>}

            <Divider label="Entreprise" labelPosition="center" />
            <Paper withBorder p="sm">
                <Stack gap="xs">
                    <Group justify="space-between"><Text size="xs" fw={700}>ENTREPRISE :</Text><Text size="sm">{data.company_name || 'N/A'}</Text></Group>
                    <Group justify="space-between"><Text size="xs" fw={700}>EMAIL :</Text><Text size="sm">{data.company_email || 'N/A'}</Text></Group>
                </Stack>
                {data.company_email && (
                    <Stack mt="md">
                        {!data.evaluation_token ? (
                            <Button variant="light" size="xs" onClick={handleGenerateLink}>Générer le Magic Link</Button>
                        ) : (
                            <Alert color="blue" p="xs">
                                <Text size="xs" style={{ wordBreak: 'break-all' }}>{window.location.origin}/app/?token={data.evaluation_token}</Text>
                            </Alert>
                        )}
                    </Stack>
                )}
            </Paper>

            {history.length > 0 && (
                <Stack mt="xl">
                    <Divider label="Historique" labelPosition="center" />
                    {history.map(h => (
                        <Paper key={h.id} withBorder p="xs" bg="gray.1">
                            <Text size="xs" fw={700}>{h.company_name || 'Inconnue'}</Text>
                            <Text size="10px" c="dimmed">ID: {h.id}</Text>
                        </Paper>
                    ))}
                </Stack>
            )}
        </Stack>
    );
}
