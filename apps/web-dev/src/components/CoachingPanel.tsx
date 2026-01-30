import React from 'react';
import { Stack, Title, Text, Paper, Accordion, Group, ThemeIcon, List, Alert, Button, Card, Divider, Badge } from '@mantine/core';
import { IconLamp, IconCertificate, IconSparkles, IconSearch, IconArrowRight, IconMessageDots } from '@tabler/icons-react';

export function CoachingPanel() {
    return (
        <Stack gap="xl">
            <Title order={3}>Centre de Coaching & IA</Title>

            {/* ASSISTANT IA PLACEHOLDER */}
            <Card withBorder padding="lg" radius="md" bg="blue.0" style={{ borderColor: 'var(--mantine-color-blue-3)' }}>
                <Group justify="space-between" mb="md">
                    <Group>
                        <ThemeIcon size="xl" radius="md" variant="gradient" gradient={{ from: 'blue', to: 'cyan' }}>
                            <IconSparkles size={24} />
                        </ThemeIcon>
                        <div>
                            <Text fw={700} size="lg">Assistant IA : Coach de Stage</Text>
                            <Text size="xs" c="dimmed">Module en cours de développement</Text>
                        </div>
                    </Group>
                    <Badge color="blue">Prochainement</Badge>
                </Group>
                
                <Text size="sm" mb="lg">
                    Bientôt, vous pourrez envoyer votre CV ici. L'intelligence artificielle analysera votre profil par rapport aux compétences du BUT TC et vous proposera :
                </Text>
                
                <List size="sm" spacing="xs" icon={<IconCheck size={14} color="var(--mantine-color-blue-6)" />}>
                    <List.Item>Des suggestions de mots-clés adaptés à votre parcours.</List.Item>
                    <List.Item>Un score de correspondance avec les offres locales.</List.Item>
                    <List.Item>Une aide à la rédaction de vos lettres de motivation.</List.Item>
                </List>

                <Button variant="light" mt="xl" fullWidth disabled leftSection={<IconMessageDots size={16}/>}>
                    Lancer l'analyse (Bientôt disponible)
                </Button>
            </Card>

            <Divider label="Conseils de recherche" labelPosition="center" />

            <Accordion variant="separated">
                <Accordion.Item value="cv">
                    <Accordion.Control icon={<IconCertificate size={20} color="orange" />}>Optimiser mon CV BUT TC</Accordion.Control>
                    <Accordion.Panel>
                        <Stack gap="sm">
                            <Text size="sm">Votre CV doit mettre en avant vos **SAÉ** (Situations d'Apprentissage et d'Évaluation). Ce sont vos expériences concrètes.</Text>
                            <List size="sm">
                                <List.Item>Utilisez les codes de compétences (ex: "C1 - Marketing") dans vos titres.</List.Item>
                                <List.Item>Listez les outils utilisés (Odoo, Canva, Suite Office, Google Analytics).</List.Item>
                                <List.Item>Indiquez clairement votre parcours (Marketing Digital, SME, etc.).</List.Item>
                            </List>
                        </Stack>
                    </Accordion.Panel>
                </Accordion.Item>

                <Accordion.Item value="recherche">
                    <Accordion.Control icon={<IconSearch size={20} color="blue" />}>Où chercher mon stage ?</Accordion.Control>
                    <Accordion.Panel>
                        <Text size="sm" mb="md">Ne vous limitez pas aux sites d'annonces. Utilisez le réseau !</Text>
                        <List size="sm">
                            <List.Item><b>Le Codex Entreprises</b> : Consultez la liste des entreprises ayant déjà pris des étudiants de l'IUT.</List.Item>
                            <List.Item><b>LinkedIn</b> : Suivez les entreprises locales du Havre et de Normandie.</List.Item>
                            <List.Item><b>Candidatures spontanées</b> : Préparez une liste de 20 entreprises cibles.</List.Item>
                        </List>
                    </Accordion.Panel>
                </Accordion.Item>

                <Accordion.Item value="entretien">
                    <Accordion.Control icon={<IconMessageDots size={20} color="green" />}>Réussir l'entretien</Accordion.Control>
                    <Accordion.Panel>
                        <Text size="sm">Soyez prêt à expliquer ce qu'est le BUT et vos objectifs de compétences. L'entreprise cherche quelqu'un d'opérationnel mais aussi en apprentissage.</Text>
                    </Accordion.Panel>
                </Accordion.Item>
            </Accordion>
        </Stack>
    );
}

const IconCheck = ({ size, color }: any) => (
    <ThemeIcon size={size} radius="xl" color="green" variant="light">
        <IconSparkles size={10} />
    </ThemeIcon>
);
