# Milestone 4: ORM Tool Implementation (15 points)

In this milestone, you'll build an **Object-Relational Mapping (ORM)** tool from scratch in Python (or your preferred language). ORMs are critical in modern backend development, providing a clean and powerful way to interact with databases through objects instead of raw SQL.

> All examples are in Python but can be translated to other languages.

---

## Why ORMs Matter

ORMs are a standard in backend development for several reasons:

1. **SQL Abstraction** – Focus on logic, not low-level syntax.
2. **Maintainability** – Schema changes are easier to manage.
3. **Readability** – Code is cleaner and object-oriented.
4. **Portability** – Swap databases (e.g., MySQL → PostgreSQL) with minimal changes.
5. **Security** – ORMs reduce risk of SQL injection by managing inputs safely.

Understanding how ORMs work under the hood is a valuable industry skill. You’ll not only be better at using ORMs but also at debugging, optimizing, and extending them.

---

## Objectives

1. Map database tables to model classes.
2. Implement basic CRUD operations.
3. Build a query interface to allow flexible filtering.
4. Handle relationships (e.g., One-to-Many, Many-to-Many).
5. Build a reusable and extendable database interaction layer.

---

## Project Setup

### 1. IDE Setup

- Use your preferred IDE (we recommend PyCharm).
- Clone the milestone repository.
- Ensure your project structure looks like this:

```bash
/orm_project
├── /models
│   └── models.py
├── /orm
│   ├── __init__.py
│   ├── base.py
│   ├── columns.py
│   ├── datatypes.py
│   ├── dbconnectors.py
│   ├── migrations.py
├── __init__.py
├── requirements.txt
├── tests.py

```

### 2. **Install Required Dependencies**

- Install all the required dependencies using:

```bash 

pip install -r requirements.txt

```

### 3. **Implementation**

- Complete all `TODO` methods in the following files:
  - `base.py`
  - `columns.py`
  - `datatypes.py`
  - `migrations.py` *(optional, for extra credit)*

We’ll cover ORM concepts in an upcoming lecture to help you get started.

---

### 4. **Models**

- After finishing the core implementation, create your model classes in `models.py`.
- Models should represent the key tables from your previously designed schema.
- These models abstract away SQL and allow developers to interact with data through high-level methods.
- Delete the two example models after implementing your own.
- All models must inherit from the base class in `base.py`.

---

### 5. **Testing**

- Use `tests.py` to validate your model logic.
- The file includes sample tests—replace them with tests for your own models.
- Make sure your tests cover:
  - CRUD operations
  - Filters and joins
  - Any relationships you've implemented
- Test thoroughly to ensure your models perform without errors.

---

### 6. **Migrations (Optional, +2 Extra Credit)**

- Migrations allow your ORM to version-control schema changes (e.g., adding or altering tables).
- If you choose to implement `migrations.py`, make sure:
  - Migrations are created when the schema changes.
  - You test this functionality in `tests.py`.

---

## Grading Rubric

| File              | Deductions                                                     |
|-------------------|----------------------------------------------------------------|
| Any Missing files | -5 points                                                      |
| `columns.py`      | -0.5 points per incomplete method (up to -2 points)            |
| `datatypes.py`    | -0.5 points per incomplete method (up to -2 points)            |
| `base.py`         | -0.5 points per incomplete method (up to -6 points)            |
| `tests.py`        | -1 point per untested or incorrectly tested model feature      |
| Extra Credit      | +2 points for complete and tested implementation of migrations |

> Grading is consistent and based on this rubric to ensure fairness and transparency for all students.

---

## Submission Guidelines

- **Upload all required files with all your work implemented to this milestone directory.**
- **On Canvas:** Submit the direct URL to the *Milestone 4* folder in your repository.
- Submissions in the wrong directory will be treated as missing.

> Following these instructions is critical. Misplaced or incomplete submissions may receive major point deductions.

---

## Final Note 

You’ve just built a foundational ORM system—nicely done! Up next: Milestone 5, where you’ll **record a demo** showcasing your work. Lights, camera, architecture! 🍿🎬
