## 1. Database & Tech Stack
* **SQLite is strictly mandatory.** Do not use any other database system or alternative storage engines. This codebase serves as a standard template.

## 2. Methodology: Test-Driven Development (TDD)
* Strictly adhere to TDD workflow:
    1. **Model First:** Design and define the data model.
    2. **Write Tests:** Draft unit/integration tests covering expected behaviors.
    3. **Implementation:** Write the minimal business logic required to make tests pass.

## 3. Architecture & Design Patterns
* Maintain clear domain separation (Domain-Driven Design principles).
* Actively utilize established design patterns (e.g., **Factory**, **Builder**, **Facade**).

## 4. State Management
* Avoid prop-drilling or passing data down deep structural chains.
* Use **atomic/global state management** (conceptually similar to Jotai in React):
    * Shared entities (e.g., `userState`) must be accessible globally across the application.
    * For parent-child-grandchild structures, encapsulate state at the parent level, allowing child components to directly access and mutate it.

## 5. UI Requirements for Testing
* **Every single UI element must have a unique `id` attribute** to enable deterministic automated UI testing.

## 6. Additional
Please create folder 'tasks' with two folders inside : 'todo', 'done' with .gitkeep files

## 7. Additional
Do not think about how application should look like. The output of this file should be empty app with background color and simple "hello" word.
I will use flutter-init-prompt.md as an init file for building other apps so try to be detailed as you can 
Do not run application just ask if I want to start when you finish 
