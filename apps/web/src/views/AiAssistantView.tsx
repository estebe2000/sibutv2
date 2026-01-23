import React, { useState, useRef, useEffect } from 'react';
import { Container, Title, Text, Group, ThemeIcon, Paper, ScrollArea, Textarea, ActionIcon, Stack, Loader, Avatar, SimpleGrid, Alert, FileInput, Tooltip, Button, Badge, Chip, Box } from '@mantine/core';
import { IconRobot, IconSend, IconUser, IconSchool, IconChecklist, IconBrain, IconSparkles, IconTrash, IconFileUpload, IconFileCheck, IconBulb, IconRefresh } from '@tabler/icons-react';
import { useAiChat } from '../hooks/useAiChat';
import { notifications } from '@mantine/notifications';
import api from '../services/api';

// BIBLIOTHÈQUES STANDARDS
import ReactMarkdown from 'react-markdown';
import remarkMath from 'remark-math';
import rehypeKatex from 'rehype-katex';
import 'katex/dist/katex.min.css';

const QUICK_PROMPTS = [
    "Résume le programme du S1",
    "Quelles sont les compétences du BUT TC ?",
    "Explique moi la SAE 1.01",
    "Comment évaluer la compétence 'Vente' ?"
];

export function AiAssistantView() {
  const { messages, loading, fileName, clearChat, handleFileUpload, sendMessage, setFileContext, setFilename } = useAiChat();
  const [input, setInput] = useState('');
  const [ingesting, setIngesting] = useState(false);
  const scrollViewport = useRef<HTMLDivElement>(null);

  // Auto-scroll to bottom when messages change
  useEffect(() => {
    if (scrollViewport.current) {
        scrollViewport.current.scrollTo({ top: scrollViewport.current.scrollHeight, behavior: 'smooth' });
    }
  }, [messages, loading]);

  const onSend = () => {
      if (!input.trim()) return;
      sendMessage(input);
      setInput('');
  };

  const onKeyDown = (e: React.KeyboardEvent) => {
      if (e.key === 'Enter' && !e.shiftKey) {
          e.preventDefault();
          onSend();
      }
  };

  const handleIngest = async () => {
      setIngesting(true);
      try {
          await api.post('/ai/ingest');
          notifications.show({ title: 'Mise à jour lancée', message: 'L\'IA lit les documents en arrière-plan...', color: 'green' });
      } catch (e) {
          notifications.show({ title: 'Erreur', message: 'Impossible de lancer la mise à jour.', color: 'red' });
      }
      setIngesting(false);
  };

  return (
    <Container size="lg" py="xl">
        <Group justify="space-between" mb="xl">
            <Group>
                <ThemeIcon size={44} radius="md" variant="gradient" gradient={{ from: 'blue', to: 'cyan' }}>
                    <IconRobot size={26} />
                </ThemeIcon>
                <div>
                    <Title order={2}>Assistant Pédagogique IA</Title>
                    <Text size="sm" c="dimmed">Expert BUT Techniques de Commercialisation</Text>
                </div>
            </Group>
            <Group>
                <Button variant="light" leftSection={<IconRefresh size={16}/>} onClick={handleIngest} loading={ingesting}>
                    Mettre à jour l'IA
                </Button>
                <Button variant="subtle" color="red" leftSection={<IconTrash size={16}/>} onClick={clearChat}>
                    Réinitialiser
                </Button>
            </Group>
        </Group>

        <Alert variant="light" color="blue" title="IA Augmentée" icon={<IconSparkles />} mb="xl">
            L'assistant connaît le programme et les responsables. Vous pouvez aussi uploader un document pour analyse.
        </Alert>

        <SimpleGrid cols={{ base: 1, md: 3 }} spacing="lg" mb="xl">
            <Paper withBorder p="md" radius="md" shadow="xs" bg="blue.0">
                <ThemeIcon size="lg" radius="md" variant="light" color="blue" mb="xs"><IconSchool size={20} /></ThemeIcon>
                <Text size="sm" fw={700}>Pédagogie</Text>
                <Text size="xs" c="dimmed">Plans de cours & SAÉ.</Text>
            </Paper>
            <Paper withBorder p="md" radius="md" shadow="xs" bg="teal.0">
                <ThemeIcon size="lg" radius="md" variant="light" color="teal" mb="xs"><IconChecklist size={20} /></ThemeIcon>
                <Text size="sm" fw={700}>Évaluation</Text>
                <Text size="xs" c="dimmed">Grilles critériées AC.</Text>
            </Paper>
            <Paper withBorder p="md" radius="md" shadow="xs" bg="grape.0">
                <ThemeIcon size="lg" radius="md" variant="light" color="grape" mb="xs"><IconBrain size={20} /></ThemeIcon>
                <Text size="sm" fw={700}>Analyse</Text>
                <Text size="xs" c="dimmed">Cohérence du programme.</Text>
            </Paper>
        </SimpleGrid>

        <Title order={3} mb="md">Discussion Interactive</Title>
        <Paper withBorder radius="lg" shadow="md" h={600} style={{ display: 'flex', flexDirection: 'column', overflow: 'hidden' }}>
            <ScrollArea viewportRef={scrollViewport} style={{ flexGrow: 1 }} p="md" type="always" bg="gray.0">
                <Stack gap="xl" py="md">
                    {messages.map((m, i) => (
                        <Group key={i} align="flex-start" justify={m.role === 'user' ? 'flex-end' : 'flex-start'} wrap="nowrap">
                            {m.role === 'bot' && <Avatar color="blue" radius="xl" size="md"><IconRobot size={20} /></Avatar>}
                            <Paper 
                                withBorder={false} 
                                bg={m.role === 'user' ? 'blue.6' : 'white'} 
                                c={m.role === 'user' ? 'white' : 'dark.9'}
                                py="xs" px="md" radius="lg" 
                                shadow={m.role === 'bot' ? 'sm' : 'none'}
                                style={{ 
                                    maxWidth: '85%',
                                    borderBottomLeftRadius: m.role === 'bot' ? 0 : undefined,
                                    borderBottomRightRadius: m.role === 'user' ? 0 : undefined,
                                }}
                            >
                                <Box style={{ fontSize: '14px', lineHeight: '1.6' }} className="markdown-content">
                                    <ReactMarkdown 
                                        remarkPlugins={[remarkMath]} 
                                        rehypePlugins={[rehypeKatex]}
                                        components={{
                                            p: ({node, ...props}) => <p style={{margin: 0, marginBottom: '0.5em'}} {...props} />,
                                            ul: ({node, ...props}) => <ul style={{paddingLeft: '1.2em', margin: 0}} {...props} />,
                                            ol: ({node, ...props}) => <ol style={{paddingLeft: '1.2em', margin: 0}} {...props} />,
                                        }}
                                    >
                                        {m.content}
                                    </ReactMarkdown>
                                </Box>
                            </Paper>
                            {m.role === 'user' && <Avatar color="gray" radius="xl" size="md"><IconUser size={20} /></Avatar>}
                        </Group>
                    ))}
                    {loading && (
                        <Group align="center" gap="xs">
                             <Avatar color="blue" radius="xl" size="md"><IconRobot size={20} /></Avatar>
                             <Paper withBorder={false} py="xs" px="md" radius="lg" bg="white" shadow="sm" style={{ borderBottomLeftRadius: 0 }}>
                                <Group gap={4}>
                                    <Loader size={6} variant="dots" color="blue" />
                                    <Text size="xs" c="dimmed">En train d'écrire...</Text>
                                </Group>
                             </Paper>
                        </Group>
                    )}
                </Stack>
            </ScrollArea>

            <div style={{ padding: '15px', borderTop: '1px solid #e9ecef', background: 'white' }}>
                <Stack gap="xs">
                    {/* Quick Prompts */}
                    {messages.length < 3 && !loading && (
                        <Group gap="xs" mb="xs">
                            <ThemeIcon size="sm" variant="transparent" color="yellow"><IconBulb size={16} /></ThemeIcon>
                            <ScrollArea type="never">
                                <Group wrap="nowrap">
                                    {QUICK_PROMPTS.map((prompt, i) => (
                                        <Chip 
                                            key={i} 
                                            size="xs" 
                                            variant="outline" 
                                            onClick={() => { setInput(prompt); }} 
                                            styles={{ label: { cursor: 'pointer' } }}
                                            checked={false}
                                        >
                                            {prompt}
                                        </Chip>
                                    ))}
                                </Group>
                            </ScrollArea>
                        </Group>
                    )}

                    {fileName && (
                        <Group gap="xs">
                            <Badge color="green" variant="light" leftSection={<IconFileCheck size={12}/>} size="lg">
                                {fileName}
                            </Badge>
                            <ActionIcon size="sm" color="red" variant="subtle" onClick={() => {setFileContext(null); setFilename(null);}}>
                                <IconTrash size={14}/>
                            </ActionIcon>
                        </Group>
                    )}
                    
                    <Group gap="xs" align="flex-end">
                        <FileInput 
                            style={{ display: 'none' }} 
                            id="ai-file-upload" 
                            accept=".pdf,.txt"
                            onChange={(p) => handleFileUpload(p)} 
                        />
                        <Tooltip label="Joindre un document (PDF, TXT)">
                            <ActionIcon 
                                size={44}
                                variant="light" 
                                color="blue" 
                                radius="md"
                                onClick={() => document.getElementById('ai-file-upload')?.click()}
                                loading={loading}
                                mb={2}
                            >
                                <IconFileUpload size={22} />
                            </ActionIcon>
                        </Tooltip>
                        
                        <Textarea 
                            placeholder={fileName ? "Posez une question sur ce document..." : "Posez votre question à l'assistant..."} 
                            style={{ flexGrow: 1 }} 
                            minRows={1}
                            maxRows={4}
                            autosize
                            radius="md"
                            value={input}
                            onChange={(e) => setInput(e.target.value)}
                            onKeyDown={onKeyDown}
                            disabled={loading}
                        />
                        
                        <ActionIcon 
                            size={44} 
                            radius="md" 
                            color="blue" 
                            variant="filled" 
                            onClick={onSend} 
                            loading={loading}
                            disabled={!input.trim()}
                            mb={2}
                        >
                            <IconSend size={22} />
                        </ActionIcon>
                    </Group>
                    <Text size="xs" c="dimmed" ta="center">
                        L'IA peut faire des erreurs. Vérifiez les informations importantes.
                    </Text>
                </Stack>
            </div>
        </Paper>
    </Container>
  );
}