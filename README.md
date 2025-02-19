# ✅ **Task Manager**  

This project is a **Task Management App** built with Flutter. It helps users efficiently **create, track, and manage tasks** while integrating with Firebase for authentication and real-time updates.  

## ✨ **Features**  
✔️ **User Authentication** – Secure login, registration, and password recovery.  
✔️ **Task Management** – Add, edit, delete, and view task details.  
✔️ **Real-Time Sync** – Firebase ensures instant updates across devices.  

---

## ⚙️ **Installation**  

### 1️⃣ **Clone the Repository**  
```bash  
git clone https://github.com/kartik17k/task-manager.git  
```  

### 2️⃣ **Navigate to the Project Directory**  
```bash  
cd task-manager  
```  

### 3️⃣ **Install Dependencies**  
```bash  
flutter pub get  
```  

### 4️⃣ **Set Up Firebase**  
- Configure Firebase in the project.  
- Update `firebase_options.dart` with your Firebase credentials.  

### 5️⃣ **Run the Application** 🚀  
```bash  
flutter run  
```  

---  

## **How It Works**    

### **1️⃣ User Authentication**  
- **Login & Register**: Users can sign up and log in securely.  
- **Forgot Password**: Users can reset their password via email verification.  

---  

### **2️⃣ Task Management**  
- **Create Tasks**: Users can add new tasks with details like:  
  - **Title** (e.g., Complete project report)  
  - **Description** (Optional but helpful for details)  
  - **Due Date** (For tracking deadlines)  
  - **Priority** (Low, Medium, High)  
  - **Status** (Pending, Completed)  

- **Edit & Delete**: Users can modify or remove tasks anytime.  
- **Real-Time Sync**: Changes instantly reflect across devices via Firestore.  

---  

### **3️⃣ Firebase Firestore Integration**  
- All task data is stored in Firestore under a `tasks` collection.  
- Data retrieval is **real-time**, ensuring instant updates.  

---  

### **4️⃣ Task Filtering & Sorting**  
- Users can **filter tasks** based on **priority** and **status**.  
- Tasks are sorted by **due date** for better tracking.  

---  

## **🚀 Summary**  
- **🔥 Firebase Authentication** ensures secure login and signup.  
- **🟡 Live updates** keep task management seamless.  
- **📌 Efficient task sorting** for better productivity.  

This ensures an intuitive and **productive user experience**! 📅✨  

---  

## **📌 Required Dependencies**  
Add these dependencies to your `pubspec.yaml`:  

```yaml  
dependencies:  
  flutter:  
    sdk: flutter  
  firebase_core: latest_version  
  cloud_firestore: latest_version  
  firebase_auth: latest_version  
  provider: latest_version  
```  

### **Why These Dependencies?**  
- **`firebase_core` & `cloud_firestore`** → Firestore integration for real-time task management.  
- **`firebase_auth`** → Secure authentication and user management.  
- **`provider`** → Efficient state management.  

---  

## **🚀 Future Enhancements**  
✅ **Push Notifications**  
   - Notify users about upcoming task deadlines.  

✅ **Offline Mode**  
   - Implement local storage (e.g., Hive, SharedPreferences) to access tasks without internet.  

✅ **Dark Mode**  
   - Support theme switching for a better user experience.  

This roadmap ensures a continuously improving **task management experience**! 📌📅  

---  
### **📬 Contact**  
For questions or suggestions, reach out at:  
- **Email**: kartikkattishettar@gmail.com  
- **GitHub**: [Kartik](https://github.com/kartik17k)  
