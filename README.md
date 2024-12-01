StudyMaster
StudyMaster is an educational app designed to help engineering students manage their learning materials, improve their note-taking skills, and prepare for exams. The app uses Core Data for persistence and integrates various tools like quizzes, notes, and progress tracking to create a collaborative and competitive learning environment.

Current Project Structure
1. App Overview
Entry Point: The app starts at SubjectsView, where users can manage subjects.
Core Features:
Subjects: Allows users to create, view, and manage subjects.
Quizzes: Dynamic quizzes are linked to each subject with scores and progress tracking.
Notes: Notes are associated with subjects, and users can add, edit, and delete them.
2. Key Modules
SubjectsView
Displays a list of subjects managed by the user.
Users can create new subjects through a modal interface or delete existing ones.
Navigation links allow users to access quizzes and notes for each subject.
SubjectDetailView
Provides access to the specific subject's quizzes and notes.
Acts as a hub for managing a subject's related content.
QuizzView
Displays quizzes associated with the selected subject.
Automatically initializes random quizzes for a subject if none exist.
Tracks the user's performance, including correct and incorrect answers.
Displays progress using a circular progress bar.
Supports functionality for skipping questions, forfeiting, and reviewing scores after completion.
NoteView
Allows users to view, create, and edit notes associated with the selected subject.
Newly created notes are automatically linked to the current subject.
Notes display their title, content, and last modified date.
Includes features for deleting notes and displaying detailed note content.
ReplayView
A dedicated view for displaying results and replaying completed quizzes.
Core Data Models
Subject: Represents a subject with attributes like name and relationships to quizzes and notes.
Quizz: Represents a quiz question, with attributes for questionText, correctAnswer, options, and a relationship to its subject.
NoteEntity: Represents a note with attributes for name, content, timestamp, and a relationship to its subject.
Helper Functions
Utility functions for formatting dates, randomizing options for quizzes, and managing Core Data interactions.
CircularProgressBar
A reusable SwiftUI component to visually track quiz progress.
Persistence
Core Data stack implementation to handle the app's persistent data.
3. Implemented Features
Subjects Management
Create, view, and delete subjects.
Subjects are associated with quizzes and notes, allowing for seamless navigation.
Quizzes
Quizzes are dynamically generated if none exist for a subject.
Tracks performance metrics like correct/incorrect answers and time taken.
Provides a score based on time and accuracy.
Allows users to replay quizzes and review their performance.
Notes
Notes can be added, edited, and deleted for each subject.
Supports linking notes to specific subjects.
Displays note details, including the title, content, and last modified date.
Progress Tracking
Tracks quiz scores and calculates average performance across multiple attempts.
Displays progress using visual indicators like a circular progress bar.
Future Development
Ultimate Goals
Curriculum Management:

Allow users to create a curriculum for their class.
Add subjects manually and upload professors' notes and lessons to the corresponding subject.
Collaborative Features:

Enable class members to join a curriculum and access the same interface as the creator.
Support individual note uploads by students.
GPT-Powered Note Grading:

Implement GPT-based feedback to grade students' notes compared to the professor's materials.
Provide actionable suggestions to improve note-taking by identifying missing or incomplete points.
Flashcards for Revision:

Automatically generate flashcards from professors' notes to help students revise key concepts.
Enhanced Quizzes and Exercises:

Include exercises and mock exams in addition to quizzes.
Store scores for all activities and calculate a cumulative mean to assess overall performance.
Notify students if their scores are too low and recommend specific areas to improve.
Leaderboard and Competitive Learning:

Display a leaderboard for each subject, showing student rankings based on their scores.
Make the leaderboard visible to all members of the curriculum.
Knowledge Gap Analysis:

When a student first joins a subject, ask diagnostic questions to identify knowledge gaps.
Use this information to provide targeted help and improve the student’s foundational understanding.
Personalized Learning Recommendations:

Track weak areas based on past quiz performance and reinforce them through adaptive quizzes.
Reintroduce incorrectly answered questions periodically to ensure mastery.
Conclusion
StudyMaster is evolving into a comprehensive learning platform for students. By integrating Core Data, GPT-based AI features, and collaborative tools, the app will provide an efficient and engaging way for students to manage their studies, improve their skills, and collaborate with peers.
