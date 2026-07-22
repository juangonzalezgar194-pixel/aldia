# AlDía - Sistema de Gestión de Pagos de Arriendo

Proyecto formativo SENA - Ficha 3113988 - ADSO
Centro Agroecológico y Empresarial "Quebrajacho", Fusagasugá, Cundinamarca

**Equipo:** Juan Esteban González García, Damir Edilson Delgado, Miguel

**Slogan:** Siempre puntual, siempre tranquilo.

---

## Estructura del proyecto

- backend/  -> Spring Boot + MySQL (Java)
- frontend/ -> Flutter (móvil y web)

---

## Requisitos previos

- XAMPP (con MySQL activo)
- JDK 17 o superior
- Flutter SDK instalado y configurado (\lutter doctor\ sin errores graves)
- Git

---

## 1. Clonar el repositorio

\\\ash
git clone https://github.com/juangonzalezgar194-pixel/aldia.git
cd aldia
\\\

---

## 2. Configurar la base de datos (backend)

1. Abre XAMPP y arranca **Apache** y **MySQL**
2. Entra a phpMyAdmin (http://localhost/phpmyadmin)
3. Crea una base de datos nueva llamada exactamente: **aldia_db**
4. No necesitas crear tablas manualmente: Spring Boot las crea solas al arrancar (gracias a \ddl-auto=update\)

---

## 3. Levantar el backend

\\\ash
cd backend
.\mvnw spring-boot:run
\\\

- El backend queda corriendo en: **http://localhost:8080**
- Verifica en la consola que no haya errores de conexión a MySQL
- Si el puerto 8080 está ocupado, cierra el proceso que lo esté usando o cambia \server.port\ en \pplication.properties\

---

## 4. Levantar el frontend (Flutter)

\\\ash
cd frontend
flutter pub get
flutter run
\\\

**IMPORTANTE:** revisa el archivo \lib/services/api_service.dart\. Ahí está la URL base del backend.
Si vas a correr todo en tu propia máquina (backend y frontend en el mismo PC), debe apuntar a:
\\\
http://localhost:8080
\\\
o
\\\
http://127.0.0.1:8080
\\\
según si estás en Flutter Web o emulador/dispositivo físico.

---

## 5. Probar los endpoints (opcional, con Bruno)

Si quieres probar el backend sin el frontend, pueden usar **Bruno** (gratuito, similar a Postman):
1. Descargar Bruno: https://www.usebruno.com/
2. Pedirle a Juan la colección exportada de endpoints (\Aldia API\)
3. Importar la colección y probar login, registro, contratos, pagos, etc.

---

## Notas importantes

- Este repositorio es **privado**, solo para uso del equipo del proyecto formativo.
- Ante cualquier duda o error al levantar el proyecto, escribir al grupo antes de la exposición.
- Evidencia del proyecto verificable en vivo durante la sustentación.
