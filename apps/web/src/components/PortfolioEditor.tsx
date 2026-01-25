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

import { Paper, Title, Button, Group, TextInput, Stack, Text, ActionIcon, Tooltip, LoadingOverlay, Badge } from '@mantine/core';
import { IconDeviceFloppy, IconArrowLeft, IconShare, IconEye, IconHistory } from '@tabler/icons-react';
import api from '../services/api';
import { notifications } from '@mantine/notifications';

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
                },
                onChange: () => {
                    // Possibilité d'implémenter une sauvegarde automatique ici
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
                const res = await api.post('/portfolio/pages', payload);
                // Si c'est une création, on pourrait rediriger ou mettre à jour l'ID
            }

            setLastSaved(new Date());
            notifications.show({ title: 'Succès', message: 'Portfolio sauvegardé', color: 'green' });
        } catch (e) {
            notifications.show({ title: 'Erreur', message: 'Échec de la sauvegarde', color: 'red' });
        }
        setSaving(false);
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

            <Paper withBorder p="xl" radius="md" bg="white" shadow="md">
                <div id="editorjs-container" style={{ minHeight: 500 }} />
            </Paper>

            <Paper withBorder p="md" radius="md" bg="blue.0">
                <Group>
                    <IconHistory size={20} color="var(--mantine-color-blue-6)" />
                    <div>
                        <Text fw={700} size="sm">Conseil Académique</Text>
                        <Text size="xs" c="dimmed">Utilisez les "Preuves du Coffre-fort" pour illustrer vos propos. Liez vos documents SAÉ directement dans votre rédaction.</Text>
                    </div>
                </Group>
            </Paper>
        </Stack>
    );
}
