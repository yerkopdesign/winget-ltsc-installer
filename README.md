# 🛠️ Instalador de WinGet para LTSC — Solución Gráfica
> **Utilidad de automatización con interfaz gráfica (GUI) nativa para instalar y configurar WinGet en Windows 10 Enterprise LTSC (2021/2019).**

[![Plataforma: Windows LTSC](https://img.shields.io/badge/Plataforma-Windows%20LTSC-blue.svg?style=flat-square&logo=windows&logoColor=white)](#)
[![Lenguaje: AutoIt v3](https://img.shields.io/badge/Lenguaje-AutoIt%20v3-orange.svg?style=flat-square)](#)
[![Licencia: MIT](https://img.shields.io/badge/Licencia-MIT-green.svg?style=flat-square)](#)

Una herramienta standalone limpia e intuitiva desarrollada en **AutoIt v3** diseñada para aprovisionar y configurar por completo `winget` (Windows Package Manager) en entornos Enterprise donde la Microsoft Store ha sido omitida de raíz.

---

## 🎨 Vista Previa Visual

| Entorno de Trabajo | Ventana de la Aplicación |
| :---: | :---: |
| ![Estructura de Carpetas](assets/preview-folder.png) | ![Interfaz de la GUI](assets/preview-gui.png) |
*Nota: El diseño utiliza feedback visual directo, tipografía nativa Segoe UI y barras de progreso fluidas en tiempo real.*

---

## ✨ Características y Arquitectura

* **🛡️ Elevación del Sistema de Raíz** — Incorpora directivas estrictas de `#RequireAdmin` para forzar la validación de privilegios administrativos antes de registrar paquetes en el sistema.
* **📦 Entorno de Compilación Seguro** — Resuelve por completo los fallos del empaquetador en rutas locales con caracteres Unicode o tildes (como directorios tipo `Programación`) al migrar la lógica de llamadas directamente al entorno local (`@ScriptDir`).
* **⚡ Estrategia de Despliegue Dual:**
    * **Versión Online:** Conecta dinámicamente con servidores en la nube para descargar e instalar los payloads oficiales más recientes en equipos con red activa.
    * **Versión Local/Offline:** Operación 100% estática que valida, procesa e instala los paquetes binarios adyacentes al ejecutable.
* **🔒 Desconexión Segura de Telemetría** — Desvincula de forma silenciosa (`@SW_HIDE`) el origen muerto de `msstore` para prevenir bucles de sincronización e hilos colgados en segundo plano en despliegues sin red.

---

## 📁 Estructura del Proyecto y Descargas

Los scripts fuentes están organizados de la siguiente forma en el repositorio:

```text
📦 winget-ltsc-installer
 ┣ 📂 src
 ┃ ┣ 📜 Winget-Online-GUI.au3    # Código fuente con descarga activa por red
 ┃ ┗ 📜 Winget-Local-GUI.au3     # Código fuente para ejecución offline local
 ┣ 📂 assets                     # Capturas de pantalla e identidad visual
 ┣ 📜 .gitignore                 # Filtros para evitar subir archivos basura
 ┗ 📜 README.md                  # Documentación principal del sistema
