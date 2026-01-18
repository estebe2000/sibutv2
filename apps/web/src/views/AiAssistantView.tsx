import React, { useState } from 'react';
import { Container, Title, Text, Group, ThemeIcon, Paper, ScrollArea, TextInput, ActionIcon, Stack, Loader, Avatar, SimpleGrid, Alert } from '@mantine/core';
import { IconRobot, IconSend, IconUser, IconSchool, IconChecklist, IconBrain, IconSparkles } from '@tabler/icons-react';
import api from '../services/api';

interface Message {
    role: 'user' | 'bot';
    content: string;
}

const SimpleMarkdown = ({ content }: { content: string }) => {
    // Découpage simple pour gérer le gras et le code inline LaTeX
    const parts = content.split(/(\*\*.*?\*\*|\\(.*?\\))/g); 
    
    return (
        <span>
            {parts.map((part, i) => {
                if (part.startsWith('**') && part.endsWith('**')) {
                    return <strong key={i}>{part.slice(2, -2)}</strong>;
                }
                if (part.startsWith('\\(') && part.endsWith('\\)')) {
                    return <code key={i} style={{background: 'rgba(0,0,0,0.1)', padding: '2px 4px', borderRadius: 4, fontFamily: 'monospace'}}>{part.slice(2, -2)}</code>;
                }
                return part;
            })}
        </span>
    );
};

export function AiAssistantView() {
  const [messages, setMessages] = useState<Message[]>([
      { role: 'bot', content: "Bonjour ! Je suis l'assistant pédagogique du BUT TC. Comment puis-je vous aider aujourd'hui ? (Génération de cours, idées d'évaluation...)" }
  ]);
  const [input, setInput] = useState('');
  const [loading, setLoading] = useState(false);

  const handleSend = async () => {
      if (!input.trim()) return;
      const userMsg = input;
      setInput('');
      setMessages(prev => [...prev, { role: 'user', content: userMsg }]);
      setLoading(true);

      try {
          const res = await api.post('/ai/chat', { message: userMsg });
          setMessages(prev => [...prev, { role: 'bot', content: res.data.response }]);
      } catch (e) {
          console.error(e);
          setMessages(prev => [...prev, { role: 'bot', content: "Désolé, je rencontre des difficultés techniques pour joindre mon cerveau (Mistral)." }]);
      }
      setLoading(false);
  };

  return (
    <Container size="lg" py="xl">
        <Group mb="xl">
            <ThemeIcon size={40} radius="xl" variant="gradient" gradient={{ from: 'blue', to: 'cyan' }}>
            <IconRobot size={24} />
            </ThemeIcon>
            <div>
            <Title order={2}>Assistant Pédagogique IA</Title>
            <Text c="dimmed">Propulsé par Mistral Codestral</Text>
            </div>
        </Group>

        <Alert variant="light" color="blue" title="Fonctionnalité en cours de déploiement" icon={<IconSparkles />} mb="xl">
            Cet assistant est connecté au LLM Mistral pour répondre à vos questions. Les fonctionnalités avancées ci-dessous arriveront bientôt.
        </Alert>

        <SimpleGrid cols={{ base: 1, md: 3 }} spacing="lg" mb="xl">
            <Paper withBorder p="md" radius="md" shadow="sm">
            <ThemeIcon size="lg" radius="md" variant="light" color="indigo" mb="xs"><IconSchool size={20} /></ThemeIcon>
            <Text size="md" fw={500}>Génération de Contenu</Text>
            <Text size="xs" c="dimmed" mb="md">Créez des plans de cours et scénarios pédagogiques.</Text>
            </Paper>
            <Paper withBorder p="md" radius="md" shadow="sm">
            <ThemeIcon size="lg" radius="md" variant="light" color="teal" mb="xs"><IconChecklist size={20} /></ThemeIcon>
            <Text size="md" fw={500}>Grilles d'Évaluation</Text>
            <Text size="xs" c="dimmed" mb="md">Générez des critères basés sur le référentiel.</Text>
            </Paper>
            <Paper withBorder p="md" radius="md" shadow="sm">
            <ThemeIcon size="lg" radius="md" variant="light" color="grape" mb="xs"><IconBrain size={20} /></ThemeIcon>
            <Text size="md" fw={500}>Analyse de Cohérence</Text>
            <Text size="xs" c="dimmed" mb="md">Vérifiez l'alignement pédagogique.</Text>
            </Paper>
        </SimpleGrid>

        <Title order={3} mb="md">Discussion Interactive</Title>
        <Paper withBorder p="md" radius="md" shadow="sm" h={500} style={{ display: 'flex', flexDirection: 'column' }}>
            <ScrollArea style={{ flexGrow: 1 }} mb="md" type="always">
                <Stack gap="md" p="xs">
                    {messages.map((m, i) => (
                        <Group key={i} align="flex-start" justify={m.role === 'user' ? 'flex-end' : 'flex-start'}>
                            {m.role === 'bot' && <Avatar color="blue" radius="xl"><IconRobot size={20} /></Avatar>}
                            <Paper 
                                withBorder={m.role === 'bot'}
                                bg={m.role === 'user' ? 'blue' : 'gray.0'}
                                c={m.role === 'user' ? 'white' : 'dark'}
                                py="xs" px="md" radius="lg" 
                                style={{ maxWidth: '80%' }}
                            >
                                <Text size="sm" style={{ whiteSpace: 'pre-wrap' }}>
                                    <SimpleMarkdown content={m.content} />
                                </Text>
                            </Paper>
                            {m.role === 'user' && <Avatar color="gray" radius="xl"><IconUser size={20} /></Avatar>}
                        </Group>
                    ))}
                    {loading && (
                        <Group align="center">
                             <Avatar color="blue" radius="xl"><IconRobot size={20} /></Avatar>
                             <Loader size="xs" variant="dots" />
                        </Group>
                    )}
                </Stack>
            </ScrollArea>

            <Group>
                <TextInput 
                    placeholder="Posez votre question..." 
                    style={{ flexGrow: 1 }}
                    value={input}
                    onChange={(e) => setInput(e.target.value)}
                    onKeyDown={(e) => e.key === 'Enter' && handleSend()}
                    disabled={loading}
                />
                <ActionIcon size="lg" color="blue" variant="filled" onClick={handleSend} loading={loading}>
                    <IconSend size={18} />
                </ActionIcon>
            </Group>
        </Paper>
    </Container>
  );
}
