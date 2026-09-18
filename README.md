
# "Scholar" -> Student_Task_Manager(Lunorsoft_Initial_Idea)

Scholar is a full-stack Student Task Management Application designed to help students create, organize, track, update, and complete their academic and personal tasks through a centralized task management platform. The system provides secure user authentication, task CRUD operations, task filtering, sorting, search, pagination, completion tracking, and task statistics. The application is divided into a Flutter frontend, Node.js and Express.js backend, and PostgreSQL database managed using Prisma ORM.

## Problem Statement

Students often manage assignments, examinations, projects, laboratory work, and personal activities across different platforms. This makes it difficult to maintain a centralized view of pending and completed work. Scholar provides a structured task management system where authenticated users can create, update, complete, filter, search, and delete their tasks from a single application.

## System Architecture

The application follows a client-server architecture. The Flutter frontend communicates with the backend through REST APIs. The backend handles authentication, request validation, business logic, task management, and database operations. PostgreSQL is used for persistent data storage, while Prisma ORM provides the database access layer.

<img width="714" height="480" alt="01-system-architecture" src="https://github.com/user-attachments/assets/a5374d26-2bed-44dd-9fc7-dfd27bb21932" />

## Data Flow Pipeline

The application follows a structured request-response pipeline. User actions from the Flutter interface are converted into HTTP requests using Dio. The Express.js backend authenticates and validates the request before passing it through the controller, service, and repository layers. Prisma then communicates with PostgreSQL and the resulting response is returned to the frontend.

<img width="768" height="263" alt="02-request-lifecycle" src="https://github.com/user-attachments/assets/13a7419c-4370-4cee-beda-533e1b49184b" />

## Backend Architecture
The backend follows a Controller-Service-Repository architecture. Routes define the REST API endpoints, middleware handles authentication and security concerns, controllers handle HTTP requests, services contain application logic, and the repository/data-access layer communicates with PostgreSQL through Prisma ORM.

<img width="768" height="300" alt="03-backend-layered-architecture" src="https://github.com/user-attachments/assets/06d94fe0-2e83-4b89-8a59-d7366cd692b4" />

## Database Architecture

Scholar uses PostgreSQL as its relational database. Prisma ORM is used for schema management, migrations, and type-safe database operations. Each authenticated user can have multiple tasks, while task operations are scoped to the authenticated user's identity.

<img width="768" height="344" alt="04-relational-data-model" src="https://github.com/user-attachments/assets/daeebb77-19ca-4f84-b042-3e36aede841a" />

## Operational Flow
User Registration / Login → JWT Authentication → Dashboard → Create Task → View Tasks → Update Task → Complete Task → Delete Task

The frontend communicates with the backend through REST API requests, while the backend manages authentication, validation, business logic, and database operations.

## Deployment Architecture

The application can be deployed as separate frontend, backend, and database components. The Flutter application acts as the client, the Node.js and Express.js application provides the REST API, and PostgreSQL provides persistent storage.

<img width="768" height="358" alt="05-deployment-architecture" src="https://github.com/user-attachments/assets/31963077-248d-4f9f-9310-002dfe6e4a93" />

## Features
- User registration and login
- JWT-based authentication
- Secure password hashing
- Create new tasks
- View existing tasks
- View individual task details
- Update tasks
- Mark tasks as completed
- Delete tasks
- Task search
- Task filtering
- Task sorting
- Task pagination
- Due date management
- Priority management
- Category-based organization
- Task statistics
- Completion percentage
- Overdue task tracking
- Category-wise task statistics

## Task Categories

| Category | Description |
|---|---|
| ASSIGNMENT | Academic assignments |
| EXAM | Examinations and preparation |
| PROJECT | Academic or personal projects |
| LAB | Laboratory-related work |
| PERSONAL | Personal activities |
| OTHER | Other tasks |

## Task Priority

| Priority | Description |
|---|---|
| LOW | Low-priority tasks |
| MEDIUM | Normal-priority tasks |
| HIGH | High-priority tasks |

## Task Status

The backend supports multiple task filtering states:

| Status | Description |
|---|---|
| ALL | All tasks |
| PENDING | Tasks that are not completed |
| COMPLETED | Completed tasks |
| TODAY | Tasks due today |
| UPCOMING | Future tasks |
| OVERDUE | Tasks past their due date |

## Technology Stack

### Frontend

| Technology | Purpose |
|---|---|
| Flutter | Cross-platform application development |
| Dart | Programming language |
| Riverpod | State management |
| Dio | HTTP client and REST API communication |
| Flutter Secure Storage | Secure local data storage |
| Shared Preferences | Local application preferences |
| Table Calendar | Calendar-based task management |
| FL Chart | Data visualization |
| Google Fonts | Application typography |

### Backend

| Technology | Purpose |
|---|---|
| Node.js | Server-side runtime |
| Express.js | REST API framework |
| TypeScript | Type-safe backend development |
| Prisma ORM | Database access and ORM |
| PostgreSQL | Relational database |
| JWT | User authentication |
| bcryptjs | Password hashing |
| Zod | Request validation |

## Repository Structure

### Frontend Repository

```text
Taskflow/
│
├── android/
├── ios/
├── lib/
├── linux/
├── macos/
├── test/
├── web/
├── windows/
│
├── .gitignore
├── analysis_options.yaml
├── pubspec.yaml
└── pubspec.lock
```

### Backend Repository

```text
taskflow-backend/
│
├── prisma/
├── src/
├── tests/
│
├── .env.example
├── .gitignore
├── jest.config.js
├── package.json
├── package-lock.json
├── tsconfig.json
└── README.md
```
# Complete Local System
```text
                YOUR COMPUTER
                     │
        ┌────────────┴────────────┐
        │                         │
        ▼                         ▼
 React/Vite                  Express/Node
 :5173                         :5000
        │                         │
        │      REST API           │
        └────────────►────────────┘
                                  │
                                  ▼
                       MongoDB Community
                              :27017
                                  │
                                  ▼
                         student_task_manager
                            │             │
                            ▼             ▼
                          users         tasks

                                  ▲
                                  │
                                  │
                            MongoDB Compass
```

# Request Lifecycle
A typical request follows the following flow:

```text
User Action
    |
    v
Flutter UI
    |
    v
Dio HTTP Request
    |
    v
Express.js API
    |
    v
Authentication Middleware
    |
    v
Request Validation
    |
    v
Controller
    |
    v
Service Layer
    |
    v
Repository / Prisma
    |
    v
PostgreSQL
    |
    v
Response
    |
    v
Flutter UI Update
```

# Database Architecture

TaskFlow uses PostgreSQL as its persistent relational database.

Prisma ORM acts as the data access layer between the backend application and PostgreSQL.

## Data Relationship

The main relationship is between users and their tasks.

```text
User
 |
 | 1
 |
 |--------------------<
 |                     |
 |                     | N
 v                     v
Tasks                User Tasks
## API Architecture
### Authentication APIs
| Method | Endpoint | Purpose |
|---|---|---|
| POST | `/api/auth/register` | Register a new user |
| POST | `/api/auth/login` | Authenticate a user |
| GET | `/api/auth/me` | Retrieve authenticated user |
```
A user can create and manage multiple tasks, while each task belongs to a specific authenticated user.

Task ownership is enforced using the authenticated user's identity.

---

# Deployment Architecture
The application can be deployed as separate frontend, backend, and database components.

```text
                 Internet
                    |
          +---------+---------+
          |                   |
          v                   v
   Flutter Application   Backend API
                              |
                              v
                         PostgreSQL
                           Database
```
                  ┌───────────────────────┐
                  │      React + Vite     │
                  │       Frontend        │
                  │   localhost:5173      │
                  └───────────┬───────────┘
                              │
                         REST API / HTTP
                              │
                              ▼
                  ┌───────────────────────┐
                  │   Node.js + Express    │
                  │       Backend         │
                  │   localhost:5000      │
                  └───────────┬───────────┘
                              │
                         Mongoose
                              │
                              ▼
                  ┌───────────────────────┐
                  │     MongoDB Atlas      │
                  │        Database        │
                  └───────────────────────┘


### Task APIs
| Method | Endpoint | Purpose |
|---|---|---|
| GET | `/api/tasks` | Retrieve user's tasks |
| GET | `/api/tasks/stats` | Retrieve task statistics |
| GET | `/api/tasks/:id` | Retrieve a specific task |
| POST | `/api/tasks` | Create a new task |
| PUT | `/api/tasks/:id` | Update an existing task |
| PATCH | `/api/tasks/:id/complete` | Mark a task as completed |
| DELETE | `/api/tasks/:id` | Delete a task |

## Security

The backend implements security controls across authentication, authorization, request validation, API protection, and database access.

- JWT authentication with token expiry
- bcrypt password hashing
- Authenticated user identity from verified JWT
- User-scoped task access
- Protection against unauthorized task access
- Zod request validation
- Strict request body schemas
- API rate limiting
- Helmet security headers
- Explicit CORS configuration
- Request body size limitation
- Pagination limits
- Generic client-facing error messages
- Server-side error logging
- Prisma parameterized database operations

Task queries are scoped using the authenticated user's identity to prevent unauthorized access to another user's tasks.

## Testing

The backend contains automated tests covering important application and security behavior.

The testing process covers areas such as:

- Authentication
- Authorization
- Request validation
- Task ownership
- API protection
- Input handling

## Application Workflow

```text
User
  |
  v
Register / Login
  |
  v
JWT Authentication
  |
  v
Dashboard
  |
  +-------------------+
  |                   |
  v                   v
View Tasks       Task Statistics
  |
  +-------------------------------+
  |              |                |
  v              v                v
Create         Update          Complete
Task           Task            Task
  |
  v
Delete Task
```
## Engineering Approach

The project separates the frontend presentation layer from backend API processing and database operations. The backend further separates request handling, business logic, authentication, validation, and database access.

This architecture provides clear separation of responsibilities, easier maintenance, improved testability, and a structure that can be extended as the application grows.

## Project Objective
The objective of Scholar is to provide students with a centralized platform for managing academic and personal tasks.
The project demonstrates the complete development of a full-stack application involving:

```text
Flutter Application
        |
        v
REST API Communication
        |
        v
Express.js Backend
        |
        v
Authentication & Validation
        |
        v
Business Logic
        |
        v
Prisma ORM
        |
        v
PostgreSQL Database

```
## Future Improvements

- Push notifications for upcoming deadlines
- Recurring tasks
- Advanced task analytics
- Calendar synchronization
- Offline task synchronization
- Improved task search
- Additional user preferences
- Production monitoring and observability
