# 🎬 MP4X – Convert Videos to MP4

**MP4X** is a lightweight desktop application built with Flutter that allows you to convert common video formats (e.g. AVI, MKV, MOV) to MP4 using FFmpeg. Simple interface, fast conversion, and easy to use.

---

## ✨ Features

- 🎯 Convert various formats (AVI, MKV, MOV, etc.) to MP4
- 🖱️ Drag & drop support
- 🧹 Automatically deletes existing output files before converting
- 🔔 Windows notifications on completion
- ⚡ Powered by FFmpeg
- 🖥️ Built for Windows with a modern UI

---

## 📦 Requirements

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [FFmpeg](https://ffmpeg.org/)

---

## 🔧 Install FFmpeg

To use MP4X, you need to install FFmpeg and make sure it is available globally via the `ffmpeg` command.

### Windows Instructions

1. Download FFmpeg from: https://ffmpeg.org/download.html  
2. Extract it to a folder (e.g. `C:\ffmpeg`)  
3. Add `C:\ffmpeg\bin` to your **Environment Variables → System PATH**

To check if FFmpeg is installed properly:

```bash
ffmpeg -version
