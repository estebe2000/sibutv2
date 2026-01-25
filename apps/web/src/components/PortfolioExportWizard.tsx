import React, { useState, useEffect } from 'react';
import { Stepper, Button, Group, TextInput, Stack, Text, Paper, MultiSelect, Switch, ColorInput, Title, Divider, Checkbox, Textarea, Center, Alert } from '@mantine/core';
import { IconFileExport, IconForms, IconListCheck, IconSettings, IconDownload, IconExternalLink, IconInfoCircle } from '@tabler/icons-react';
import api from '../services/api';
import { notifications } from '@mantine/notifications';

export function PortfolioExportWizard({ studentUid, pages }: { studentUid: string, pages: any[] }) {
    const [active, setActive] = useState(0);
    const [config, setConfig] = useState({
        preamble: "En tant qu'étudiant en BUT Techniques de Commercialisation, ce portfolio retrace mon parcours d'acquisition de compétences à travers mes expériences académiques et professionnelles.",
        selected_pages: [] as string[],
        include_internships: true,
        include_sae: true,
        include_radar: true,
        theme_color: "#1971c2"
    });

    const [exporting, setExporting] = useState(false);

    const handleExport = async (format: 'pdf' | 'html') => {
        setExporting(true);
        try {
            // Pour la démo, on ouvre l'endpoint d'export (à implémenter au besoin)
            window.open(`${api.defaults.baseURL}/portfolio/export/${format}?student_uid=${studentUid}&color=${encodeURIComponent(config.theme_color)}`, '_blank');
            notifications.show({ title: 'Exportation lancée', message: `Le fichier ${format.toUpperCase()} est en cours de génération.` });
        } catch (e) {
            notifications.show({ title: 'Erreur', message: 'Échec de la génération', color: 'red' });
        }
        setExporting(false);
    };

    return (
        <Paper withBorder p="xl" radius="md" shadow="md">
            <Group mb="xl">
                <IconFileExport size={28} color="var(--mantine-color-blue-6)" />
                <Title order={3}>Assistant d'Exportation Professionnel</Title>
            </Group>

            <Stepper active={active} onStepClick={setActive} allowNextStepsSelect={false} breakpoint="sm">
                
                <Stepper.Step label="Préambule" description="Introduction du book" icon={<IconForms size={18} />}>
                    <Stack mt="xl">
                        <Text size="sm" fw={500}>Éditez l'introduction de votre portfolio :</Text>
                        <Textarea 
                            placeholder="Présentez-vous..."
                            minRows={6}
                            value={config.preamble}
                            onChange={(e) => setConfig({...config, preamble: e.target.value})}
                        />
                        <Alert color="blue" icon={<IconInfoCircle />}>
                            Ce texte apparaîtra sur la première page de votre export.
                        </Alert>
                    </Stack>
                </Stepper.Step>

                <Stepper.Step label="Sélection" description="Contenu à inclure" icon={<IconListCheck size={18} />}>
                    <Stack mt="xl">
                        <Text size="sm" fw={500}>Cochez les briques à intégrer :</Text>
                        <Paper withBorder p="md" radius="sm">
                            <Stack>
                                <Checkbox 
                                    label="Mes Stages et Expériences Pro" 
                                    checked={config.include_internships} 
                                    onChange={(e) => setConfig({...config, include_internships: e.currentTarget.checked})} 
                                />
                                <Checkbox 
                                    label="Mes SAÉ (Activités Académiques)" 
                                    checked={config.include_sae} 
                                    onChange={(e) => setConfig({...config, include_sae: e.currentTarget.checked})} 
                                />
                                <Checkbox 
                                    label="Graphique Radar de Synthèse" 
                                    checked={config.include_radar} 
                                    onChange={(e) => setConfig({...config, include_radar: e.currentTarget.checked})} 
                                />
                            </Stack>
                        </Paper>

                        <Text size="sm" fw={500} mt="md">Pages de réflexion spécifiques :</Text>
                        <MultiSelect 
                            data={pages.map(p => ({ value: p.id.toString(), label: p.title }))}
                            placeholder="Choisir les pages..."
                            value={config.selected_pages}
                            onChange={(v) => setConfig({...config, selected_pages: v})}
                        />
                    </Stack>
                </Stepper.Step>

                <Stepper.Step label="Rendu" description="Style et format" icon={<IconSettings size={18} />}>
                    <Stack mt="xl">
                        <Group grow>
                            <ColorInput 
                                label="Couleur d'accentuation" 
                                value={config.theme_color} 
                                onChange={(v) => setConfig({...config, theme_color: v})} 
                            />
                            <TextInput label="Propriétaire du document" value={studentUid} disabled />
                        </Group>

                        <Divider my="lg" label="Finalisation" labelPosition="center" />

                        <Group justify="center" gap="xl" py="xl">
                            <Stack align="center">
                                <Button 
                                    size="lg" 
                                    color="red" 
                                    variant="filled" 
                                    leftSection={<IconDownload size={24} />}
                                    onClick={() => handleExport('pdf')}
                                    loading={exporting}
                                >
                                    Générer le PDF
                                </Button>
                                <Text size="xs" c="dimmed">Format rigoureux pour impression</Text>
                            </Stack>

                            <Stack align="center">
                                <Button 
                                    size="lg" 
                                    color="blue" 
                                    variant="outline" 
                                    leftSection={<IconExternalLink size={24} />}
                                    onClick={() => handleExport('html')}
                                    loading={exporting}
                                >
                                    Générer le Web-Book
                                </Button>
                                <Text size="xs" c="dimmed">Page HTML interactive</Text>
                            </Stack>
                        </Group>
                    </Stack>
                </Stepper.Step>

                <Stepper.Completed>
                    <Center py="xl">
                        <Stack align="center">
                            <Title order={4} c="green">Exportation Terminée !</Title>
                            <Text size="sm">Vous pouvez maintenant fermer cet assistant.</Text>
                            <Button onClick={() => setActive(0)} variant="subtle">Recommencer un export</Button>
                        </Stack>
                    </Center>
                </Stepper.Completed>
            </Stepper>

            <Group justify="flex-end" mt="xl">
                {active !== 0 && (
                    <Button variant="default" onClick={() => setActive((current) => current - 1)}>
                        Précédent
                    </Button>
                )}
                {active < 2 && (
                    <Button onClick={() => setActive((current) => current + 1)}>Étape Suivante</Button>
                )}
            </Group>
        </Paper>
    );
}