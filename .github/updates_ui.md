# 📱 Mobile App UI/UX Design – Tourist Safety App  
(Heatmap Version + Location Sharing Toggle + SOS Screen, Simplified)

---

## 1. Onboarding & KYC Screen
**Purpose:** Verify tourist identity & issue Digital ID.  

**UI Elements:**  
- Language selection (with flags/icons).  
- Aadhaar/Passport scan (camera upload).  
- Consent checkbox (“I agree to share data for safety monitoring”).  
- Step indicator (Step 1 of 3).  
- Continue button.  

**Design Needs:**  
- Multilingual from start.  
- Simple, clean, progress-based.  
- Accessibility (voice/text input).  

---

## 2. Home Dashboard (Heatmap-based)
**Purpose:** Show real-time tourist safety map + quick controls.  

**UI Elements:**  
- **Full-screen Map (OpenStreetMap).**  
- **Heatmap Overlay:**  
  - 🟢 Green = Safe zones.  
  - 🟡 Yellow = Medium risk.  
  - 🔴 Red = High risk.  
- **Tourist Location:** Blue dot.  
- **Panic Button:** Large, floating, bottom-right, red, always visible.  
- **Location Sharing Toggle:** Top-right corner (ON/OFF).  
- **Status Banner (top):**  
  - ✅ Safe  
  - ⚠️ Caution  
  - 🚨 Danger  
- **Legend Bar:** Bottom or side → explains colors.  

**Interactions:**  
- Tap zone → see risk details.  
- Zoom in/out → heatmap density adjusts.  
- Filters → “Now / Last 24h / Last 7 days”.  
- Toggle location sharing ON/OFF → instant update.  

---

## 3. SOS Screen (Emergency Mode)
**Purpose:** Dedicated screen after panic button is pressed.  

**UI Elements:**  
- **Big Alert Banner:** “SOS Activated – Help is on the way”.  
- **Live Location Map (OpenStreetMap):** Your position + nearest responders.  
- **Auto-Send Evidence:** Option to capture & send photo/audio.  
- **Contact Options:**  
  - 📞 Call Police  
  - 📞 Call Family/Emergency Contact  
  - 🏥 Request Ambulance  
- **Incident Status Tracker:**  
  - Alert Sent ✅  
  - Police Notified ⏳  
  - Unit Assigned 🚓  
- **10-Second Cancellation Window:**  
  - A countdown timer (10s) is shown after SOS is triggered.  
  - User can cancel **only within this 10-second window**.  
  - After 10s, SOS alert **cannot be cancelled**.  

**Design Needs:**  
- Full-screen takeover → tourist knows SOS is active.  
- Bold red theme for urgency.  
- Minimal text, clear icons.  
- Voice input support (“Call ambulance”, “Send photo”).  

---

## 4. Alerts & Notifications Screen
**Purpose:** Hub for system alerts & AI predictions.  

**UI Elements:**  
- List of alerts (severity-based colors).  
- Alert details → type, location, timestamp, recommendation.  
- Quick actions → Navigate, Call Police, Call Family.  

**Design Needs:**  
- High-priority alerts pinned.  
- Vibrations + sound for emergencies.  
- Offline storage with later sync.  

---

## 5. Family Sharing Screen
**Purpose:** Allow trusted contacts to track the tourist.  

**UI Elements:**  
- Live location map (OpenStreetMap, if enabled).  
- SOS history (list of triggered events).  
- Toggle to start/stop sharing.  

**Design Needs:**  
- Clear privacy note → “Only visible to selected contacts”.  
- Simple layout for non-technical users.  

---

## 6. Settings & Profile Screen
**Purpose:** Manage Digital ID, privacy & preferences.  

**UI Elements:**  
- Digital Tourist ID → QR code + expiry countdown.  
- Profile info → Name, Photo, Emergency contact.  
- Privacy toggles → consent, tracking, notifications.  
- Language & accessibility settings.  
- Logout/Delete ID (auto expiry after trip).  

**Design Needs:**  
- Visual countdown for ID validity.  
- Multi-language support.  
- Easy navigation.  

---

# 🎨 Style & Accessibility
- **Colors:** Heatmap (Green → Yellow → Red), SOS screen = bold red theme.  
- **Typography:** Large bold fonts for emergencies, clean sans-serif for body text.  
- **Accessibility:**  
  - Voice commands (“Help”, “Call Family”).  
  - Large buttons for elderly/disabled.  
  - 10+ languages.  

---

# ✅ Final Set of Screens
1. Onboarding & KYC  
2. Home Dashboard (Heatmap + Location Toggle)  
3. SOS Screen (Emergency Mode with 10s cancel window)  
4. Alerts & Notifications  
5. Family Sharing  
6. Settings & Profile  
