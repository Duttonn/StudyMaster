# StudyMaster

**StudyMaster** is an educational app designed to help engineering students manage their learning materials, improve their note-taking skills, and prepare for exams. The app uses **Core Data** for persistence and integrates various tools like quizzes, notes, and progress tracking to create a collaborative and competitive learning environment.

---

## **Current Project Structure**

### **1. App Overview**
- **Entry Point:** The app starts at `SubjectsView`, where users can manage subjects.
- **Core Features:** 
  - **Subjects**: Allows users to create, view, and manage subjects.
  - **Quizzes**: Dynamic quizzes are linked to each subject with scores and progress tracking.
  - **Notes**: Notes are associated with subjects, and users can add, edit, and delete them.

---

### **2. Key Modules**

#### **SubjectsView**
- Displays a list of subjects managed by the user.
- Users can create new subjects through a modal interface or delete existing ones.
- Navigation links allow users to access quizzes and notes for each subject.

#### **SubjectDetailView**
- Provides access to the specific subject's quizzes and notes.
- Acts as a hub for managing a subject's related content.

#### **QuizzView**
- Displays quizzes associated with the selected subject.
- Automatically initializes random quizzes for a subject if none exist.
- Tracks the user's performance, including correct and incorrect answers.
- Displays progress using a circular progress bar.
- Supports functionality for skipping questions, forfeiting, and reviewing scores after completion.

#### **NoteView**
- Allows users to view, create, and edit notes associated with the selected subject.
- Newly created notes are automatically linked to the current subject.
- Notes display their title, content, and last modified date.
- Includes features for deleting notes and displaying detailed note content.

#### **ReplayView**
- A dedicated view for displaying results and replaying completed quizzes.

#### **Core Data Models**
- **Subject**: Represents a subject with attributes like `name` and relationships to `quizzes` and `notes`.
- **Quizz**: Represents a quiz question, with attributes for `questionText`, `correctAnswer`, `options`, and a relationship to its `subject`.
- **NoteEntity**: Represents a note with attributes for `name`, `content`, `timestamp`, and a relationship to its `subject`.

#### **Helper Functions**
- Utility functions for formatting dates, randomizing options for quizzes, and managing Core Data interactions.

#### **CircularProgressBar**
- A reusable SwiftUI component to visually track quiz progress.

#### **Persistence**
- Core Data stack implementation to handle the app's persistent data.

---

### **3. Implemented Features**

#### **Subjects Management**
- Create, view, and delete subjects.
- Subjects are associated with quizzes and notes, allowing for seamless navigation.

#### **Quizzes**
- Quizzes are dynamically generated if none exist for a subject.
- Tracks performance metrics like correct/incorrect answers and time taken.
- Provides a score based on time and accuracy.
- Allows users to replay quizzes and review their performance.

#### **Notes**
- Notes can be added, edited, and deleted for each subject.
- Supports linking notes to specific subjects.
- Displays note details, including the title, content, and last modified date.

#### **Progress Tracking**
- Tracks quiz scores and calculates average performance across multiple attempts.
- Displays progress using visual indicators like a circular progress bar.

---

Here's the enhanced **"Future Development"** section for your README with these additions:

---

## **Future Development**

### **Ultimate Goals**
1. **Curriculum Management:**
   - Allow users to create a curriculum for their class.
   - Add subjects manually and upload professors' notes and lessons to the corresponding subject.
   - Enable class members to join a curriculum and access the same interface as the curriculum creator.

2. **Collaborative Features:**
   - Support individual note uploads by students.
   - Enable users to share notes or collaborate on a set of notes for group study.
   - Introduce quiz challenges to let users compete with friends using custom quizzes and compare scores.

3. **GPT-Powered Note Grading:**
   - Implement GPT-based feedback to grade students' notes compared to the professor's materials.
   - Provide actionable suggestions to improve note-taking by identifying missing or incomplete points.

4. **Adaptive Learning Features:**
   - Track weak areas based on past quiz performance and reinforce them through adaptive quizzes.
   - Reintroduce incorrectly answered questions periodically to ensure mastery.

5. **Leaderboard and Gamification:**
   - Display a leaderboard for each subject, showing student rankings based on scores.
   - Introduce badges or points for completing quizzes, mastering subjects, or maintaining streaks to keep users motivated.

6. **Flashcards for Revision:**
   - Automatically generate flashcards from professors' notes to help students revise key concepts.

7. **Knowledge Gap Analysis:**
   - Ask diagnostic questions when a student joins a subject to identify knowledge gaps.
   - Use this information to provide targeted help and improve foundational understanding.

---

### **Possible Enhancements**

#### **1. Enhanced User Experience**
- **Dark Mode Support:** Add a toggle for light/dark mode to improve usability for students who study at night.
- **Progress Tracking Dashboard:** Create a visual representation of user progress, including completed quizzes, mastered topics, and study streaks.
- **Search and Filtering:** Implement a search bar or filtering options for subjects, notes, or quizzes to help users quickly find what they need.

#### **2. Gamification**
- **Achievements and Rewards:** Introduce badges or points for completing quizzes or mastering subjects to keep users motivated.
- **Leaderboard:** Display a leaderboard for friendly competition among users.

#### **3. Collaboration Features**
- **Shared Notes:** Allow users to share notes or collaborate on a set of notes for group study.
- **Quiz Challenges:** Enable users to challenge friends with custom quizzes and compare scores.

#### **4. Advanced Quiz Features**
- **Custom Quiz Creation:** Let users create their own quizzes with questions and answers for personalized study.
- **Timed Quizzes:** Add a timed mode for quizzes to simulate exam conditions.
- **Question Bank Integration:** Allow users to add frequently missed questions into a "Focus Bank" for targeted learning.

#### **5. Cloud Sync and Backup**
- **iCloud/Google Drive Integration:** Provide cloud sync options to back up data and access it across multiple devices.
- **Multi-Device Support:** Ensure users can seamlessly transition between devices.

#### **6. AI-Powered Enhancements**
- **Smart Suggestions:** Use AI to recommend topics to review based on quiz performance or the time since a topic was last reviewed.
- **Summarization:** Allow the app to generate summaries for notes using NLP techniques.
- **Flashcard Generation:** Automatically create flashcards from notes using AI to identify key terms and concepts.

#### **7. Expand Subject Support**
- **Formula Repository:** Add a feature to store and organize formulas for math, physics, or engineering topics.
- **Diagrams and Annotations:** Allow users to draw or annotate diagrams directly in their notes.

#### **8. Analytics for Self-Improvement**
- **Detailed Insights:** Show analytics like average quiz score, time spent studying per subject, and topics with the highest error rates.
- **Heatmap Calendar:** Display a heatmap-style calendar of study activity to motivate consistency.

#### **9. Monetization and Scalability**
- **Premium Features:** Offer advanced features like cloud sync, AI tools, or gamification as part of a premium subscription.
- **Ads:** Consider implementing non-intrusive ads for free users.

#### **10. Technical Enhancements**
- **Bug Fixes and Optimization:** Address any known performance issues or UI bugs.
- **Code Refactoring:** Review and optimize code for better maintainability and scalability.
- **Unit Tests:** Write automated tests to ensure app stability as you add features.
