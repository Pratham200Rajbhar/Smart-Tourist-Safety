# 📝 Flutter Mobile App Prototype Prompt

I want you to build a **Flutter mobile app prototype** for a hackathon project.  
The app is called **“Smart Tourist Safety”** and should demonstrate a **tourist safety monitoring system** using maps, alerts, and a panic button.  
This is only a prototype — no backend is required, just demo data and mock flows.  

---

## 🎯 Goals
- Impress hackathon judges with **working UI + demo features**.  
- Show **tourist clusters in Jammu & Kashmir** using mock data.  
- Demonstrate **geo-fencing, safety alerts, and panic SOS button**.  
- Keep it **lightweight, offline, and free (no paid APIs)**.  

---

## 📱 Required Screens
1. **Onboarding + Digital ID**
   - Simple sign-up with name + ID.  
   - Generate a **QR code Digital ID** using `qr_flutter`.  
   - Show “Blockchain Verified ✅” text (mock only).  

2. **Home Dashboard**
   - Show a **map (OpenStreetMap via `flutter_map`)** centered on Srinagar, J&K.  
   - Display **tourist clusters** (green = safe, red = alert).  
   - Show a **safety score** text (just "Safe" or "Risky" mock).  
   - Add a **panic SOS button (FAB)**.  

3. **Geo-Fence Alert**
   - Define a **danger zone polygon** (red) and a **safe zone polygon** (green).  
   - If tourist enters danger zone → show popup:  
     > ⚠️ "You are in a Risky Area! Return to Safe Zone."  
   - Trigger vibration + sound (if possible).  

4. **Panic / SOS Flow**
   - Tap panic → show **Lottie animation** (sending SOS).  
   - Confirmation: “SOS Sent ✅ Location shared with authorities.”  
   - Data shown: Digital ID, GPS, timestamp (mock).  

5. **Authority Dashboard (optional, inside app)**
   - Simple screen with **map + red flashing alert marker** when SOS is sent.  
   - Show alert detail card (Tourist ID, time, severity).  

---

## 📦 Required Libraries (pubspec.yaml)
```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^8.1.2
  flutter_map: ^7.0.2
  flutter_map_marker_cluster: ^1.2.0
  latlong2: ^0.9.0
  geolocator: ^12.0.0
  qr_flutter: ^4.1.0
  flutter_local_notifications: ^17.2.0
  lottie: ^3.1.0
  google_fonts: ^6.2.1
```

---

## 🗺️ Demo Data (Tourist Clusters in J&K)
```json
[
  { "id": 1, "name": "Group A", "lat": 34.0837, "lng": 74.7973, "status": "safe" },   // Srinagar
  { "id": 2, "name": "Group B", "lat": 34.0484, "lng": 74.3805, "status": "alert" },  // Gulmarg
  { "id": 3, "name": "Group C", "lat": 34.1526, "lng": 77.5770, "status": "safe" },   // Leh
  { "id": 4, "name": "Group D", "lat": 33.7782, "lng": 76.5762, "status": "alert" }   // Kargil
]
```

---

## 🎨 UI/UX Requirements
- Use **Material 3 theming** with `google_fonts`.  
- Map → **green markers for safe**, **red markers for alerts**.  
- Cluster markers (blue circle with count) using `flutter_map_marker_cluster`.  
- Panic button → FloatingActionButton with red background.  
- Use **Lottie animation** for SOS sending.  
- Popups on marker tap → show tourist group name + status.  

---

## 🚀 Expected Demo Flow
1. Tourist opens app → Onboarding → Digital ID generated.  
2. Home Dashboard → Map shows clusters of tourists in J&K.  
3. If tourist marker moves into danger zone polygon → alert popup + vibration.  
4. Panic button pressed → animation → SOS confirmation shown.  
5. Authority dashboard screen → shows alert marker + details.  

---

## ⚠️ Important Notes
- Use **mock/demo data only** (no backend).  
- Keep code **modular** (each screen separate widget).  
- Focus on **UI + interactions**, not real AI or blockchain.  
- Goal is to **showcase concept visually**, not full implementation.  