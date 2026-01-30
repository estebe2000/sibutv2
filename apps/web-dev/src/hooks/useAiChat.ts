import { useState, useCallback } from 'react';
import api from '../services/api';

export interface Message {
    role: 'user' | 'bot';
    content: string;
}

export const INITIAL_MESSAGE: Message = { 
    role: 'bot', 
    content: "Bonjour ! Je suis l'assistant pédagogique du BUT TC. Comment puis-je vous aider aujourd'hui ?" 
};

export function useAiChat() {
    const [messages, setMessages] = useState<Message[]>([INITIAL_MESSAGE]);
    const [loading, setLoading] = useState(false);
    const [fileContext, setFileContext] = useState<string | null>(null);
    const [fileName, setFilename] = useState<string | null>(null);

    const clearChat = useCallback(() => {
        setMessages([INITIAL_MESSAGE]);
        setFileContext(null);
        setFilename(null);
    }, []);

    const handleFileUpload = useCallback(async (file: File | null) => {
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
    }, []);

    const sendMessage = useCallback(async (content: string) => {
        if (!content.trim() || loading) return;
        
        const userMsg: Message = { role: 'user', content };
        setMessages(prev => [...prev, userMsg]);
        setLoading(true);

        try {
            // Filter out the initial welcome message for the API context if needed, 
            // or send the whole history. The original code sliced the first message.
            const historyToSend = [...messages, userMsg].slice(1);
            
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
    }, [messages, loading, fileContext]);

    return {
        messages,
        loading,
        fileName,
        clearChat,
        handleFileUpload,
        sendMessage,
        setFileContext,
        setFilename
    };
}
