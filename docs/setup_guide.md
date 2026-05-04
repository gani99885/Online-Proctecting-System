# Setup Guide

## 📌 Requirements

Before running this project, install the following:

* Node.js (v18 or above)
* PostgreSQL
* MongoDB
* Redis (Memurai for Windows)

---

## ⚙️ Installation Steps

### 1. Clone the repository

git clone https://github.com/gani99885/Online-Proctecting-System.git

---

### 2. Navigate to project

cd Online-Proctecting-System

---

### 3. Install dependencies

cd server
npm install

cd ../client
npm install

---

### 4. Environment Setup

Create a `.env` file inside the server folder and add:

PORT=5000
POSTGRES_URI=
MONGO_URI=
REDIS_URL=
JWT_SECRET=

---

### 5. Run the project

cd server
npm start

cd ../client
npm start

---

## ✅ Verification

* Server runs without errors
* Client opens in browser
* Database connection works

---
