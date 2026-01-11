import React, { useState, useEffect } from 'react';
import {
  Text,
  Group,
  Title,
  Paper,
  Stack,
  Button,
  Badge,
  TextInput,
  Select,
  ActionIcon,
  Modal,
  Tabs,
  Accordion,
  List,
  Box,
  Textarea,
  Loader,
  Grid,
  ThemeIcon,
  Container,
  Center,
  Divider
} from '@mantine/core';
import {
  IconPencil,
  IconPlus,
  IconDownload,
  IconClock,
  IconCategory,
  IconDatabase,
  IconBook,
  IconUsers,
  IconCrown
} from '@tabler/icons-react';
import { notifications } from '@mantine/notifications';
import axios from 'axios';
import { renderRichText } from '../components/RichTextRenderer';
import { ResponsibilitySelector } from '../components/ResponsibilitySelector';

// API URL (will be passed or fetched from store/env)
const API_URL = window.location.hostname === 'localhost'
  ? 'http://localhost:8000'
  : `http://${window.location.hostname}:8000`;

export function CompetencyEditor({ curriculum, onRefresh, professors }: any) {
  const [pathway, setPathway] = useState('Tronc Commun');
  const [editingComp, setEditingComp] = useState<any>(null);
  const [editingAct, setEditingAct] = useState<any>(null);

  const [infoItem, setInfoItem] = useState<any>(null);
  const [infoLoading, setInfoLoading] = useState(false);

  const [activeTabs, setActiveTabs] = useState<Record<number, string | null>>({ 1: 'comps', 2: 'comps', 3: 'comps' });
  const [expandedResource, setExpandedResource] = useState<string | null>(null);
  const [expandedActivity, setExpandedActivity] = useState<string | null>(null);
  const [expandedComp, setExpandedComp] = useState<string | null>(null);

  const getLevelFromCode = (code: string) => {
    const m = code.match(/[R|S|SAE]\s?(\d)/);
    if (!m) return 1;
    const digit = parseInt(m[1]);
    if (digit <= 2) return 1;
    if (digit <= 4) return 2;
    return 3;
  };

  useEffect(() => {
    const compHandler = (e: any) => {
        const code = e.detail;
        const lvl = getLevelFromCode(code);
        setActiveTabs(prev => ({ ...prev, [lvl]: 'comps' }));
        const comp = curriculum.competences.find((c: any) => c.code === code);
        if (comp) {
            setExpandedComp(comp.code + comp.id);
            setTimeout(() => {
                const el = document.getElementById(`comp-accordion-${comp.code + comp.id}`);
                if (el) el.scrollIntoView({ behavior: 'smooth', block: 'center' });
            }, 200);
        }
    };
    const resHandler = (e: any) => {
        const code = e.detail;
        const lvl = getLevelFromCode(code);
        setActiveTabs(prev => ({ ...prev, [lvl]: 'ress' }));

        const res = curriculum.resources.find((r: any) => r.code === code);
        if (res) {
            setExpandedResource(res.code + res.id);
            setTimeout(() => {
                const el = document.getElementById(`accordion-${res.code + res.id}`);
                if (el) el.scrollIntoView({ behavior: 'smooth', block: 'center' });
            }, 200);
        }
    };
    const actHandler = (e: any) => {
        const code = e.detail;
        const lvl = getLevelFromCode(code);
        setActiveTabs(prev => ({ ...prev, [lvl]: 'acts' }));

        const searchCode = code.replace('SAÉ', 'SAE').trim();
        const act = curriculum.activities.find((a: any) => a.code === searchCode);
        if (act) {
            const val = act.code + act.id;
            setExpandedActivity(val);
            setTimeout(() => {
                const el = document.getElementById(`act-accordion-${val}`);
                if (el) el.scrollIntoView({ behavior: 'smooth', block: 'center' });
            }, 200);
        }
    };
    window.addEventListener('switch-to-comp', compHandler);
    window.addEventListener('switch-to-resources', resHandler);
    window.addEventListener('switch-to-activities', actHandler);
    return () => {
        window.removeEventListener('switch-to-comp', compHandler);
        window.removeEventListener('switch-to-resources', resHandler);
        window.removeEventListener('switch-to-activities', actHandler);
    };
  }, [curriculum]);

  const pathways = ['TOUS', 'Tronc Commun', 'BI', 'BDMRC', 'MDEE', 'MMPV', 'SME'];
  const levels = [1, 2, 3];

  const handleSaveComp = async () => {
    try {
        await axios.patch(`${API_URL}/competencies/${editingComp.id}`, editingComp);
        notifications.show({ title: 'Succès', message: 'Compétence mise à jour' });
        setEditingComp(null);
        onRefresh();
    } catch (e) { notifications.show({ color: 'red', title: 'Erreur', message: 'Échec de la sauvegarde' }); }
  };

  const handleSaveAct = async () => {
    try {
        await axios.patch(`${API_URL}/activities/${editingAct.id}`, editingAct);
        notifications.show({ title: 'Succès', message: 'Activité mise à jour' });
        setEditingAct(null);
        onRefresh();
    } catch (e) { notifications.show({ color: 'red', title: 'Erreur', message: 'Échec de la sauvegarde' }); }
  };

  const handleExport = async () => {
    try {
        const res = await axios.get(`${API_URL}/export/curriculum`);
        const dataStr = "data:text/json;charset=utf-8," + encodeURIComponent(JSON.stringify(res.data, null, 2));
        const downloadAnchorNode = document.createElement('a');
        downloadAnchorNode.setAttribute("href",     dataStr);
        downloadAnchorNode.setAttribute("download", `referentiel_tc_${new Date().toISOString().split('T')[0]}.json`);
        document.body.appendChild(downloadAnchorNode);
        downloadAnchorNode.click();
        downloadAnchorNode.remove();
        notifications.show({ title: 'Export réussi', message: 'Le fichier de sauvegarde a été téléchargé' });
    } catch (e) { notifications.show({ color: 'red', title: 'Erreur', message: 'Échec de l\'export' }); }
  };

  const showInfo = async (item: any, type: 'RES' | 'AC', pathway?: string) => {
    setInfoLoading(true);
    setInfoItem({ ...item, type });
    try {
        if (type === 'RES') {
            const url = pathway
                ? `${API_URL}/resources/${item.code.trim()}?pathway=${encodeURIComponent(pathway)}`
                : `${API_URL}/resources/${item.code.trim()}`;
            const res = await axios.get(url);
            setInfoItem({ ...res.data, type });
        }
    } catch (e) {
        setInfoItem({ ...item, type, error: 'Détails non trouvés' });
    }
    setInfoLoading(false);
  };

  if (!curriculum || !curriculum.competences) return <Center p="xl"><Loader /></Center>;

  return (
    <Container size="lg">
      {/* INFO MODAL - ADAPTIVE VERSION */}
      <Modal opened={!!infoItem} onClose={() => setInfoItem(null)} title={infoItem?.code || "Infos"} size={infoItem?.type === 'AC' ? "lg" : "md"}>
        {infoLoading ? <Center p="xl"><Loader /></Center> : infoItem && (
            <Stack>
                <Title order={4} c="blue">{infoItem.label || infoItem.code}</Title>

                {infoItem.type === 'RES' && (infoItem.hours > 0 || infoItem.hours_details) && (
                    <Badge color="blue" variant="filled" leftSection={<IconClock size={12} />}>
                        Volume Horaire : {infoItem.hours_details || `${infoItem.hours}h`}
                    </Badge>
                )}

                <Divider />

                {infoItem.error ? <Text c="red">{infoItem.error}</Text> : (
                    <>
                        {infoItem.type === 'AC' ? (
                            // FULL SHEET FOR AC
                            <Box>
                                {renderRichText(infoItem.description, curriculum, showInfo, setActiveTabs)}
                            </Box>
                        ) : (
                            // LIGHT VERSION FOR RESOURCE
                            <>
                                {infoItem.description && (
                                    <Box>
                                        <Text size="sm" fw={700} mb={4}>Résumé :</Text>
                                        <Box>
                                            {renderRichText(infoItem.description.includes('Mots clés :') ? infoItem.description.split('Mots clés :')[0] : infoItem.description, curriculum, showInfo, setActiveTabs)}
                                        </Box>
                                    </Box>
                                )}

                                {infoItem.learning_outcomes?.length > 0 && (
                                    <Box mt="md">
                                        <Text size="sm" fw={700} mb={4}>AC Liés :</Text>
                                        <Group gap={5}>
                                            {infoItem.learning_outcomes.map((lo: any) => (
                                                <Badge key={lo.id} size="xs" variant="outline">{lo.code}</Badge>
                                            ))}
                                        </Group>
                                    </Box>
                                )}

                                <Button
                                    fullWidth
                                    variant="light"
                                    mt="lg"
                                                                    onClick={() => {
                                                                        const code = infoItem.code;
                                                                        setInfoItem(null);
                                                                        window.dispatchEvent(new CustomEvent('switch-to-resources', { detail: code }));
                                                                    }}                                >
                                    Voir la fiche complète (Menu Ressources)
                                </Button>
                            </>
                        )}
                    </>
                )}
            </Stack>
        )}
      </Modal>

      {/* COMP EDITOR MODAL */}
      <Modal opened={!!editingComp} onClose={() => setEditingComp(null)} title="Édition Compétence" size="lg">
        {editingComp && (
            <Stack>
                <Group grow>
                    <TextInput label="Code" value={editingComp.code} disabled />
                    <TextInput label="Parcours" value={editingComp.pathway} disabled />
                </Group>
                <TextInput label="Libellé" value={editingComp.label} onChange={(e) => setEditingComp({...editingComp, label: e.target.value})} />
                <Textarea label="Description" value={editingComp.description || ''} onChange={(e) => setEditingComp({...editingComp, description: e.target.value})} autosize minRows={3} />
                <Button onClick={handleSaveComp}>Sauvegarder</Button>
            </Stack>
        )}
      </Modal>

      {/* ACTIVITY EDITOR MODAL */}
      <Modal opened={!!editingAct} onClose={() => setEditingAct(null)} title="Édition Activité" size="lg">
        {editingAct && (
            <Stack>
                <Group grow>
                    <TextInput label="Code" value={editingAct.code} disabled />
                    <TextInput label="Type" value={editingAct.type} disabled />
                </Group>
                <TextInput label="Libellé" value={editingAct.label} onChange={(e) => setEditingAct({...editingAct, label: e.target.value})} />
                <Textarea label="Description (Objectifs)" value={editingAct.description || ''} onChange={(e) => setEditingAct({...editingAct, description: e.target.value})} autosize minRows={4} />
                <TextInput label="Ressources" value={editingAct.resources || ''} onChange={(e) => setEditingAct({...editingAct, resources: e.target.value})} placeholder="R1.01, R1.02..." />
                <ResponsibilitySelector entity={editingAct} type="activity" professors={professors} onRefresh={onRefresh} apiUrl={API_URL} />
                <Button onClick={handleSaveAct} mt="md">Sauvegarder</Button>
            </Stack>
        )}
      </Modal>

      <Group justify="space-between" mb="xl">
        <Title order={2}>Gestion du Référentiel</Title>
        <Group>
          <Button variant="light" color="blue" leftSection={<IconDownload size={16} />} onClick={handleExport} size="sm">Exporter (Sauvegarde)</Button>
          <Select
            placeholder="Parcours"
            data={pathways}
            value={pathway}
            onChange={(v) => setPathway(v || 'Tronc Commun')}
            size="sm"
          />
          <Button variant="outline" onClick={onRefresh} size="sm">Actualiser</Button>
        </Group>
      </Group>

      {levels.map(lvl => {
        const currPathway = lvl === 1 ? 'Tronc Commun' : pathway;

        const comps = curriculum.competences?.filter((c: any) => {
            if (c.level !== lvl) return false;
            if (pathway === 'TOUS') return true;
            return c.pathway === currPathway || c.pathway === 'Tronc Commun';
        }) || [];

        const acts = (curriculum.activities?.filter((a: any) => {
            if (a.level !== lvl) return false;
            if (pathway === 'TOUS') return true;
            return a.pathway === currPathway || a.pathway === 'Tronc Commun';
        }) || []).sort((a: any, b: any) => {
            // 1. Sort by Semester
            if (a.semester !== b.semester) return a.semester - b.semester;

            // 2. Sort by Type (SAE first, then PORTFOLIO, then STAGE)
            const typeOrder: any = { 'SAE': 1, 'PORTFOLIO': 2, 'STAGE': 3, 'PROJET': 4 };
            const typeA = typeOrder[a.type] || 99;
            const typeB = typeOrder[b.type] || 99;
            if (typeA !== typeB) return typeA - typeB;

            // 3. Sort by Code
            return a.code.localeCompare(b.code);
        });

        if (comps.length === 0 && acts.length === 0) return null;

        return (
          <Paper key={lvl} withBorder p="md" mb="xl" shadow="sm">
            <Group justify="space-between" mb="md">
              <Title order={3} c="blue">BUT {lvl}</Title>
              <Badge size="lg" variant="light">{pathway === 'TOUS' ? 'Tous Parcours' : currPathway}</Badge>
            </Group>

            <Tabs value={activeTabs[lvl]} onChange={(v) => setActiveTabs(prev => ({ ...prev, [lvl]: v }))}>
              <Tabs.List mb="md">
                <Tabs.Tab value="comps" leftSection={<IconCategory size={16} />}>Compétences ({comps.length})</Tabs.Tab>
                <Tabs.Tab value="acts" leftSection={<IconDatabase size={16} />} color="orange">Activités ({acts.length})</Tabs.Tab>
                <Tabs.Tab value="ress" leftSection={<IconBook size={16} />} color="teal">Ressources ({curriculum.resources?.filter((r: any) => {
                            if (!r.code) return false;
                            const codePrefix = parseInt(r.code.replace('R', '').split('.')[0]);
                            if (isNaN(codePrefix)) return false;

                            // Level Filter
                            let matchLevel = false;
                            if (lvl === 1 && (codePrefix === 1 || codePrefix === 2)) matchLevel = true;
                            if (lvl === 2 && (codePrefix === 3 || codePrefix === 4)) matchLevel = true;
                            if (lvl === 3 && (codePrefix === 5 || codePrefix === 6)) matchLevel = true;
                            if (!matchLevel) return false;

                            // Pathway Filter
                            const currPathway = lvl === 1 ? 'Tronc Commun' : pathway;
                            if (pathway === 'TOUS') return true;
                            return r.pathway === currPathway || r.pathway === 'Tronc Commun';
                        }).length})</Tabs.Tab>
              </Tabs.List>

              <Tabs.Panel value="comps">
                <Accordion variant="separated" value={expandedComp} onChange={setExpandedComp}>
                  {comps.map((c: any) => (
                    <Accordion.Item key={c.id} value={c.code + c.id} id={`comp-accordion-${c.code + c.id}`}>
                      <Accordion.Control>
                        <Group justify="space-between">
                          <Group><Badge color="blue">{c.code}</Badge><Text fw={600}>{c.label}</Text></Group>
                          <Group gap="xs">
                             <Badge size="xs" color="gray" variant="outline">{c.pathway}</Badge>
                             <ActionIcon size="xs" variant="subtle" onClick={(e) => { e.stopPropagation(); setEditingComp(c); }}><IconPencil size={12} /></ActionIcon>
                          </Group>
                        </Group>
                      </Accordion.Control>
                      <Accordion.Panel>
                        <Stack gap="lg">
                            {c.situations_pro && (
                                <Box>
                                    <Text size="xs" fw={700} c="blue" mb={4} tt="uppercase">Situations Professionnelles (Contextes)</Text>
                                    <Paper withBorder p="sm" bg="blue.0">
                                        <List size="sm" spacing="xs">
                                            {c.situations_pro.split('\n').map((s: string, i: number) => (
                                                <List.Item key={i}>{s.trim()}</List.Item>
                                            ))}
                                        </List>
                                    </Paper>
                                </Box>
                            )}

                            <Box>
                                <Text size="xs" fw={700} c="dimmed" mb={4} tt="uppercase">Composantes Essentielles (Critères Qualité)</Text>
                                <List size="sm" spacing="xs" withPadding>
                                    {c.essential_components?.map((ce: any) => (
                                        <List.Item key={ce.id}><b>{ce.code}</b> : {ce.label}</List.Item>
                                    ))}
                                </List>
                            </Box>

                            <Box>
                                <Text size="xs" fw={700} c="blue" mb={8} tt="uppercase">Apprentissages Critiques (Détails des attentes)</Text>
                                <Accordion variant="contained" chevronPosition="right">
                                    {c.learning_outcomes?.sort((a: any, b: any) => a.code.localeCompare(b.code)).map((lo: any) => (
                                        <Accordion.Item key={lo.id} value={lo.code}>
                                            <Accordion.Control>
                                                <Group gap="xs">
                                                    <Badge size="sm" variant="filled">{lo.code}</Badge>
                                                    <Text size="sm" fw={500}>{lo.label}</Text>
                                                </Group>
                                            </Accordion.Control>
                                            <Accordion.Panel>
                                                <Box p="xs">
                                                    {lo.description ? (
                                                        renderRichText(lo.description, curriculum, showInfo, setActiveTabs)
                                                    ) : (
                                                        <Text size="sm" c="dimmed" fs="italic">Détails de compréhension à venir...</Text>
                                                    )}
                                                </Box>
                                            </Accordion.Panel>
                                        </Accordion.Item>
                                    ))}
                                </Accordion>
                            </Box>
                        </Stack>
                      </Accordion.Panel>
                    </Accordion.Item>
                  ))}
                </Accordion>
              </Tabs.Panel>

              <Tabs.Panel value="acts">
                <Accordion variant="separated" value={expandedActivity} onChange={setExpandedActivity}>
                  {acts.map((a: any) => (
                    <Accordion.Item key={a.id} value={a.code + a.id} id={`act-accordion-${a.code + a.id}`}>
                      <Accordion.Control>
                        <Group justify="space-between" wrap="nowrap">
                            <Group gap="sm" wrap="nowrap">
                                <Badge color={a.type === 'SAE' ? 'orange' : a.type === 'STAGE' ? 'teal' : (a.type === 'PORTFOLIO' ? 'cyan' : 'grape')} size="sm" w={80} style={{ flexShrink: 0 }}>{a.type}</Badge>
                                <Text fw={600} size="sm" truncate>{a.code} : {a.label}</Text>
                            </Group>
                            <Group gap="xs" wrap="nowrap" style={{ flexShrink: 0 }}>
                                {a.hours > 0 && (
                                    <Badge size="xs" variant="light" color="gray" leftSection={<IconClock size={10} />}>{a.hours}h</Badge>
                                )}
                                <ActionIcon size="xs" variant="subtle" onClick={(e) => { e.stopPropagation(); setEditingAct(a); }}><IconPencil size={12} /></ActionIcon>
                            </Group>
                        </Group>
                      </Accordion.Control>
                      <Accordion.Panel>
                        <Grid>
                            <Grid.Col span={12}>
                                {a.description && (
                                    <Box mb="sm">
                                        <Text size="xs" fw={700} c="dimmed" mb={4}>OBJECTIFS ET CONTEXTE</Text>
                                        <Text size="sm" style={{ whiteSpace: 'pre-wrap', lineHeight: 1.5 }}>{a.description}</Text>
                                    </Box>
                                )}
                            </Grid.Col>

                            <Grid.Col span={6}>
                                <Text size="xs" fw={700} c="orange" mb={4}>RESSOURCES MOBILISÉES</Text>
                                <Group gap={6}>
                                    {a.resources ? a.resources.split(',').map((rCode: string) => {
                                        const code = rCode.trim();
                                        const resInfo = curriculum.resources?.find((r: any) => r.code === code);
                                        return (
                                            <Badge
                                                key={code}
                                                size="sm"
                                                variant="light"
                                                color="orange"
                                                style={{ cursor: 'pointer', textTransform: 'none' }}
                                                className="hover-badge"
                                                onClick={() => showInfo(resInfo || {code}, 'RES', a.pathway)}
                                                leftSection={<IconBook size={10} />}
                                            >
                                                {code}
                                            </Badge>
                                        );
                                    }) : <Text size="xs" c="dimmed" fs="italic">Aucune ressource</Text>}
                                </Group>
                            </Grid.Col>

                            <Grid.Col span={6}>
                                <Text size="xs" fw={700} c="blue" mb={4}>COMPÉTENCES (AC)</Text>
                                <Group gap={6}>
                                    {a.learning_outcomes?.length > 0 ? a.learning_outcomes.map((lo: any) => (
                                        <Badge
                                            key={lo.id}
                                            size="sm"
                                            variant="light"
                                            color="blue"
                                            style={{ cursor: 'pointer' }}
                                            className="hover-badge"
                                            onClick={() => setInfoItem({...lo, type: 'AC'})}
                                        >
                                            {lo.code}
                                        </Badge>
                                    )) : <Text size="xs" c="dimmed" fs="italic">Aucun AC lié</Text>}
                                </Group>
                            </Grid.Col>

                            <Grid.Col span={12}>
                                <Divider my="xs" variant="dotted" />
                                <Group gap="xl">
                                    <Group gap={4}>
                                        <IconCrown size={14} color="gold" />
                                        <Text size="xs" c="dimmed">Responsable : {professors?.find((p: any) => p.id === a.owner_id)?.full_name || 'Non assigné'}</Text>
                                    </Group>
                                    <Group gap={4}>
                                        <IconUsers size={14} color="gray" />
                                        <Text size="xs" c="dimmed">Intervenants : {a.intervenants?.length || 0}</Text>
                                    </Group>
                                </Group>
                            </Grid.Col>
                        </Grid>
                      </Accordion.Panel>
                    </Accordion.Item>
                  ))}
                </Accordion>
              </Tabs.Panel>

              <Tabs.Panel value="ress">
                <Accordion variant="separated" value={expandedResource} onChange={setExpandedResource}>
                    {curriculum.resources
                        ?.filter((r: any) => {
                            if (!r.code) return false;

                            // 1. Filter by Level
                            const codePrefix = parseInt(r.code.replace('R', '').split('.')[0]);
                            if (isNaN(codePrefix)) return false;
                            if (lvl === 1 && (codePrefix !== 1 && codePrefix !== 2)) return false;
                            if (lvl === 2 && (codePrefix !== 3 && codePrefix !== 4)) return false;
                            if (lvl === 3 && (codePrefix !== 5 && codePrefix !== 6)) return false;

                            // 2. Filter by Pathway
                            const currPathway = lvl === 1 ? 'Tronc Commun' : pathway;
                            if (pathway === 'TOUS') return true;
                            // Resources from BUT 1 are usually Tronc Commun
                            // Resources from BUT 2/3 are tagged by pathway OR Tronc Commun
                            return r.pathway === currPathway || r.pathway === 'Tronc Commun';
                        })
                        .sort((a: any, b: any) => {
                            // Extract semester and index from code R{sem}.{pathway}.{index} or R{sem}.{index}
                            // Examples: R3.01, R3.SME.15
                            const parseResCode = (code: string) => {
                                const parts = code.replace('R', '').split('.');
                                const sem = parseInt(parts[0]) || 0;
                                // Last part is usually the index
                                const idx = parseInt(parts[parts.length - 1]) || 0;
                                return { sem, idx };
                            };

                            const valA = parseResCode(a.code);
                            const valB = parseResCode(b.code);

                            if (valA.sem !== valB.sem) return valA.sem - valB.sem;
                            return valA.idx - valB.idx;
                        })
                        .map((r: any) => (
                        <Accordion.Item key={r.id} value={r.code + r.id} id={`accordion-${r.code + r.id}`}>
                            <Accordion.Control>
                                <Group justify="space-between" wrap="nowrap">
                                    <Group gap="sm" wrap="nowrap">
                                        <Badge color="teal" size="sm" w={60} style={{ flexShrink: 0 }}>{r.code}</Badge>
                                        <Text fw={600} size="sm" truncate>{r.label}</Text>
                                    </Group>
                                    <Group gap="xs" wrap="nowrap" style={{ flexShrink: 0 }}>
                                        {r.hours > 0 && (
                                            <Badge size="xs" variant="light" color="gray" leftSection={<IconClock size={10} />}>{r.hours}h</Badge>
                                        )}
                                        <Button size="compact-xs" variant="light" onClick={(e) => { e.stopPropagation(); showInfo(r, 'RES'); }}>Détail</Button>
                                    </Group>
                                </Group>
                            </Accordion.Control>
                            <Accordion.Panel>
                                <Stack gap="md">
                                    {(r.hours > 0 || r.hours_details) && (
                                        <Group>
                                            <Badge size="lg" color="blue" variant="filled" leftSection={<IconClock size={14} />}>Volume Horaire : {r.hours_details || `${r.hours}h`}</Badge>
                                        </Group>
                                    )}

                                    {r.description && (
                                        <Box>
                                            <Text size="xs" fw={700} c="dimmed" mb={4}>DESCRIPTIF & CONTRIBUTION</Text>
                                            <Text size="sm" style={{ whiteSpace: 'pre-wrap' }}>{r.description.includes('Mots clés :') ? r.description.split('Mots clés :')[0] : r.description}</Text>
                                        </Box>
                                    )}

                                    {r.content && (
                                        <Box>
                                            <Text size="xs" fw={700} c="dark" mb={4}>CONTENU PÉDAGOGIQUE</Text>
                                            <Text size="sm" style={{ whiteSpace: 'pre-wrap', lineHeight: 1.6, paddingLeft: 10, borderLeft: '2px solid #eee' }}>{r.content}</Text>
                                        </Box>
                                    )}

                                    {r.targeted_competencies && (
                                        <Box>
                                            <Text size="xs" fw={700} c="teal" mb={4}>COMPÉTENCES CIBLÉES</Text>
                                            <List size="xs" spacing={2} icon={<ThemeIcon color="teal" size={6} radius="xl"><IconPlus size={4}/></ThemeIcon>}>
                                                {r.targeted_competencies.split(',').map((comp: string, idx: number) => (
                                                    <List.Item key={idx}>{comp.trim()}</List.Item>
                                                ))}
                                            </List>
                                        </Box>
                                    )}

                                    {r.learning_outcomes?.length > 0 && (
                                        <Box>
                                            <Text size="xs" fw={700} c="blue" mb={4}>APPRENTISSAGES CRITIQUES CIBLÉS</Text>
                                            <List size="xs" spacing={2} icon={<ThemeIcon color="blue" size={6} radius="xl"><IconPlus size={4}/></ThemeIcon>}>
                                                {r.learning_outcomes.map((lo: any) => (
                                                    <List.Item key={lo.id}>
                                                        <b>{lo.code}</b> : {lo.label}
                                                    </List.Item>
                                                ))}
                                            </List>
                                        </Box>
                                    )}

                                    {r.description && r.description.includes('Mots clés :') && (
                                        <Box>
                                            <Text size="xs" fw={700} c="grape" mb={4}>MOTS CLÉS</Text>
                                            <Text size="sm" c="dimmed">{r.description.split('Mots clés :')[1].split('Volume')[0]}</Text>
                                        </Box>
                                    )}
                                </Stack>
                            </Accordion.Panel>
                        </Accordion.Item>
                    ))}
                </Accordion>
              </Tabs.Panel>
            </Tabs>
          </Paper>
        );
      })}
    </Container>
  );
}
