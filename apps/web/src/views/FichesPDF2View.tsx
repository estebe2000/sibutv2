import React, { useState } from 'react';
import { Container, Title, Paper, Grid, TextInput, Select, Text, ScrollArea, Table, Badge, Group, Button } from '@mantine/core';
import { IconFileText } from '@tabler/icons-react';

// API URL (Relative for Nginx Gateway)
const API_URL = '/api';

export function FichesPDF2View({ curriculum }: any) {
  const [search, setSearch] = useState('');
  const [typeFilter, setTypeFilter] = useState('TOUS');
  const [pathwayFilter, setPathwayFilter] = useState('TOUS');
  const [semesterFilter, setSemesterFilter] = useState('TOUS');

  const pathways = ['TOUS', 'Tronc Commun', 'BI', 'BDMRC', 'MDEE', 'MMPV', 'SME'];
  const types = ['TOUS', 'SAE', 'STAGE', 'PORTFOLIO', 'RESSOURCE'];
  const semesters = ['TOUS', '1', '2', '3', '4', '5', '6'];

  const allItems = [
    ...(curriculum.activities || []).map((a: any) => ({ ...a, it: 'ACT', displayType: a.type })),
    ...(curriculum.resources || []).map((r: any) => {
        // Infer semester from resource code (R1.01 -> S1)
        const semMatch = r.code.match(/R(\d)/);
        const sem = semMatch ? semMatch[1] : '0';
        return { ...r, it: 'RES', displayType: 'RESSOURCE', semester: parseInt(sem) };
    })
  ];

  const filtered = allItems.filter((item: any) => {
    const matchesSearch = item.code.toLowerCase().includes(search.toLowerCase()) ||
                          item.label.toLowerCase().includes(search.toLowerCase());
    const matchesType = typeFilter === 'TOUS' || (typeFilter === 'RESSOURCE' ? item.it === 'RES' : item.displayType === typeFilter);
    const matchesPathway = pathwayFilter === 'TOUS' || item.pathway === pathwayFilter;
    const matchesSemester = semesterFilter === 'TOUS' || item.semester.toString() === semesterFilter;
    return matchesSearch && matchesType && matchesPathway && matchesSemester;
  });

  return (
    <Container size="xl">
      <Title order={2} mb="xl">Génération de Fiches PDF à la volée</Title>

      <Paper withBorder p="md" shadow="sm" radius="md" mb="xl">
        <Grid align="flex-end">
          <Grid.Col span={3}>
            <TextInput label="Rechercher" placeholder="Code ou libellé..." value={search} onChange={(e) => setSearch(e.target.value)} />
          </Grid.Col>
          <Grid.Col span={2}>
            <Select label="Type" data={types} value={typeFilter} onChange={(v) => setTypeFilter(v || 'TOUS')} />
          </Grid.Col>
          <Grid.Col span={3}>
            <Select label="Parcours" data={pathways} value={pathwayFilter} onChange={(v) => setPathwayFilter(v || 'TOUS')} />
          </Grid.Col>
          <Grid.Col span={2}>
            <Select label="Semestre" data={semesters} value={semesterFilter} onChange={(v) => setSemesterFilter(v || 'TOUS')} />
          </Grid.Col>
          <Grid.Col span={2}>
            <Text size="xs" c="dimmed" ta="right">{filtered.length} éléments</Text>
          </Grid.Col>
        </Grid>
      </Paper>

      <Paper withBorder shadow="md" radius="md" p={0} style={{ overflow: 'hidden' }}>
        <ScrollArea h={600}>
          <Table striped highlightOnHover>
            <Table.Thead bg="gray.1">
              <Table.Tr>
                <Table.Th>Type</Table.Th>
                <Table.Th>Sem.</Table.Th>
                <Table.Th>Code</Table.Th>
                <Table.Th>Libellé</Table.Th>
                <Table.Th style={{ textAlign: 'right' }}>Action</Table.Th>
              </Table.Tr>
            </Table.Thead>
            <Table.Tbody>
              {filtered.map((item: any, i: number) => (
                <Table.Tr key={i}>
                  <Table.Td>
                    <Badge color={item.it === 'RES' ? 'teal' : 'orange'} size="sm" variant="light">
                      {item.displayType}
                    </Badge>
                  </Table.Td>
                  <Table.Td><Badge variant="outline" size="xs">S{item.semester}</Badge></Table.Td>
                  <Table.Td fw={700} size="sm">{item.code}</Table.Td>
                  <Table.Td><Text size="sm">{item.label}</Text></Table.Td>
                  <Table.Td>
                    <Group justify="flex-end">
                      <Button size="compact-xs" variant="light" leftSection={<IconFileText size={12} />} onClick={() => window.open(`${API_URL}/${item.it === 'RES' ? 'resources' : 'activities'}/${item.id}/pdf`, '_blank')}>
                        Générer PDF
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
