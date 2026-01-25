import React, { useEffect, useRef, useState } from 'react';
import EditorJS from '@editorjs/editorjs';
// @ts-ignore
import Header from '@editorjs/header';
// @ts-ignore
import List from '@editorjs/list';
// @ts-ignore
import Table from '@editorjs/table';
// @ts-ignore
import Checklist from '@editorjs/checklist';
// @ts-ignore
import Quote from '@editorjs/quote';
// @ts-ignore
import LinkTool from '@editorjs/link';

import { Paper, Title, Button, Group, TextInput, Stack, Text, ActionIcon, Tooltip, LoadingOverlay, Badge, Drawer, ScrollArea, ThemeIcon, Divider } from '@mantine/core';
import { IconDeviceFloppy, IconArrowLeft, IconShare, IconEye, IconHistory, IconFolder, IconFileDownload, IconPlus } from '@tabler/icons-react';
import api from '../services/api';
import { notifications } from '@mantine/notifications';
import { useDisclosure } from '@mantine/hooks';

interface PortfolioEditorProps {
    pageId?: number;
    onBack: () => void;
    studentUid: string;
}

export function PortfolioEditor({ pageId, onBack, studentUid }: PortfolioEditorProps) {
    const editorInstance = useRef<EditorJS | null>(null);
    const [title, setTitle] = useState('Ma Réflexion de Compétence');
    const [loading, setLoading] = useState(false);
    const [saving, setSaving] = useState(false);
    const [lastSaved, setLastSaved] = useState<Date | null>(null);
    const [opened, { open, close }] = useDisclosure(false);
    const [availableFiles, setAvailableFiles] = useState<any[]>([]);

    const fetchFiles = async () => {
        try {
            const res = await api.get('/portfolio/files');
            setAvailableFiles(res.data);
        } catch (e) {}
    };

    useEffect(() => {
        fetchFiles();
    }, []);

    useEffect(() => {
        const initEditor = async () => {
            setLoading(true);
            let initialData = {};

            if (pageId) {
                try {
                    const res = await api.get(`/portfolio/pages/${pageId}`);
                    setTitle(res.data.title);
                    initialData = JSON.parse(res.data.content_json);
                } catch (e) {
                    notifications.show({ title: 'Erreur', message: 'Impossible de charger la page', color: 'red' });
                }
            }

            editorInstance.current = new EditorJS({
                holder: 'editorjs-container',
                placeholder: 'Commencez à rédiger votre réflexion ici...',
                data: initialData,
                tools: {
                    header: { class: Header, inlineToolbar: true, config: { levels: [2, 3, 4], defaultLevel: 2 } },
                    list: { class: List, inlineToolbar: true },
                    table: { class: Table, inlineToolbar: true },
                    checklist: { class: Checklist, inlineToolbar: true },
                    quote: { class: Quote, inlineToolbar: true },
                    link: { class: LinkTool, inlineToolbar: true }
                }
            });
            setLoading(false);
        };

        if (!editorInstance.current) {
            initEditor();
        }

        return () => {
            if (editorInstance.current && typeof editorInstance.current.destroy === 'function') {
                editorInstance.current.destroy();
                editorInstance.current = null;
            }
        };
    }, [pageId]);

    const handleSave = async () => {
        if (!editorInstance.current) return;
        setSaving(true);
        try {
            const outputData = await editorInstance.current.save();
            const payload = {
                title,
                content_json: JSON.stringify(outputData),
                student_uid: studentUid
            };

            if (pageId) {
                await api.patch(`/portfolio/pages/${pageId}`, payload);
            } else {
                await api.post('/portfolio/pages', payload);
            }

            setLastSaved(new Date());
            notifications.show({ title: 'Succès', message: 'Portfolio sauvegardé', color: 'green' });
        } catch (e) {
            notifications.show({ title: 'Erreur', message: 'Échec de la sauvegarde', color: 'red' });
        }
        setSaving(false);
    };

    const insertProof = (file: any) => {
        if (!editorInstance.current) return;
        
        // 1. Insérer un bloc de citation pour le style
        editorInstance.current.blocks.insert('quote', {
            text: `Preuve : ${file.filename}`,
            caption: `Document lié à l'activité ${file.entity_id}`,
            alignment: 'left'
        });

        // 2. Insérer un bloc paragraphe avec le lien HTML RÉEL (accepté par le plugin paragraph)
        // C'est ce lien qui sera détecté par le Dashboard pour afficher le trombone
        editorInstance.current.blocks.insert('paragraph', {
            text: `Lien de la preuve : <a href="/api/portfolio/download/${file.id}">${file.filename}</a>`
        });
        
        notifications.show({ title: 'Preuve liée', message: file.filename, color: 'blue' });
        close();
    };

    return (
        <Stack gap="md" style={{ position: 'relative' }}>
            <LoadingOverlay visible={loading} />
            
            <Paper withBorder p="md" radius="md" shadow="sm">
                <Group justify="space-between">
                    <Group>
                        <ActionIcon variant="subtle" onClick={onBack} size="lg"><IconArrowLeft /></ActionIcon>
                        <TextInput 
                            variant="unstyled" 
                            size="xl" 
                            fw={700} 
                            placeholder="Titre de la page..." 
                            value={title} 
                            onChange={(e) => setTitle(e.target.value)}
                            style={{ width: 400 }}
                        />
                    </Group>
                    <Group>
                        {lastSaved && <Text size="xs" c="dimmed">Enregistré à {lastSaved.toLocaleTimeString()}</Text>}
                        <Button 
                            variant="outline" 
                            leftSection={<IconFolder size={18} />} 
                            onClick={open}
                        >
                            Ma Bibliothèque
                        </Button>
                        <Button 
                            leftSection={<IconDeviceFloppy size={18} />} 
                            onClick={handleSave} 
                            loading={saving}
                            color="blue"
                        >
                            Enregistrer
                        </Button>
                        <Button variant="light" leftSection={<IconShare size={18}/>}>Partager</Button>
                    </Group>
                </Group>
            </Paper>

            <Drawer opened={opened} onClose={close} title="Bibliothèque de Preuves" position="right" size="md">
                <ScrollArea h="calc(100vh - 80px)" p="md">
                    <Text size="xs" c="dimmed" mb="lg">Cliquez sur une preuve pour l'insérer dans votre réflexion à l'endroit du curseur.</Text>
                    
                    <Stack gap="md">
                        {availableFiles.length === 0 ? (
                            <Text size="sm" ta="center" py="xl" c="dimmed">Aucune preuve dans votre coffre-fort.</Text>
                        ) : (
                            availableFiles.map(file => (
                                <Paper key={file.id} withBorder p="sm" radius="md" className="hover-card" onClick={() => insertProof(file)} style={{ cursor: 'pointer' }}>
                                    <Group justify="space-between" wrap="nowrap">
                                        <Group gap="sm" wrap="nowrap">
                                            <ThemeIcon variant="light" color="orange"><IconFileDownload size={16}/></ThemeIcon>
                                            <div style={{ overflow: 'hidden' }}>
                                                <Text size="sm" fw={700} truncate>{file.filename}</Text>
                                                <Text size="10px" c="dimmed">{file.entity_id} - {file.academic_year}</Text>
                                            </div>
                                        </Group>
                                        <IconPlus size={16} color="gray" />
                                    </Group>
                                </Paper>
                            ))
                        )}
                    </Stack>
                </ScrollArea>
            </Drawer>

            <Paper withBorder p="xl" radius="md" bg="white" shadow="md">
                <div id="editorjs-container" style={{ minHeight: 500 }} />
            </Paper>

            <Paper withBorder p="md" radius="md" bg="blue.0">
                <Group>
                    <IconHistory size={20} color="var(--mantine-color-blue-6)" />
                    <div>
                        <Text fw={700} size="sm">Conseil Académique</Text>
                        <Text size="xs" c="dimmed">Utilisez le bouton "Ma Bibliothèque" pour lier vos documents SAÉ directement dans votre rédaction.</Text>
                    </div>
                </Group>
            </Paper>
        </Stack>
    );
}