import React, { useState, useEffect } from 'react';
import { Stack, Group, TextInput, Button, Divider, Text, Paper, Title, Select, Textarea, Timeline, Alert, Slider, Badge, ThemeIcon, Anchor, Box, Avatar } from '@mantine/core';
import { useMediaQuery } from '@mantine/hooks';
import { DateInput } from '@mantine/dates';
import { IconDeviceFloppy, IconPlus, IconTruck, IconPhone, IconVideo, IconLink, IconMail, IconTrash, IconCirclePlus, IconBriefcase, IconShare } from '@tabler/icons-react';
import api from '../services/api';
import { notifications } from '@mantine/notifications';

export function ProfessorInternshipManager({ student }: { student: any }) {
    const isMobile = useMediaQuery('(max-width: 62em)');
    const [data, setData] = useState<any>(null);
    const [visits, setVisits] = useState<any[]>([]);
    const [loading, setLoading] = useState(true);
    const [newVisit, setNewVisit] = useState({ date: new Date(), type: 'SITE', report_content: '' });
    const [generatingLink, setGeneratingLink] = useState(false);
    const [evaluations, setEvaluations] = useState<any[]>([]);
    const [rubric, setRubric] = useState<any>(null);
    const [teacherScores, setTeacherScores] = useState<any[]>([]);
    const [history, setHistory] = useState<any[]>([]);

    const CompanyLogo = ({ email }: { email?: string }) => {
        const [src, setSrc] = useState<string | null>(null);
        const [domain, setDomain] = useState<string | null>(null);

        useEffect(() => {
            if (!email) { setSrc(null); return; }
            const d = email.split('@')[1];
            const generic = ['gmail.com', 'outlook.fr', 'orange.fr', 'wanadoo.fr', 'yahoo.fr', 'hotmail.com'];
            if (d && !generic.includes(d)) {
                setDomain(d);
                setSrc(`https://logo.clearbit.com/${d}`);
            } else {
                setSrc(null);
            }
        }, [email]);

        const handleError = () => {
            if (src && src.includes('clearbit') && domain) {
                setSrc(`https://www.google.com/s2/favicons?domain=${domain}&sz=64`);
            } else {
                setSrc(null);
            }
        };

        return (
            <Avatar src={src} size="lg" radius="md" onError={handleError}>
                <IconBriefcase size={30} />
            </Avatar>
        );
    };

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
                    return { criterion_id: c.id, score: existing ? existing.score : 50, comment: existing ? existing.comment : '' };
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

    const handleShareLink = async () => {
        const shareUrl = `${window.location.origin}/app/?token=${data.evaluation_token}`;
        const shareData = {
            title: 'Évaluation de Stage',
            text: `Bonjour, voici le lien pour évaluer le stage de ${student.full_name} :`,
            url: shareUrl,
        };

        if (navigator.share) {
            try {
                await navigator.share(shareData);
            } catch (err) { console.log('Share failed', err); }
        } else {
            navigator.clipboard.writeText(`${shareData.text} ${shareUrl}`);
            notifications.show({ title: 'Copié !', message: 'Lien copié dans le presse-papier.' });
        }
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

    const getScoreByRole = (criterionId: number, role: string) => {
        const ev = evaluations.find(e => e.evaluator_role === role && e.criterion_id === criterionId);
        return ev ? ev.score : null;
    };

    const getCommentByRole = (criterionId: number, role: string) => {
        const ev = evaluations.find(e => e.evaluator_role === role && e.criterion_id === criterionId);
        return ev ? ev.comment : null;
    };

    const getVisitIcon = (type: string) => {
        if (type === 'SITE') return <IconTruck size={16} />;
        if (type === 'PHONE') return <IconPhone size={16} />;
        return <IconVideo size={16} />;
    };

    if (loading) return <Text p="xl" ta="center">Chargement des données...</Text>;

    return (
        <Stack gap="xl" pb={isMobile ? 100 : 0}>
            {/* ACTIONS DE GESTION */}
            <Paper withBorder p="sm" bg="gray.0" radius="md">
                <Group justify="space-between">
                    <Button variant="outline" color="blue" size={isMobile ? "md" : "xs"} leftSection={<IconCirclePlus size={16}/>} onClick={handleCreateNew}>
                        Nouveau Stage
                    </Button>
                    <Button variant="subtle" color="red" size={isMobile ? "md" : "xs"} leftSection={<IconTrash size={16}/>} onClick={handleDelete}>
                        Effacer
                    </Button>
                </Group>
            </Paper>

            {/* DATES */}
            <Paper withBorder p={isMobile ? "xl" : "md"} radius="md" bg="blue.0" shadow="sm">
                <Title order={5} mb="md">Calendrier du Stage</Title>
                <Stack gap="md">
                    <Group grow stackOnMobile>
                        <DateInput label="Date de début" size={isMobile ? "lg" : "sm"} value={data.start_date ? new Date(data.start_date) : null} onChange={(d) => setData({...data, start_date: d})} />
                        <DateInput label="Date de fin" size={isMobile ? "lg" : "sm"} value={data.end_date ? new Date(data.end_date) : null} onChange={(d) => setData({...data, end_date: d})} />
                    </Group>
                    <Button fullWidth size={isMobile ? "lg" : "sm"} onClick={handleSaveDates} leftSection={<IconDeviceFloppy size={20}/>}>
                        Enregistrer les dates
                    </Button>
                </Stack>
            </Paper>

            {/* VISITES ET CONTACTS */}
            <Divider label={<Text size="sm" fw={700}>VISITES ET CONTACTS</Text>} labelPosition="center" />
            
            <Paper withBorder p={isMobile ? "xl" : "md"} bg="gray.0" radius="md">
                <Stack gap="lg">
                    {/* BLOC CONTACTS */}
                    <Stack gap="md">
                        <Paper p="md" radius="sm" withBorder bg="white">
                            <Text size="xs" fw={700} c="dimmed" mb={5}>ÉLÈVE</Text>
                            <Text size="lg" fw={700}>{student.full_name}</Text>
                            <Anchor href={`mailto:${student.email}`} size="md" display="block">{student.email}</Anchor>
                            {student.phone && (
                                <Anchor href={`tel:${student.phone.replace(/\s/g, '')}`} size="lg" fw={700} color="green" display="block" mt={5}>
                                    <IconPhone size={18} style={{ verticalAlign: 'middle', marginRight: 8 }} />
                                    {student.phone}
                                </Anchor>
                            )}
                        </Paper>
                        <Paper p="md" radius="sm" withBorder bg="white">
                            <Text size="xs" fw={700} c="dimmed" mb={5}>ENTREPRISE & TUTEUR PRO</Text>
                            <Group align="flex-start" wrap="nowrap">
                                <CompanyLogo email={data.company_email} />
                                <Box style={{ flex: 1 }}>
                                    <Text size="lg" fw={700}>{data.company_name || 'N/A'}</Text>
                                    <Text size="md" fw={600}>{data.supervisor_name || 'Maître de stage non renseigné'}</Text>
                                    <Anchor href={`mailto:${data.company_email}`} size="md" display="block">{data.company_email}</Anchor>
                                    {(data.supervisor_phone || data.company_phone) && (
                                        <Anchor href={`tel:${(data.supervisor_phone || data.company_phone).replace(/\s/g, '')}`} size="lg" fw={700} color="green" display="block" mt={5}>
                                            <IconPhone size={18} style={{ verticalAlign: 'middle', marginRight: 8 }} />
                                            {data.supervisor_phone || data.company_phone}
                                        </Anchor>
                                    )}
                                </Box>
                            </Group>
                        </Paper>
                    </Stack>
                    
                    <Divider variant="dotted" />

                    {/* FORMULAIRE VISITE */}
                    <Stack gap="md">
                        <Title order={5}>Ajouter un suivi / RDV</Title>
                        <Group grow stackOnMobile>
                            <DateInput label="Date du RDV" size="lg" value={newVisit.date} onChange={(d) => d && setNewVisit({...newVisit, date: d})} />
                            <Select label="Type" size="lg" value={newVisit.type} onChange={(v) => setNewVisit({...newVisit, type: v || 'SITE'})} data={[{value:'SITE', label:'Sur place'}, {value:'PHONE', label:'Tél'}, {value:'VISIO', label:'Visio'}]} />
                        </Group>
                        <Textarea label="Rapport de visite" size="lg" placeholder="Points abordés, ambiance..." minRows={3} value={newVisit.report_content} onChange={(e) => setNewVisit({...newVisit, report_content: e.target.value})} />
                        <Button onClick={handleAddVisit} size="lg" color="green" leftSection={<IconPlus size={20}/>}>Valider ce rapport</Button>
                    </Stack>
                </Stack>
            </Paper>

            {/* TIMELINE VISITES */}
            {visits.length > 0 && (
                <Paper p="md">
                    <Timeline active={visits.length - 1} bulletSize={isMobile ? 32 : 24} lineWidth={2}>
                        {visits.map((v, i) => (
                            <Timeline.Item key={i} bullet={getVisitIcon(v.type)} title={new Date(v.date).toLocaleDateString()}>
                                <Text size={isMobile ? "md" : "sm"}>{v.report_content}</Text>
                                <Text size="xs" c="dimmed">{v.type}</Text>
                            </Timeline.Item>
                        ))}
                    </Timeline>
                </Paper>
            )}

            {/* SYNTHÈSE ÉVALUATIONS */}
            <Divider label={<Text size="sm" fw={700}>SYNTHÈSE ET ÉVALUATION FINALE</Text>} labelPosition="center" />
            
            {rubric && (
                <Paper withBorder p="xl" bg="blue.0" radius="md" shadow="md">
                    <Group justify="space-between">
                        <Title order={4}>Note Académique Finale</Title>
                        <Badge size="xl" h={50} px="xl" color="blue" variant="filled">
                            <Text size="xl" fw={900}>{calculateFinalGrade().toFixed(2)} / 20</Text>
                        </Badge>
                    </Group>
                </Paper>
            )}

            {rubric ? (
                <Stack gap="xl">
                    {rubric.criteria.map((c: any, idx: number) => {
                        const sScore = getScoreByRole(c.id, 'STUDENT');
                        const pScore = getScoreByRole(c.id, 'PRO');
                        const sComm = getCommentByRole(c.id, 'STUDENT');
                        const pComm = getCommentByRole(c.id, 'PRO');
                        return (
                            <Paper key={c.id} withBorder p="xl" bg="white" shadow="sm">
                                <Text size="lg" fw={700} mb="lg" c="indigo">{c.label} ({c.weight} pts)</Text>
                                <Stack gap="md">
                                    <Group grow stackOnMobile>
                                        <Paper p="sm" withBorder bg="blue.0">
                                            <Text size="xs" fw={700} c="blue">ÉLÈVE: {sScore??'N/A'}%</Text>
                                            {sComm && <Text size="sm" fs="italic">{sComm}</Text>}
                                        </Paper>
                                        <Paper p="sm" withBorder bg="orange.0">
                                            <Text size="xs" fw={700} c="orange">PRO: {pScore??'N/A'}%</Text>
                                            {pComm && <Text size="sm" fs="italic">{pComm}</Text>}
                                        </Paper>
                                    </Group>
                                    <Divider variant="dashed" my="md" />
                                    <Text fw={700} size="md">VOTRE NOTE (PROF) :</Text>
                                    <Slider 
                                        size="xl"
                                        label={(v)=>`Prof: ${v}%`} 
                                        value={teacherScores[idx]?.score || 0} 
                                        onChange={(v)=>{const n=[...teacherScores]; n[idx].score=v; setTeacherScores(n);}} 
                                        color="green" 
                                        marks={[{value:0, label:'0%'}, {value:50, label:'50%'}, {value:100, label:'100%'}]}
                                        mb="xl"
                                    />
                                    <Textarea 
                                        label="Commentaire académique"
                                        size="lg"
                                        placeholder="Observations finales..." 
                                        value={teacherScores[idx]?.comment || ''} 
                                        onChange={(e)=>{const n=[...teacherScores]; n[idx].comment=e.target.value; setTeacherScores(n);}} 
                                    />
                                </Stack>
                            </Paper>
                        );
                    })}
                    <Button fullWidth size="xl" color={data.is_finalized ? "gray" : "green"} onClick={handleSaveTeacherEval} disabled={data.is_finalized} leftSection={<IconDeviceFloppy size={24}/>}>
                        {data.is_finalized ? "Évaluation déjà finalisée" : "VALIDER L'ÉVALUATION FINALE"}
                    </Button>
                </Stack>
            ) : <Text p="xl" ta="center" c="dimmed">Aucune grille d'évaluation définie pour ce stage.</Text>}

            {/* MAGIC LINK */}
            {data && data.company_email && (
                <Paper withBorder p="xl" radius="md" shadow="sm">
                    <Title order={5} mb="md">Partage du Magic Link (Tuteur Pro)</Title>
                    {!data.evaluation_token ? (
                        <Button fullWidth variant="light" size="lg" onClick={handleGenerateLink} leftSection={<IconLink size={20}/>}>Générer le lien d'évaluation</Button>
                    ) : (
                        <Stack gap="md">
                            <Alert color="blue" p="md" icon={<IconLink size={20} />}>
                                <Text size="sm" fw={700} mb="xs">Lien d'évaluation :</Text>
                                <Text size="xs" style={{ wordBreak: 'break-all' }} fw={600} bg="white" p="xs">{window.location.origin}/app/?token={data.evaluation_token}</Text>
                            </Alert>
                            <Button 
                                fullWidth 
                                size="xl" 
                                color="blue" 
                                leftSection={<IconShare size={24}/>} 
                                onClick={handleShareLink}
                            >
                                {navigator.share ? "Partager (SMS, WhatsApp, Mail...)" : "Copier le lien"}
                            </Button>
                        </Stack>
                    )}
                </Paper>
            )}

            {/* HISTORIQUE */}
            {history.length > 0 && (
                <Stack mt="xl">
                    <Divider label="HISTORIQUE DES STAGES" labelPosition="center" />
                    {history.map(h => (
                        <Paper key={h.id} withBorder p="md" bg="gray.1">
                            <Group justify="space-between">
                                <div>
                                    <Text size="md" fw={700}>{h.company_name || 'Entreprise inconnue'}</Text>
                                    <Text size="xs" c="dimmed">ID: {h.id} | Finalisé: {h.is_finalized ? 'Oui' : 'Non'}</Text>
                                </div>
                                <Badge color="gray">Archivé</Badge>
                            </Group>
                        </Paper>
                    ))}
                </Stack>
            )}
        </Stack>
    );
}
