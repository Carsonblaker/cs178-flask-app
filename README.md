# Workout Tracker

**CS178: Cloud and Database Systems — Project #1**
**Author:** Carson Blaker
**GitHub:** Carsonblaker
---

## Overview

This project is a workout tracking web application built with Flask. It allows users to browse a library of exercises stored in a MySQL database, and log their personal workout sessions using DynamoDB. The app is designed for anyone who wants to track their gym activity and review their workout history over time.

---

## Technologies Used

- **Flask** — Python web framework
- **AWS EC2** — hosts the running Flask application
- **AWS RDS (MySQL)** — relational database storing the exercise library (exercises, sets, and reps)
- **AWS DynamoDB** — non-relational database storing personal workout session logs
- **GitHub Actions** — auto-deploys code from GitHub to EC2 on push

---

## Project Structure

```
cs178-flask-app/
├── flaskapp.py          # Main Flask application — routes and app logic
├── dbCode.py            # Database helper functions (MySQL + DynamoDB)
├── creds.py      # Sample credentials file (see Credential Setup below)
├── templates/
│   ├── home.html           # Landing page
│   ├── display_exercises.html  # Shows exercise library from MySQL
│   ├── log_workout.html    # Form to log a new workout session (DynamoDB)
│   ├── view_logs.html      # View, edit, and delete workout logs (DynamoDB)
    ├── display_users.html # Creates a way to create the user for the exercise
│   └── edit_log.html       # Edit an existing workout log entry
├── .gitignore           # Excludes creds.py and other sensitive files
└── README.md
```

---

## How to Run Locally

1. Clone the repository:

   ```bash
   git clone https://github.com/your-username/cs178-flask-app.git
   cd cs178-flask-app
   ```

2. Install dependencies:

   ```bash
   pip3 install flask pymysql boto3
   ```

3. Set up your credentials (see Credential Setup below)

4. Run the app:

   ```bash
   python3 flaskapp.py
   ```

5. Open your browser and go to `http://127.0.0.1:8080`

---

## How to Access in the Cloud

The app is deployed on an AWS EC2 instance. To view the live version:

```
http://[your-ec2-public-ip]:8080
```

_(Note: the EC2 instance may not be running after project submission.)_

---

## Credential Setup

This project requires a `creds.py` file that is **not included in this repository** for security reasons.

Create a file called `creds.py` in the project root with the following format (see `creds_sample.py` for reference):

```python
# creds.py — do not commit this file
host = "your-rds-endpoint"
user = "admin"
password = "your-password"
db = "workout_tracker"
region = "us-east-1"
```

---

## Database Design

### SQL (MySQL on RDS)

The relational database stores a library of exercises and workout performance data across three tables:

- `exercise` — stores each exercise (e.g. Bench Press, Squat); primary key is `exercise_id`
- `workout_set` — stores each set performed for an exercise (weight, set number, timestamp); foreign key links to `exercise`
- `rep` — stores individual reps within a set including a form rating; foreign key links to `workout_set`

The JOIN query used in this project joins all three tables (`exercise → workout_set → rep`) to produce a full workout log showing each exercise name, set number, weight used, total reps performed, and average form score.

### DynamoDB

- **Table name:** `workout_log`
- **Partition key:** `username` (String)
- **Sort key:** `log_date` (String, format: YYYY-MM-DD)
- **Other attributes:** `exercises_done`, `notes`
- **Used for:** storing free-form personal workout session logs per user, allowing users to record what they did on a given day and add notes about the session

---

## CRUD Operations

| Operation | Route           | Description                                              |
| --------- | --------------- | -------------------------------------------------------- |
| Create    | `/log-workout`  | Logs a new workout session entry to DynamoDB             |
| Read      | `/view-logs`    | Looks up and displays all workout logs for a username    |
| Update    | `/edit-log`     | Edits the exercises and notes on an existing log entry   |
| Delete    | `/delete-log`   | Deletes a workout log entry by username and date         |

---

## Challenges and Insights

One of the trickier parts of this project was connecting the Flask app to both a relational and non-relational database at the same time and keeping that logic clean. Separating all database functions into `dbCode.py` made this much more manageable. Setting up the GitHub Actions auto-deploy pipeline was also a learning curve, but once it was working it made iterating on the project much faster — every `git push` automatically updated the live app on EC2.

---

## AI Assistance

Claude was used as a debugging and troubleshooting assistant throughout this project. When errors came up such as issues with DynamoDB connections, Flask route behavior, and database integration. Claude was asked to help identify the problem and explain what was going wrong. 