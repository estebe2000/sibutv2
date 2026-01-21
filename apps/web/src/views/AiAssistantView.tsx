import React, { useState } from 'react';
import { Container, Title, Text, Group, ThemeIcon, Paper, ScrollArea, TextInput, ActionIcon, Stack, Loader, Avatar, SimpleGrid, Alert, FileInput, Tooltip, Button, Badge } from '@mantine/core';
import { IconRobot, IconSend, IconUser, IconSchool, IconChecklist, IconBrain, IconSparkles, IconTrash, IconFileUpload, IconFileCheck } from '@tabler/icons-react';
import api from '../services/api';

// BIBLIOTHÈQUES STANDARDS
import ReactMarkdown from 'react-markdown';
import remarkMath from 'remark-math';
import rehypeKatex from 'rehype-katex';
import 'katex/dist/katex.min.css';

interface Message {
    role: 'user' | 'bot';
    content: string;
}

export function AiAssistantView() {
  const INITIAL_MESSAGE: Message = { role: 'bot', content: "Bonjour ! Je suis l'assistant pédagogique du BUT TC. Comment puis-je vous aider aujourd'hui ?" };
  
  const [messages, setMessages] = useState<Message[]>([INITIAL_MESSAGE]);
  const [input, setInput] = useState('');
  const [loading, setLoading] = useState(false);
  const [fileContext, setFileContext] = useState<string | null>(null);
  const [fileName, setFilename] = useState<string | null>(null);

  const clearChat = () => {
      setMessages([INITIAL_MESSAGE]);
      setFileContext(null);
      setFilename(null);
  };

  const handleFileUpload = async (file: File | null) => {
      if (!file) return;
      setLoading(true);
      const formData = new FormData();
      formData.append('file', file);
      try {
          const res = await api.post('/ai/extract-text', formData);
          setFileContext(res.data.text);
          setFilename(res.data.filename);
          setMessages(prev => [...prev, { role: 'bot', content: `Document **${res.data.filename}** ajouté au contexte.` }]);
      } catch (e) {
          console.error(e);
          setMessages(prev => [...prev, { role: 'bot', content: "Erreur lors de la lecture du fichier." }]);
      }
      setLoading(false);
  };

  const handleSend = async () => {
      if (!input.trim() || loading) return;
      const userMsg: Message = { role: 'user', content: input };
      const newHistory = [...messages, userMsg];
      setMessages(newHistory);
      setInput('');
      setLoading(true);

      try {
          // On retire le message de bienvenue pour l'IA
          const historyToSend = newHistory.slice(1);
          
          const res = await api.post('/ai/chat', { 
              messages: historyToSend.map(m => ({
                  role: m.role === 'bot' ? 'assistant' : 'user',
                  content: m.content
              })),
              file_context: fileContext
          });
          setMessages(prev => [...prev, { role: 'bot', content: res.data.response }]);
      } catch (e: any) {
          console.error(e);
          setMessages(prev => [...prev, { role: 'bot', content: "Désolé, je rencontre des difficultés techniques." }]);
      }
      setLoading(false);
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
            <Button variant="subtle" color="red" leftSection={<IconTrash size={16}/>} onClick={clearChat}>
                Réinitialiser
            </Button>
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
        <Paper withBorder radius="lg" shadow="md" h={500} style={{ display: 'flex', flexDirection: 'column', overflow: 'hidden' }}>
            <ScrollArea style={{ flexGrow: 1 }} p="md" type="always">
                <Stack gap="xl" py="md">
                    {messages.map((m, i) => (
                        <Group key={i} align="flex-start" justify={m.role === 'user' ? 'flex-end' : 'flex-start'} wrap="nowrap">
                            {m.role === 'bot' && <Avatar color="blue" radius="md" size="md"><IconRobot size={20} /></Avatar>}
                            <Paper 
                                withBorder={m.role === 'bot'} 
                                bg={m.role === 'user' ? 'blue.6' : 'white'} 
                                c={m.role === 'user' ? 'white' : 'dark.8'}
                                py="sm" px="md" radius="lg" 
                                style={{ 
                                    maxWidth: '85%',
                                    boxShadow: m.role === 'bot' ? '0 2px 12px rgba(0,0,0,0.04)' : 'none'
                                }}
                            >
                                <div style={{ fontSize: '14px', lineHeight: '1.6' }}>
                                    <ReactMarkdown 
                                        remarkPlugins={[remarkMath]} 
                                        rehypePlugins={[rehypeKatex]}
                                    >
                                        {m.content}
                                    </ReactMarkdown>
                                </div>
                            </Paper>
                            {m.role === 'user' && <Avatar color="gray" radius="md" size="md"><IconUser size={20} /></Avatar>}
                        </Group>
                    ))}
                    {loading && (
                        <Group align="center" gap="xs">
                             <Avatar color="blue" radius="md" size="md"><IconRobot size={20} /></Avatar>
                             <Paper withBorder py="xs" px="md" radius="lg" bg="white">
                                <Loader size="xs" variant="dots" />
                             </Paper>
                        </Group>
                    )}
                </Stack>
            </ScrollArea>

            <div style={{ padding: '15px', borderTop: '1px solid #e9ecef', background: 'white' }}>
                <Stack gap="xs">
                    {fileName && (
                        <Group gap="xs">
                            <Badge color="green" variant="light" leftSection={<IconFileCheck size={12}/>}>
                                Document : {fileName}
                            </Badge>
                            <ActionIcon size="xs" color="red" variant="subtle" onClick={() => {setFileContext(null); setFilename(null);}}>
                                <IconTrash size={12}/>
                            </ActionIcon>
                        </Group>
                    )}
                    <Group gap="xs">
                        <FileInput 
                            style={{ display: 'none' }} 
                            id="ai-file-upload" 
                            accept=".pdf,.txt"
                            onChange={handleFileUpload} 
                        />
                        <Tooltip label="Joindre un document">
                            <ActionIcon 
                                size="42px" 
                                variant="light" 
                                color="blue" 
                                radius="md"
                                onClick={() => document.getElementById('ai-file-upload')?.click()}
                                loading={loading}
                            >
                                <IconFileUpload size={22} />
                            </ActionIcon>
                        </Tooltip>
                        
                        <TextInput 
                            placeholder={fileName ? "Question sur le document..." : "Posez votre question..."} 
                            style={{ flexGrow: 1 }} 
                            size="md"
                            radius="md"
                            value={input}
                            onChange={(e) => setInput(e.target.value)}
                            onKeyDown={(e) => e.key === 'Enter' && handleSend()}
                            disabled={loading}
                        />
                        <ActionIcon size="42px" radius="md" color="blue" variant="filled" onClick={handleSend} loading={loading}>
                            <IconSend size={22} />
                        </ActionIcon>
                    </Group>
                </Stack>
            </div>
        </Paper>
    </Container>
  );
}
