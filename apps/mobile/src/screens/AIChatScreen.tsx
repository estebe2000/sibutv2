import React, { useState } from 'react';
import { View, Text, TextInput, TouchableOpacity, SafeAreaView, ScrollView, KeyboardAvoidingView, Platform } from 'react-native';

export default function AIChatScreen({ navigation }: any) {
  const [message, setMessage] = useState('');
  const [chat, setChat] = useState([
    { id: 1, role: 'ai', text: "Bonjour ! Je suis l'assistant pédagogique du IUT. Comment puis-je vous aider pour vos compétences ou vos stages ?" }
  ]);

  const sendMessage = () => {
    if (!message.trim()) return;
    setChat([...chat, { id: Date.now(), role: 'user', text: message }]);
    setMessage('');

    // Simulate AI response
    setTimeout(() => {
      setChat(prev => [...prev, {
        id: Date.now(),
        role: 'ai',
        text: "Cette information se trouve dans le référentiel de la compétence C2. Je vous conseille de valider l'Apprentissage Critique AC2.01 via votre mission de stage actuelle."
      }]);
    }, 1000);
  };

  return (
    <SafeAreaView className="flex-1 bg-white">
      <View className="px-4 py-3 bg-indigo-600 flex-row items-center">
        <TouchableOpacity onPress={() => navigation.goBack()} className="mr-4">
          <Text className="text-white font-bold text-lg">← Retour</Text>
        </TouchableOpacity>
        <Text className="text-white text-lg font-bold">Assistant Pédagogique (IA)</Text>
      </View>

      <KeyboardAvoidingView
        behavior={Platform.OS === "ios" ? "padding" : "height"}
        className="flex-1"
      >
        <ScrollView className="flex-1 p-4">
          {chat.map(msg => (
            <View key={msg.id} className={`mb-4 flex-row ${msg.role === 'user' ? 'justify-end' : 'justify-start'}`}>
              <View className={`max-w-[80%] p-4 rounded-2xl ${msg.role === 'user' ? 'bg-blue-500 rounded-tr-none' : 'bg-gray-100 rounded-tl-none'}`}>
                <Text className={`${msg.role === 'user' ? 'text-white' : 'text-gray-800'}`}>{msg.text}</Text>
              </View>
            </View>
          ))}
        </ScrollView>

        <View className="p-4 bg-white border-t border-gray-200 flex-row items-center">
          <TextInput
            value={message}
            onChangeText={setMessage}
            placeholder="Posez votre question..."
            className="flex-1 bg-gray-100 p-3 rounded-full mr-2 px-4"
          />
          <TouchableOpacity
            onPress={sendMessage}
            className="bg-indigo-600 w-12 h-12 rounded-full items-center justify-center"
          >
            <Text className="text-white font-bold">→</Text>
          </TouchableOpacity>
        </View>
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
}
