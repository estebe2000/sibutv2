import React from 'react';
import { Title, Badge, Text, Group, Box } from '@mantine/core';

export const renderRichText = (text: string, curriculum: any, showInfo: any, setActiveTab: any) => {
    if (!text) return null;
    return text.split('\n').map((line: string, lineIdx: number) => {
        const trimmedLine = line.trim();
        if (!trimmedLine) return <Box key={lineIdx} h={10} />;

        // 1. Header Handling (###)
        if (trimmedLine.startsWith('###')) {
            return (
                <Title order={6} key={lineIdx} mt="sm" c="blue" tt="uppercase">
                    {trimmedLine.replace('###', '').trim()}
                </Title>
            );
        }

        // 2. Inline Content Parsing (Badges)
        const renderInline = (text: string) => {
            if (!text) return '';

            // Regex to match badges only (R1.01, etc.)
            const parts = text.split(/(\b[R|S]\d+\.[\w\.]+\b|\bSAÉ?\s\d+\.[\w\.]+\b)/g);

            return parts.map((part, i) => {
                if (!part) return null;

                // Handle Resource Badge
                const resMatch = part.match(/\b(R\d+\.[\w\.]+)\b/);
                if (resMatch) {
                    const code = resMatch[1];
                    const resInfo = curriculum.resources?.find((r: any) => r.code === code);
                    return (
                        <Badge
                            key={i} size="xs" color="teal" variant="light"
                            style={{ cursor: 'pointer', textTransform: 'none', verticalAlign: 'middle' }}
                            onClick={(e) => { e.stopPropagation(); showInfo(resInfo || {code}, 'RES'); }}
                        >
                            {code}
                        </Badge>
                    );
                }

                // Handle Activity Badge
                const actMatch = part.match(/\b(SAÉ?\s\d+\.[\w\.]+)\b/);
                if (actMatch) {
                    const code = actMatch[1];
                    return (
                        <Badge
                            key={i} size="xs" color="orange" variant="light"
                            style={{ cursor: 'pointer', verticalAlign: 'middle' }}
                            onClick={(e) => {
                                e.stopPropagation();
                                window.dispatchEvent(new CustomEvent('switch-to-activities', { detail: code }));
                            }}
                        >
                            {code}
                        </Badge>
                    );
                }

                return part;
            });
        };

        // 3. List Item Handling (•)
        if (trimmedLine.startsWith('•')) {
            return (
                <Group key={lineIdx} gap="xs" wrap="nowrap" align="flex-start" style={{ paddingLeft: 10 }}>
                    <Text size="sm" c="blue">•</Text>
                    <Text size="sm" style={{ flex: 1 }}>
                        {renderInline(trimmedLine.substring(1).trim())}
                    </Text>
                </Group>
            );
        }

        // 4. Standard Paragraph
        return (
            <Text key={lineIdx} size="sm" style={{ lineHeight: 1.6 }}>
                {renderInline(trimmedLine)}
            </Text>
        );
    });
};
