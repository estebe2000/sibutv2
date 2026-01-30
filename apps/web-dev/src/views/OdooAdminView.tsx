import React, { useEffect, useState } from 'react';
import { Container, Title, Paper, Table, Button, Group, Badge, Loader, ActionIcon, Text } from '@mantine/core';
import { IconTrash, IconRefresh, IconExternalLink, IconKey } from '@tabler/icons-react';
import { notifications } from '@mantine/notifications';
import { odooService } from '../services/odoo.service';
import api from '../services/api'; // Import direct pour l'appel POST custom sans passer par le service si non ajouté

export function OdooAdminView() {
  const [databases, setDatabases] = useState<string[]>([]);
  const [loading, setLoading] = useState(true);

  const fetchDatabases = async () => {
    setLoading(true);
    try {
      const dbs = await odooService.listDatabases();
      setDatabases(dbs);
    } catch (e) {
      notifications.show({ title: 'Erreur', message: 'Impossible de lister les bases', color: 'red' });
    }
    setLoading(false);
  };

  useEffect(() => {
    fetchDatabases();
  }, []);

  const handleDelete = async (dbName: string) => {
    if (!window.confirm(`Supprimer DÉFINITIVEMENT la base ${dbName} ?`)) return;
    try {
      await odooService.deleteDatabase(dbName);
      notifications.show({ title: 'Succès', message: `Base ${dbName} supprimée` });
      fetchDatabases();
    } catch (e) {
      notifications.show({ title: 'Erreur', message: 'Échec de la suppression', color: 'red' });
    }
  };

  const handleReset = async (dbName: string) => {
    if (!window.confirm(`Réinitialiser le mot de passe Admin de ${dbName} (valeur du Master) ?`)) return;
    try {
      await api.post(`/odoo/${dbName}/reset-password`);
      notifications.show({ title: 'Succès', message: `Mot de passe réinitialisé`, color: 'green' });
    } catch (e) {
      notifications.show({ title: 'Erreur', message: 'Échec du reset', color: 'red' });
    }
  };

  return (
    <Container size="lg" py="xl">
      <Group justify="space-between" mb="lg">
        <Title order={3}>Gestion des Instances Odoo</Title>
        <Button variant="light" leftSection={<IconRefresh size={16}/>} onClick={fetchDatabases}>Actualiser</Button>
      </Group>

      <Paper withBorder shadow="sm" radius="md">
        {loading ? (
          <Group justify="center" p="xl"><Loader /></Group>
        ) : (
          <Table striped highlightOnHover>
            <Table.Thead>
              <Table.Tr>
                <Table.Th>Nom de la base</Table.Th>
                <Table.Th>URL</Table.Th>
                <Table.Th>Statut</Table.Th>
                <Table.Th>Actions</Table.Th>
              </Table.Tr>
            </Table.Thead>
            <Table.Tbody>
              {databases.map(db => (
                <Table.Tr key={db}>
                  <Table.Td fw={500}>{db}</Table.Td>
                  <Table.Td>
                    <a href={`https://${db}.educ-ai.fr`} target="_blank" rel="noreferrer" style={{ display: 'flex', alignItems: 'center', gap: 5 }}>
                      {db}.educ-ai.fr <IconExternalLink size={12}/>
                    </a>
                  </Table.Td>
                  <Table.Td>
                    {db === 'master-template' ? <Badge color="grape">MASTER</Badge> : 
                     db === 'odoo' ? <Badge color="blue">PORTAIL</Badge> : 
                     <Badge color="gray">ÉTUDIANT</Badge>}
                  </Table.Td>
                  <Table.Td>
                    {db !== 'master-template' && db !== 'odoo' && (
                        <Group gap={5}>
                            <ActionIcon color="orange" variant="light" onClick={() => handleReset(db)} title="Reset Password Admin">
                                <IconKey size={16} />
                            </ActionIcon>
                            <ActionIcon color="red" variant="subtle" onClick={() => handleDelete(db)} title="Supprimer">
                                <IconTrash size={16} />
                            </ActionIcon>
                        </Group>
                    )}
                  </Table.Td>
                </Table.Tr>
              ))}
            </Table.Tbody>
          </Table>
        )}
      </Paper>
    </Container>
  );
}
