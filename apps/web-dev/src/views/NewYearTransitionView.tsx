import React from 'react';
import { Container, Paper, Title, Text, List, ThemeIcon, Stack, Group, Timeline, Alert } from '@mantine/core';
import { IconCalendarPlus, IconArchive, IconUserUp, IconHistory, IconCircleCheck, IconInfoCircle } from '@tabler/icons-react';

export function NewYearTransitionView() {
    return (
        <Container size="md" py="xl">
            <Stack gap="lg">
                <Paper withBorder p="xl" radius="md" bg="orange.0" shadow="sm">
                    <Group>
                        <ThemeIcon size={50} radius="xl" color="orange" variant="filled">
                            <IconCalendarPlus size={30} />
                        </ThemeIcon>
                        <div>
                            <Title order={2}>Transition Nouvelle Année</Title>
                            <Text c="dimmed">Planification de la bascule académique et de l'archivage</Text>
                        </div>
                    </Group>
                </Paper>

                <Alert icon={<IconInfoCircle size={16} />} title="Feuille de Route" color="blue" radius="md">
                    Ce module permettra de gérer le passage à l'année universitaire suivante tout en préservant l'historique des étudiants sur une période de 5 ans.
                </Alert>

                <Paper withBorder p="xl" radius="md">
                    <Title order={3} mb="xl">Fonctionnalités Prévues</Title>
                    
                    <Timeline active={0} bulletSize={24} lineWidth={2}>
                        <Timeline.Item bullet={<IconArchive size={12} />} title="1. Archivage Longue Durée (5 ans)">
                            <Text size="sm" mt={4}>Sauvegarde complète des éléments des élèves nous quittant :</Text>
                            <List size="sm" withPadding mt={5}>
                                <List.Item>Diplômés en fin de BUT 3</List.Item>
                                <List.Item>Changements d'orientation ou départs</List.Item>
                                <List.Item>Conservation des Portfolios, Preuves et Évaluations</List.Item>
                            </List>
                        </Timeline.Item>

                        <Timeline.Item bullet={<IconUserUp size={12} />} title="2. Promotion des Étudiants">
                            <Text size="sm" mt={4}>Bascule automatique des cohortes :</Text>
                            <List size="sm" withPadding mt={5}>
                                <List.Item>BUT 1 → BUT 2</List.Item>
                                <List.Item>BUT 2 → BUT 3</List.Item>
                                <List.Item>Placement dans un groupe "X+1 par défaut" en attente de répartition</List.Item>
                            </List>
                        </Timeline.Item>

                        <Timeline.Item bullet={<IconHistory size={12} />} title="3. Remise à Zéro du Dispatching">
                            <Text size="sm" mt={4}>Nettoyage de la structure opérationnelle :</Text>
                            <List size="sm" withPadding mt={5}>
                                <List.Item>Effacement des groupes de l'année écoulée</List.Item>
                                <List.Item>Libération des intervenants et tuteurs</List.Item>
                                <List.Item>Initialisation du nouveau calendrier académique</List.Item>
                            </List>
                        </Timeline.Item>

                        <Timeline.Item bullet={<IconEye size={12} />} title="4. Viewer d'Années Précédentes">
                            <Text size="sm" mt={4}>Consultation des archives :</Text>
                            <List size="sm" withPadding mt={5}>
                                <List.Item>Interface de consultation pour les 5 dernières années</List.Item>
                                <List.Item>Recherche par nom ou par cohorte archivée</List.Item>
                                <List.Item>Possibilité d'extraire des duplicatas de portfolios</List.Item>
                            </List>
                        </Timeline.Item>
                    </Timeline>
                </Paper>

                <Paper withBorder p="md" radius="md" bg="gray.0">
                    <Text size="xs" c="dimmed" ta="center">
                        Note : Ces opérations seront irréversibles. Un système de double validation et de backup préalable sera mis en place avant activation.
                    </Text>
                </Paper>
            </Stack>
        </Container>
    );
}

// Pour éviter l'erreur de import
const IconEye = ({ size }: { size: number }) => <IconHistory size={size} />;
