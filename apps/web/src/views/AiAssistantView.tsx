import React from 'react';
import { Container, Title, Text, SimpleGrid, Paper, ThemeIcon, Button, Group, Alert, Timeline } from '@mantine/core';
import { IconRobot, IconSchool, IconChecklist, IconBrain, IconMessageChatbot, IconSparkles, IconDatabase } from '@tabler/icons-react';

export function AiAssistantView() {
  return (
    <Container size="lg" py="xl">
      <Group mb="xl">
        <ThemeIcon size={40} radius="xl" variant="gradient" gradient={{ from: 'blue', to: 'cyan' }}>
          <IconRobot size={24} />
        </ThemeIcon>
        <div>
          <Title order={2}>Assistant Pédagogique IA</Title>
          <Text c="dimmed">Votre copilote intelligent pour le BUT TC</Text>
        </div>
      </Group>

      <Alert variant="light" color="blue" title="Fonctionnalité en cours de déploiement" icon={<IconSparkles />} mb="xl">
        Cet assistant est actuellement en phase de pré-lancement. Il sera bientôt connecté à l'ensemble du référentiel de compétences pour vous assister au quotidien.
      </Alert>

      <SimpleGrid cols={{ base: 1, md: 3 }} spacing="lg" mb={50}>
        <Paper withBorder p="xl" radius="md" shadow="sm">
          <ThemeIcon size="lg" radius="md" variant="light" color="indigo" mb="md">
            <IconSchool size={20} />
          </ThemeIcon>
          <Text size="lg" fw={500} mt="md" mb="xs">Génération de Contenu</Text>
          <Text size="sm" c="dimmed" mb="md">
            Créez des plans de cours, des scénarios de SAÉ ou des exercices adaptés aux niveaux taxonomiques des compétences ciblées.
          </Text>
          <Button variant="light" fullWidth disabled>Bientôt disponible</Button>
        </Paper>

        <Paper withBorder p="xl" radius="md" shadow="sm">
          <ThemeIcon size="lg" radius="md" variant="light" color="teal" mb="md">
            <IconChecklist size={20} />
          </ThemeIcon>
          <Text size="lg" fw={500} mt="md" mb="xs">Grilles d'Évaluation</Text>
          <Text size="sm" c="dimmed" mb="md">
            Générez automatiquement des grilles critériées basées sur les Composantes Essentielles et les Apprentissages Critiques du référentiel.
          </Text>
          <Button variant="light" fullWidth disabled>Bientôt disponible</Button>
        </Paper>

        <Paper withBorder p="xl" radius="md" shadow="sm">
          <ThemeIcon size="lg" radius="md" variant="light" color="grape" mb="md">
            <IconBrain size={20} />
          </ThemeIcon>
          <Text size="lg" fw={500} mt="md" mb="xs">Analyse de Cohérence</Text>
          <Text size="sm" c="dimmed" mb="md">
            Vérifiez l'alignement pédagogique entre vos objectifs, vos méthodes d'évaluation et les ressources mobilisées.
          </Text>
          <Button variant="light" fullWidth disabled>Bientôt disponible</Button>
        </Paper>
      </SimpleGrid>

      <Title order={3} mb="lg">Comment ça marche ?</Title>
      <Timeline active={1} bulletSize={24} lineWidth={2}>
        <Timeline.Item bullet={<IconDatabase size={12} />} title="Indexation du Référentiel">
          <Text c="dimmed" size="sm">L'IA analyse l'ensemble des fiches ressources, SAÉ et compétences du BUT TC pour comprendre le contexte.</Text>
        </Timeline.Item>

        <Timeline.Item bullet={<IconMessageChatbot size={12} />} title="Interface Chat">
          <Text c="dimmed" size="sm">Vous posez une question en langage naturel : "Propose-moi une SAÉ de niveau 2 mêlant Marketing et Droit".</Text>
        </Timeline.Item>

        <Timeline.Item title="Génération Contextuelle" lineVariant="dashed">
          <Text c="dimmed" size="sm">L'assistant propose un contenu structuré respectant les contraintes horaires et les coefficients.</Text>
        </Timeline.Item>

        <Timeline.Item title="Export & Intégration">
          <Text c="dimmed" size="sm">Vous pouvez exporter le résultat en PDF ou l'intégrer directement dans vos fiches modules.</Text>
        </Timeline.Item>
      </Timeline>
    </Container>
  );
}
