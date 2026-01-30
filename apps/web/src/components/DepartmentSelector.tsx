import React, { useState, useEffect } from 'react';
import { Select, Group, Text } from '@mantine/core';
import { IconBuilding } from '@tabler/icons-react';
import api from '../services/api';

export function DepartmentSelector({ onDepartmentChange }: { onDepartmentChange: (id: string) => void }) {
    const [departments, setDepartments] = useState<any[]>([]);
    const [selectedDept, setSelectedDept] = useState<string | null>(null);

    useEffect(() => {
        // Fetch departments (assuming user has access)
        // For now, mocking or using a simple endpoint if created
        // Ideally: GET /departments
        // We will simulate a default TC department if not available
        // But since we did not create GET /departments, let's assume we have it or use a hardcoded list for now as Proof of Concept

        // Let's create a quick endpoint in next step or assume single dept for now
        // But the plan says "Add a global selector".

        // We'll mock it for now as the backend endpoint isn't strictly requested in plan but implied
        setDepartments([
            { value: '1', label: 'TC - Techniques de Commercialisation' }
        ]);
        setSelectedDept('1');
    }, []);

    const handleChange = (val: string | null) => {
        setSelectedDept(val);
        if (val) {
            // Update Axios headers globally
            api.defaults.headers.common['X-Department-ID'] = val;
            localStorage.setItem('department_id', val);
            onDepartmentChange(val);
            window.location.reload(); // Simple way to refresh all views with new context
        }
    };

    return (
        <Group>
            <Select
                leftSection={<IconBuilding size={16} />}
                placeholder="Département"
                data={departments}
                value={selectedDept}
                onChange={handleChange}
                size="xs"
                w={250}
                allowDeselect={false}
            />
        </Group>
    );
}
