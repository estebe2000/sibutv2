import React, { useState } from 'react';
import { Container, Group, Stack, Title, Text, Select, Paper, Grid, Card, ThemeIcon, List, Badge, Modal, Center, Loader, Box, Divider } from '@mantine/core';
import { IconUsers, IconShieldCheck, IconPlus } from '@tabler/icons-react';
import api from '../services/api';
import { useStore } from '../store/useStore';
import { renderRichText } from '../components/RichTextRenderer';

export function DiscoveryView({ curriculum }: any) {
  const { config } = useStore();
  if (!curriculum || !curriculum.competences) return <Center p="xl"><Loader /></Center>;

  const activePathwaysStr = config.find((c: any) => c.key === 'ACTIVE_PATHWAYS')?.value || 'BDMRC,BI,MDEE,MMPV,SME';
  const activePathways = activePathwaysStr.split(',').filter(Boolean);

  const [pathway, setPathway] = useState(activePathways[0] || 'SME');
  const [selectedCompCode, setSelectedCompCode] = useState('C1');
  const [infoItem, setInfoItem] = useState<any>(null);
  const [infoLoading, setInfoLoading] = useState(false);

  const pathways = activePathways;
  const years = [1, 2, 3];
  const compCodes = ['C1', 'C2', 'C3', 'C4', 'C5'];

  const showInfo = async (item: any, type: 'RES' | 'AC') => {
    setInfoLoading(true);
    setInfoItem({ ...item, type });
    try {
        if (type === 'RES') {
            const res = await api.get(`/resources/${item.code.trim()}`);
            setInfoItem({ ...res.data, type });
        }
    } catch (e) {
        setInfoItem({ ...item, type, error: 'Détails non trouvés' });
    }
    setInfoLoading(false);
  };

  const getCompInfo = (code: string, year: number) => {
    const p = (code === 'C1' || code === 'C2' || code === 'C3' || year === 1) ? 'Tronc Commun' : pathway;
    if (code === 'C3' && year === 3) return null;

    const comp = curriculum.competences.find((c: any) =>
        c.code.startsWith(code) &&
        c.level === year &&
        (c.pathway === p || (year > 1 && c.pathway === pathway && c.code.startsWith(code)))
    );

    const focusMapping: any = {
        'C1': { 1: 'Construire une offre simple', 2: 'Offre complexe ou innovante', 3: 'Solution client étendue' },
        'C2': { 1: 'Préparer l\'entretien de vente', 2: 'Mener un entretien simple', 3: 'Mener une vente complexe' },
        'C3': { 1: 'Structurer un plan de com', 2: 'Élaborer un plan de com', 3: '' },
        'SME': {
            'C4': { 2: 'Déployer l\'image de marque', 3: 'Construire la stratégie de marque' },
            'C5': { 2: 'Élaborer un événement simple', 3: 'Élaborer un évènement complexe' }
        },
        'MMPV': {
            'C4': { 2: 'Gérer l\'équipe (opérationnel)', 3: 'Mobiliser l\'équipe (stratégique)' },
            'C5': { 2: 'Contribuer à la dynamique', 3: 'Manager la dynamique' }
        },
        'MDEE': {
            'C4': { 2: 'Participer au projet digital', 3: 'Développer le projet digital' },
            'C5': { 2: 'Partie prenante e-business', 3: 'Responsable e-business' }
        },
        'BI': {
            'C4': { 2: 'Assistant dév import/export', 3: 'Chargé de dév import/export' },
            'C5': { 2: 'Commercialiser offre simple', 3: 'Commercialiser offre complexe' }
        },
        'BDMRC': {
            'C4': { 2: 'Membre équipe commerciale', 3: 'Responsable équipe commerciale' },
            'C5': { 2: 'Membre équipe relation client', 3: 'Responsable équipe relation client' }
        }
    };

    let focus = "";
    if (code === 'C1' || code === 'C2' || code === 'C3') focus = focusMapping[code][year];
    else if (focusMapping[pathway] && focusMapping[pathway][code]) focus = focusMapping[pathway][code][year];

    if (!comp) return null;

    // Sort ACs by code alphabetically
    if (comp.learning_outcomes) {
        comp.learning_outcomes.sort((a: any, b: any) => a.code.localeCompare(b.code));
    }

    return { comp, focus };
  };

  const selectedData = {
      code: selectedCompCode,
      title: selectedCompCode === 'C1' ? 'Marketing' :
             selectedCompCode === 'C2' ? 'Vente' :
             selectedCompCode === 'C3' ? 'Communication' :
             selectedCompCode === 'C4' ? (pathway === 'SME' ? 'Branding' : pathway === 'MMPV' ? 'Management' : pathway === 'MDEE' ? 'Marketing Digital' : pathway === 'BI' ? 'Stratégie Inter' : 'Business Dév') :
             (pathway === 'SME' ? 'Evénementiel' : pathway === 'MMPV' ? 'Retail' : pathway === 'MDEE' ? 'E-Business' : pathway === 'BI' ? 'Opérations Inter' : 'Relation Client'),
      baseInfo: (getCompInfo(selectedCompCode, 2) || getCompInfo(selectedCompCode, 1))?.comp,
      levels: [
          getCompInfo(selectedCompCode, 1),
          getCompInfo(selectedCompCode, 2),
          getCompInfo(selectedCompCode, 3)
      ].filter(l => l !== null) as any[]
  };

  return (
    <Container size="xl">
      <Group justify="space-between" mb="xl">
        <Stack gap={0}>
            <Title order={2}>Roadmap de Formation</Title>
            <Text c="dimmed">Découvrez la progression des compétences par parcours</Text>
        </Stack>
        <Select
            label="Choisir un parcours"
            data={pathways}
            value={pathway}
            onChange={(v) => setPathway(v || 'SME')}
            style={{ width: 250 }}
        />
      </Group>

      <Paper withBorder p="md" shadow="md" radius="md" bg="white">
        <Grid gutter="md">
            <Grid.Col span={{ base: 12, md: 3 }}></Grid.Col>
            {years.map(y => (
                <Grid.Col span={{ base: 12, md: 3 }} key={y}>
                    <Paper p="xs" shadow="xs" radius="md" bg="blue.7" style={{ textAlign: 'center' }}>
                        <Text fw={700} c="white">BUT {y}</Text>
                    </Paper>
                </Grid.Col>
            ))}

            {compCodes.map(code => (
                <Grid.Col span={12} key={code}>
                    <Grid gutter="md" align="stretch">
                        <Grid.Col span={{ base: 12, md: 3 }}>
                            <Paper p="sm" h="100%" withBorder shadow="xs" radius="md"
                                   onClick={() => setSelectedCompCode(code)}
                                   style={{
                                       display: 'flex', alignItems: 'center', cursor: 'pointer',
                                       backgroundColor: selectedCompCode === code ? 'var(--mantine-color-blue-0)' : 'white',
                                       borderColor: selectedCompCode === code ? 'var(--mantine-color-blue-6)' : 'var(--mantine-color-gray-3)'
                                   }}>
                                <Group gap="sm">
                                    <Badge size="lg" radius="sm" variant="filled" color={code === 'C4' || code === 'C5' ? 'teal' : 'blue'}>{code}</Badge>
                                    <Text fw={700} size="sm">
                                        {code === 'C1' ? 'Marketing' :
                                         code === 'C2' ? 'Vente' :
                                         code === 'C3' ? 'Communication' :
                                         code === 'C4' ? (pathway === 'SME' ? 'Branding' : pathway === 'MMPV' ? 'Management' : pathway === 'MDEE' ? 'Marketing Digital' : pathway === 'BI' ? 'Stratégie Inter' : 'Business Dév') :
                                         (pathway === 'SME' ? 'Evénementiel' : pathway === 'MMPV' ? 'Retail' : pathway === 'MDEE' ? 'E-Business' : pathway === 'BI' ? 'Opérations Inter' : 'Relation Client')}
                                    </Text>
                                </Group>
                            </Paper>
                        </Grid.Col>
                        {years.map(y => {
                            const info = getCompInfo(code, y);
                            if (!info) return <Grid.Col span={{ base: 12, md: 3 }} key={y}></Grid.Col>;
                            return (
                                <Grid.Col span={{ base: 12, md: 3 }} key={y}>
                                    <Card withBorder shadow="sm" radius="md" h="100%" padding="xs"
                                          onClick={() => setSelectedCompCode(code)}
                                          style={{
                                              cursor: 'pointer',
                                              borderLeft: `4px solid var(--mantine-color-${code === 'C4' || code === 'C5' ? 'teal' : 'blue'}-6)`,
                                              backgroundColor: selectedCompCode === code ? 'var(--mantine-color-gray-0)' : 'white'
                                          }}>
                                        <Stack gap={4}>
                                            <Text size="xs" fw={700} c="dimmed">Niveau {y}</Text>
                                            <Text size="sm" fw={600} style={{ lineHeight: 1.2 }}>{info.focus}</Text>
                                        </Stack>
                                    </Card>
                                </Grid.Col>
                            );
                        })}
                    </Grid>
                </Grid.Col>
            ))}
        </Grid>
      </Paper>

      {/* DETAILED FICHE (PAGE 18 STYLE) */}
      <Paper withBorder mt={50} shadow="xl" radius="lg" p={0} style={{ overflow: 'hidden' }}>
          <Group bg={selectedCompCode === 'C4' || selectedCompCode === 'C5' ? 'teal.7' : 'blue.7'} p="xl" justify="space-between">
              <Group gap="xl">
                  <ThemeIcon size={60} radius="md" color="white" c={selectedCompCode === 'C4' || selectedCompCode === 'C5' ? 'teal.7' : 'blue.7'}>
                      <Title order={2}>{selectedCompCode}</Title>
                  </ThemeIcon>
                  <Stack gap={0}>
                      <Title order={2} c="white" tt="uppercase">{selectedData.title}</Title>
                      <Text size="lg" c="white" fw={500} style={{ opacity: 0.9 }}>{selectedData.baseInfo?.description || 'Référentiel de compétences'}</Text>
                  </Stack>
              </Group>
          </Group>

          <Grid gutter={0}>
              {/* Situations Pro & CE */}
              <Grid.Col span={12} p="xl" bg="gray.0">
                  <Grid gutter="xl">
                      <Grid.Col span={6}>
                          <Group mb="md">
                              <ThemeIcon color="blue" variant="light"><IconUsers size={18} /></ThemeIcon>
                              <Text fw={700} tt="uppercase">Situations Professionnelles</Text>
                          </Group>
                          <Paper withBorder p="md" radius="md" bg="white">
                              {selectedData.baseInfo?.situations_pro ? (
                                  <List spacing="sm" size="sm" icon={<ThemeIcon color="blue" size={6} radius="xl"><IconPlus size={4}/></ThemeIcon>}>
                                      {selectedData.baseInfo.situations_pro.split('\n').map((s: string, i: number) => (
                                          <List.Item key={i}>{s.trim()}</List.Item>
                                      ))}
                                  </List>
                              ) : <Text c="dimmed" fs="italic">Non définies</Text>}
                          </Paper>
                      </Grid.Col>
                      <Grid.Col span={6}>
                          <Group mb="md">
                              <ThemeIcon color="teal" variant="light"><IconShieldCheck size={18} /></ThemeIcon>
                              <Text fw={700} tt="uppercase">Composantes Essentielles</Text>
                          </Group>
                          <Paper withBorder p="md" radius="md" bg="white">
                              <List spacing="xs" size="xs">
                                  {selectedData.baseInfo?.essential_components?.map((ce: any) => (
                                      <List.Item key={ce.id}><b>{ce.code}</b> : {ce.label}</List.Item>
                                  ))}
                              </List>
                          </Paper>
                      </Grid.Col>
                  </Grid>
              </Grid.Col>

              {/* Learning Outcomes Table (The heart of page 18) */}
              <Grid.Col span={12} p="xl">
                  <Title order={4} mb="xl" c="blue" tt="uppercase" style={{ textAlign: 'center' }}>Progression des Apprentissages Critiques (AC)</Title>
                  <Grid gutter="md" justify="center">
                      {selectedData.levels.map((lvlData: any, idx: number) => (
                          <Grid.Col span={selectedData.levels.length === 2 ? 6 : 4} key={idx}>
                              <Paper withBorder h="100%" shadow="sm" radius="md">
                                  <Paper p="xs" bg="blue.7" style={{ borderRadius: '8px 8px 0 0', textAlign: 'center' }}>
                                      <Text c="white" fw={700} size="sm">NIVEAU {lvlData.comp.level}</Text>
                                      <Text c="white" size="xs" italic>{lvlData.focus}</Text>
                                  </Paper>
                                  <Stack p="md" gap="xs">
                                      {lvlData.comp?.learning_outcomes?.sort((a: any, b: any) => a.code.localeCompare(b.code)).map((lo: any) => (
                                          <Paper key={lo.id} withBorder p="xs" bg="gray.0" style={{ cursor: 'pointer' }}
                                                 onClick={() => showInfo(lo, 'AC')}>
                                              <Group gap="xs" wrap="nowrap" align="flex-start">
                                                  <Badge size="xs" variant="filled" style={{ flexShrink: 0 }}>{lo.code}</Badge>
                                                  <Text size="xs" fw={500}>{lo.label}</Text>
                                              </Group>
                                          </Paper>
                                      ))}
                                  </Stack>
                              </Paper>
                          </Grid.Col>
                      ))}
                  </Grid>
              </Grid.Col>
          </Grid>
      </Paper>

      {/* MODAL FOR DISCOVERY */}
      <Modal opened={!!infoItem} onClose={() => setInfoItem(null)} title={infoItem?.code || "Infos"} size={infoItem?.type === 'AC' ? "lg" : "md"}>
        {infoLoading ? <Center p="xl"><Loader /></Center> : infoItem && (
            <Stack>
                <Title order={4} c="blue">{infoItem.label || infoItem.code}</Title>
                <Divider />
                {infoItem.error ? <Text c="red">{infoItem.error}</Text> : (
                    <Box>
                        {infoItem.type === 'AC' ? (
                            renderRichText(infoItem.description, curriculum, showInfo, () => {})
                        ) : (
                            <Box>
                                <Text size="sm" fw={700} mb={4}>Résumé :</Text>
                                <Box>
                                    {renderRichText(infoItem.description?.includes('Mots clés :') ? infoItem.description.split('Mots clés :')[0] : infoItem.description, curriculum, showInfo, () => {})}
                                </Box>
                            </Box>
                        )}
                    </Box>
                )}
            </Stack>
        )}
      </Modal>
    </Container>
  );
}
