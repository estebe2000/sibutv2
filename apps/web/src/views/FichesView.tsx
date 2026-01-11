import React, { useState, useEffect } from 'react';
import { Container, Group, Title, Button, Paper, Grid, TextInput, Select, Text, ScrollArea, Table, Badge, Center, Loader } from '@mantine/core';
import { IconBook, IconInfoCircle, IconDownload } from '@tabler/icons-react';
import { notifications } from '@mantine/notifications';
import axios from 'axios';

// API URL (Relative for Nginx Gateway)
const API_URL = '/api';

export function FichesView() {
  const [fiches, setFiches] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [search, setSearch] = useState('');
  const [pathwayFilter, setPathwayFilter] = useState('TOUS');
  const [semesterFilter, setSemesterFilter] = useState('TOUS');

  const pathways = ['TOUS', 'Tronc Commun', 'BI', 'BDMRC', 'MDEE', 'MMPV', 'SME'];
  const semesters = ['TOUS', 'S1', 'S2', 'S3', 'S4', 'S5', 'S6'];

  useEffect(() => {
    fetchFiches();
  }, []);

  const fetchFiches = async () => {
    setLoading(true);
    try {
      const res = await axios.get(`${API_URL}/fiches/list`);
      setFiches(res.data);
    } catch (e) {
      notifications.show({ title: 'Erreur', message: 'Impossible de charger la liste des fiches', color: 'red' });
    }
    setLoading(false);
  };

  const filtered = fiches.filter(f => {
    const matchesSearch = f.name.toLowerCase().includes(search.toLowerCase()) || f.code?.toLowerCase().includes(search.toLowerCase());
    const matchesPathway = pathwayFilter === 'TOUS' || f.pathway === pathwayFilter;
    const matchesSemester = semesterFilter === 'TOUS' || f.semester === semesterFilter;
    return matchesSearch && matchesPathway && matchesSemester;
  });

  return (
    <Container size="xl">
      <Group justify="space-between" mb="xl">
        <Title order={2}>Fiches Pédagogiques PDF</Title>
        <Button variant="outline" onClick={fetchFiches} loading={loading}>Actualiser la liste</Button>
      </Group>

      <Paper withBorder p="md" shadow="sm" radius="md" mb="xl">
        <Grid align="flex-end">
          <Grid.Col span={4}>
            <TextInput label="Rechercher une fiche" placeholder="Ex: Marketing, SAE 1.01..." value={search} onChange={(e) => setSearch(e.target.value)} />
          </Grid.Col>
          <Grid.Col span={3}>
            <Select label="Filtrer par Parcours" data={pathways} value={pathwayFilter} onChange={(v) => setPathwayFilter(v || 'TOUS')} />
          </Grid.Col>
          <Grid.Col span={3}>
            <Select label="Filtrer par Semestre" data={semesters} value={semesterFilter} onChange={(v) => setSemesterFilter(v || 'TOUS')} />
          </Grid.Col>
          <Grid.Col span={2}>
            <Text size="xs" c="dimmed" ta="right">{filtered.length} fiches trouvées</Text>
          </Grid.Col>
        </Grid>
      </Paper>

      <Paper withBorder shadow="md" radius="md" p={0} style={{ overflow: 'hidden' }}>
        <ScrollArea h={600}>
          <Table striped highlightOnHover>
            <Table.Thead bg="gray.1">
              <Table.Tr>
                <Table.Th>Sem.</Table.Th>
                <Table.Th>Fiche</Table.Th>
                <Table.Th>Parcours</Table.Th>
                <Table.Th style={{ textAlign: 'right' }}>Actions</Table.Th>
              </Table.Tr>
            </Table.Thead>
            <Table.Tbody>
              {loading ? (
                <Table.Tr><Table.Td colSpan={4}><Center p="xl"><Loader size="sm" /></Center></Table.Td></Table.Tr>
              ) : filtered.length === 0 ? (
                <Table.Tr><Table.Td colSpan={4}><Center p="xl"><Text c="dimmed">Aucune fiche trouvée</Text></Center></Table.Td></Table.Tr>
              ) : filtered.map((f, i) => (
                <Table.Tr key={i}>
                  <Table.Td><Badge variant="light" color="blue">{f.semester}</Badge></Table.Td>
                  <Table.Td>
                    <Group gap="xs">
                      <IconBook size={16} color="gray" />
                      <Text size="sm" fw={500}>{f.name}</Text>
                    </Group>
                  </Table.Td>
                  <Table.Td><Text size="xs">{f.pathway}</Text></Table.Td>
                  <Table.Td>
                    <Group gap="xs" justify="flex-end">
                      <Button
                        size="compact-xs"
                        variant="subtle"
                        component="a"
                        href={`${API_URL}${f.url}`}
                        target="_blank"
                        leftSection={<IconInfoCircle size={12} />}
                      >
                        Aperçu
                      </Button>
                      <Button
                        size="compact-xs"
                        variant="light"
                        component="a"
                        href={`${API_URL}${f.url}`}
                        download
                        leftSection={<IconDownload size={12} />}
                      >
                        Télécharger
                      </Button>
                    </Group>
                  </Table.Td>
                </Table.Tr>
              ))}
            </Table.Tbody>
          </Table>
        </ScrollArea>
      </Paper>
    </Container>
  );
}
