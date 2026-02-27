# Student Screening: Real World Project Opportunity

> **Lead / Reference:** Thiago Castilho
> **Duration:** 48 Hours

## Overview

Welcome! This repository represents a technical screening exercise designed to evaluate your readiness for a real-world enterprise project within the Centennial College ARIES department.

This is not just a test; it is an opportunity to demonstrate how you think, how you code, and how you communicate technical findings.

## Tasks

### Task 1 – Data Understanding (Documentation)

In this `README.md` (or a separate `DATA_REPORT.md` if you prefer), briefly describe:

- The main entities in the dataset (see `data/` folder).
- **Data Quality**: Identify issues such as missing values, duplicates, or inconsistent formatting (e.g., location names).
- **Schema**: Explain how you handled the `payload` field in the `events` table (Note: It contains JSON data).
- Assumptions you had to make.

---

### Task 2 – SQL Analysis

In `sql/queries.sql`, write valid SQL queries to answer the following questions. You can assume standard SQL syntax (e.g., PostgreSQL or SQLite).

1. **Number of users by region and platform.**
2. **Number of devices per user.**
3. **Event volume per device type per day.**
4. **Identify devices with unusually high event volume** (define "unusually high" in your comments).

_Please explain your assumptions using SQL comments._

---

### Task 3 – Exploratory Analysis (Python)

Using the notebook in `notebooks/analysis.ipynb`:

- Load and clean the provided data.
- Produce at least **3 meaningful charts**, such as:
  - Event volume over time.
  - Events per device or per user.
  - Comparison between Ayla vs Tuya devices.
- **Advanced Analysis (Bonus/Strong Signal)**:
  - **Correlation**: Check if specific event types or values correlate with higher activity.
  - **Clustering**: Can you group/cluster devices based on their reporting frequency or values? (e.g., "High usage" vs "Low usage" devices, or "Noisy" devices).

---

### Task 4 – Hypotheses & Questions

In the notebook or README:

- Propose **2–3 hypotheses** about user or device behavior.
  - _Example: “Users with multiple devices generate more frequent events.”_
- Show how you would test each hypothesis with the available data.
- Clearly state whether the data **supports**, **partially supports**, or **does not support** the hypothesis.

---

### Task 5 – Reflection

Answer briefly (in README or Notebook):

- What **additional data** would improve this analysis?
- What **limitations** prevent deeper insights?
- What would you explore next if this were Phase 0 of a larger project?

---

## Submission Instructions

1. **Fork** this repository.
2. **Commit often & clearly:** We want to see your progress.
   - Avoid one single massive commit.
   - Use meaningful commit messages (explain _why_, not just _what_).
3. **Submit the GitHub link** before the interview.

### Deliverables

- **Git repository link.**
- **Completed Notebook** (`notebooks/analysis.ipynb`).
- **SQL Queries** (`sql/queries.sql`).
- **Documentation** (updated `README.md` or `DATA_REPORT.md`).

---
