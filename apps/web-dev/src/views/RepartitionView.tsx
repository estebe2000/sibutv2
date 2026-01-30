import React, { useState } from 'react';
import { Container, Title, Tabs, Paper, ScrollArea, Table, Select, Group, Box, Badge, Center, Loader, Text } from '@mantine/core';
import { IconClock, IconDatabase } from '@tabler/icons-react';
import { useStore } from '../store/useStore';

export function RepartitionView({ curriculum }: any) {
  const { config } = useStore();
  if (!curriculum || !curriculum.activities) return <Center p="xl"><Loader /></Center>;

  const activePathwaysStr = config.find((c: any) => c.key === 'ACTIVE_PATHWAYS')?.value || 'BDMRC,BI,MDEE,MMPV,SME';
  const activePathways = activePathwaysStr.split(',').filter(Boolean);

  const [pathway, setPathway] = useState(activePathways[0] || 'SME');
  const [semester, setSemester] = useState('1');

  const pathways = activePathways;
  const semesters = ['1', '2', '3', '4', '5', '6'];

  const structureData = [
    { label: "Nbre d'heures d'enseignement (ressources + SAÉ)", s1: 375, s2: 375, s3: 355, s4: 225, s5: 365, s6: 105, total: 1800 },
    { label: "Dont % d'adaptation locale (max 40%)", s1: "27 %", s2: "27 %", s3: "36 %", s4: "40 %", s5: "37 %", s6: "48 %", total: "33 %" },
    { label: "Nbre d'heures d'enseignement définies localement", s1: 100, s2: 100, s3: 125, s4: 90, s5: 135, s6: 50, total: 600 },
    { label: "Nbre heures d'enseignement SAÉ définies localement", s1: 60, s2: 75, s3: 100, s4: 75, s5: 100, s6: 40, total: 450 },
    { label: "Nbre heures d'enseignement à définir localement (Res ou SAÉ)", s1: 40, s2: 25, s3: 25, s4: 15, s5: 35, s6: 10, total: 150 },
    { label: "Nbre heures d'enseignement ressources nationales", s1: 275, s2: 275, s3: 230, s4: 135, s5: 230, s6: 55, total: 1200 },
    { label: "Nbre heures de TP définies nationalement", s1: 86, s2: 77, s3: 61, s4: 40, s5: 72, s6: 17, total: 523 },
    { label: "Nbre heures de TP à définir localement", s1: 35, s2: 45, s3: 35, s4: 35, s5: 15, s6: 5, total: 170 },
    { label: "Nbre d'heures de projet tutoré", s1: 50, s2: 100, s3: 85, s4: 115, s5: 125, s6: 125, total: 600 },
    { label: "Nbre de semaines de stage", s1: 0, s2: "2 à 4", s3: 0, s4: 8, s5: 0, s6: "14 à 16", total: "24 à 26" },
  ];

  const semInt = parseInt(semester);
  const isCommon = semInt <= 2;

  const acts = (curriculum.activities?.filter((a: any) => a.semester === semInt && (isCommon || a.pathway === pathway || a.pathway === 'Tronc Commun')) || [])
                .sort((a: any, b: any) => a.code.localeCompare(b.code));

  const ress = (curriculum.resources?.filter((r: any) => {
      if (!r.code) return false;
      const codePrefix = parseInt(r.code.replace('R', '').split('.')[0]);
      if (codePrefix !== semInt) return false;
      return isCommon || r.pathway === pathway || r.pathway === 'Tronc Commun';
  }) || []).sort((a: any, b: any) => {
      const parseResCode = (code: string) => {
          const parts = code.replace('R', '').split('.');
          return parseInt(parts[parts.length - 1]) || 0;
      };
      return parseResCode(a.code) - parseResCode(b.code);
  });

  const lvl = semInt <= 2 ? 1 : (semInt <= 4 ? 2 : 3);
  const comps = (curriculum.competences?.filter((c: any) => c.level === lvl && (isCommon || c.pathway === pathway || c.pathway === 'Tronc Commun')) || [])
                .sort((a: any, b: any) => a.code.localeCompare(b.code));

  return (
    <Container size="xl">
      <Title order={2} mb="xl">Structure et Répartition des Heures</Title>

      <Tabs defaultValue="structure" variant="pills" mb="xl">
          <Tabs.List>
              <Tabs.Tab value="structure" leftSection={<IconClock size={16} />}>Tableau de Structure</Tabs.Tab>
              <Tabs.Tab value="cross" leftSection={<IconDatabase size={16} />}>Tableau Croisé (Matrice AC)</Tabs.Tab>
          </Tabs.List>

          <Tabs.Panel value="structure" pt="xl">
            <Paper withBorder shadow="md" radius="md" p="md">
                <ScrollArea>
                <Table striped highlightOnHover withBorder withColumnBorders verticalSpacing="sm">
                    <Table.Thead>
                    <Table.Tr bg="blue.7">
                        <Table.Th style={{ color: 'white' }}>Semestres</Table.Th>
                        <Table.Th style={{ color: 'white', textAlign: 'center' }}>S1</Table.Th>
                        <Table.Th style={{ color: 'white', textAlign: 'center' }}>S2</Table.Th>
                        <Table.Th style={{ color: 'white', textAlign: 'center' }}>S3</Table.Th>
                        <Table.Th style={{ color: 'white', textAlign: 'center' }}>S4</Table.Th>
                        <Table.Th style={{ color: 'white', textAlign: 'center' }}>S5</Table.Th>
                        <Table.Th style={{ color: 'white', textAlign: 'center' }}>S6</Table.Th>
                        <Table.Th style={{ color: 'white', textAlign: 'center' }}>TOTAL</Table.Th>
                    </Table.Tr>
                    </Table.Thead>
                    <Table.Tbody>
                    {structureData.map((row, idx) => (
                        <Table.Tr key={idx}>
                        <Table.Td fw={row.label.includes('TOTAL') ? 700 : 500}>{row.label}</Table.Td>
                        <Table.Td style={{ textAlign: 'center' }}>{row.s1}</Table.Td>
                        <Table.Td style={{ textAlign: 'center' }}>{row.s2}</Table.Td>
                        <Table.Td style={{ textAlign: 'center' }}>{row.s3}</Table.Td>
                        <Table.Td style={{ textAlign: 'center' }}>{row.s4}</Table.Td>
                        <Table.Td style={{ textAlign: 'center' }}>{row.s5}</Table.Td>
                        <Table.Td style={{ textAlign: 'center' }}>{(row as any).s6}</Table.Td>
                        <Table.Td style={{ textAlign: 'center', backgroundColor: '#f8f9fa' }} fw={700}>{row.total}</Table.Td>
                        </Table.Tr>
                    ))}
                    </Table.Tbody>
                </Table>
                </ScrollArea>
            </Paper>
          </Tabs.Panel>

          <Tabs.Panel value="cross" pt="xl">
              <Group mb="xl" gap="xl">
                  <Select label="Semestre" data={semesters} value={semester} onChange={(v) => setSemester(v || '1')} style={{ width: 120 }} />
                  {semInt > 2 && <Select label="Parcours" data={pathways} value={pathway} onChange={(v) => setPathway(v || 'SME')} style={{ width: 200 }} />}
              </Group>

              <Paper withBorder shadow="md" radius="md" p="md" bg="gray.0">
                  <ScrollArea h={600}>
                      <Table withBorder withColumnBorders verticalSpacing="xs" style={{ minWidth: 1000 }}>
                          <Table.Thead>
                              <Table.Tr bg="dark.6">
                                  <Table.Th style={{ color: 'white', minWidth: 250 }}>Apprentissages Critiques (AC)</Table.Th>
                                  {acts.map(a => (
                                      <Table.Th key={a.id} style={{ color: 'white', textAlign: 'center', fontSize: '10px' }}>
                                          <Box style={{ transform: 'rotate(-45deg)', height: 80, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                                              {a.code}
                                          </Box>
                                      </Table.Th>
                                  ))}
                                  {ress.map(r => (
                                      <Table.Th key={r.id} style={{ color: 'white', textAlign: 'center', fontSize: '10px' }}>
                                          <Box style={{ transform: 'rotate(-45deg)', height: 80, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                                              {r.code}
                                          </Box>
                                      </Table.Th>
                                  ))}
                              </Table.Tr>
                          </Table.Thead>
                          <Table.Tbody>
                              {comps.map(c => (
                                  <React.Fragment key={c.id}>
                                      <Table.Tr bg="blue.0">
                                          <Table.Td colSpan={1 + acts.length + ress.length} fw={700} size="sm">
                                              {c.code} : {c.label}
                                          </Table.Td>
                                      </Table.Tr>
                                      {c.learning_outcomes?.map((lo: any) => (
                                          <Table.Tr key={lo.id} bg="white">
                                              <Table.Td style={{ fontSize: '11px' }}><b>{lo.code}</b> : {lo.label}</Table.Td>
                                              {acts.map(a => {
                                                  const isLinked = a.learning_outcomes?.some((alc: any) => lo.code.startsWith(alc.code.substring(0,7)));
                                                  return <Table.Td key={a.id} style={{ textAlign: 'center' }}>{isLinked ? <Badge color="orange" size="xs">X</Badge> : null}</Table.Td>
                                              })}
                                              {ress.map(r => {
                                                  const isLinked = r.learning_outcomes?.some((rlc: any) => lo.code.startsWith(rlc.code.substring(0,7)));
                                                  return <Table.Td key={r.id} style={{ textAlign: 'center' }}>{isLinked ? <Badge color="teal" size="xs">X</Badge> : null}</Table.Td>
                                              })}
                                          </Table.Tr>
                                      ))}
                                  </React.Fragment>
                              ))}

                              <Table.Tr bg="gray.1">
                                  <Table.Td fw={700}>Volume Horaire (H)</Table.Td>
                                  {acts.map(a => <Table.Td key={a.id} style={{ textAlign: 'center', fontSize: '10px' }}>{a.hours > 0 ? a.hours : '-'}</Table.Td>)}
                                  {ress.map(r => <Table.Td key={r.id} style={{ textAlign: 'center', fontSize: '10px' }}>{r.hours}</Table.Td>)}
                              </Table.Tr>
                              <Table.Tr bg="gray.1">
                                  <Table.Td fw={700}>Dont TP (H)</Table.Td>
                                  {acts.map(a => <Table.Td key={a.id} style={{ textAlign: 'center' }}>-</Table.Td>)}
                                  {ress.map(r => {
                                      const tpMatch = r.hours_details?.match(/(\d+)\s*heures\s*de\s*TP/i);
                                      return <Table.Td key={r.id} style={{ textAlign: 'center', fontSize: '10px' }}>{tpMatch ? tpMatch[1] : '-'}</Table.Td>
                                  })}
                              </Table.Tr>
                          </Table.Tbody>
                      </Table>
                  </ScrollArea>
              </Paper>
          </Tabs.Panel>
      </Tabs>

      <Box mt="md">
          <Text size="xs" c="dimmed" italic>Source : Programme National B.U.T. Techniques de Commercialisation - Page 63 et tableaux croisés par semestre.</Text>
      </Box>
    </Container>
  );
}
