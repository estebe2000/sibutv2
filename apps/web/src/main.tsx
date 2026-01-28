import React from 'react'
import ReactDOM from 'react-dom/client'
import { MantineProvider } from '@mantine/core'
import { Notifications } from '@mantine/notifications'
import App from './App.tsx'
import '@mantine/core/styles.css'
import '@mantine/notifications/styles.css'
import '@mantine/dates/styles.css'
import 'leaflet/dist/leaflet.css';
import './index.css'

ReactDOM.createRoot(document.getElementById('root')!).render(

  <MantineProvider defaultColorScheme="light">

    <Notifications />

    <App />

  </MantineProvider>,

)
