# Stage 1: Build
FROM node:20-slim AS build

WORKDIR /app

COPY package*.json ./
# Forcer l'installation malgré les conflits de peer dependencies de Mantine
RUN npm install --legacy-peer-deps

COPY . .
RUN npm run build

# Stage 2: Serve with Nginx
FROM nginx:alpine
COPY --from=build /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]