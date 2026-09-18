# CampusConnect : An Integrated Database Solution for University Event Management

CampusConnect is a MySQL database design for managing university events, venues, users, registrations, and attendee feedback. The project demonstrates relational modeling, primary and foreign keys, uniqueness constraints, validation checks, triggers, stored procedures, views, sample data, and reporting queries.

## Features

- User records with Admin and Attendee roles
- Venue management with location and capacity constraints
- Event scheduling with venue association, capacity, status, and descriptions
- Event registration with duplicate-registration prevention
- Attendee feedback with ratings from 1 to 5
- Registration trigger that prevents event capacity from being exceeded
- Stored procedure for event feedback statistics
- Public event view showing Upcoming, Ongoing, or Completed status
- Sample inserts and queries for demonstration

## Database Schema

```text
Users 1 ----< Registrations >---- 1 Events >---- 1 Venues
                  |
                  v
               Feedback
```

### Tables

- `Users`: accounts, email addresses, password hashes, and roles
- `Venues`: event locations and maximum venue capacity
- `Events`: event details, dates, venue, event capacity, and description
- `Registrations`: many-to-many relationship between users and events
- `Feedback`: attendee ratings and comments for events

### Database Objects

- `trg_check_capacity`: rejects a registration when the event has reached its configured capacity
- `GetEventStats(eventID)`: returns average rating and total feedback count for an event
- `PublicEventView`: presents public event information with a calculated status

## Requirements

- MySQL 8.0 or compatible MySQL server
- MySQL Workbench, the MySQL command-line client, or another SQL client

The script uses MySQL-specific features including `AUTO_INCREMENT`, `DELIMITER`, `SIGNAL`, stored procedures, and triggers.

## Run The Project

Create a database and select it:

```sql
CREATE DATABASE CampusConnect;
USE CampusConnect;
```

Run the complete script:

```bash
mysql -u your_username -p CampusConnect < UniversityEventDB.sql
```

Alternatively, open `UniversityEventDB.sql` in MySQL Workbench and execute it after selecting the `CampusConnect` schema.

The script creates the schema, trigger, procedure, view, sample records, and demonstration queries. The sample administrator and attendee records use placeholder password hashes and are for database demonstration only.

## Example Queries

List public events:

```sql
SELECT * FROM PublicEventView;
```

Show registration confirmations:

```sql
SELECT r.RegistrationID, u.UserName, e.EventName, r.RegistrationDate
FROM Registrations r
JOIN Users u ON r.UserID = u.UserID
JOIN Events e ON r.EventID = e.EventID;
```

Get feedback statistics for event 2:

```sql
CALL GetEventStats(2);
```

## Project Files

```text
.
|-- UniversityEventDB.sql       Schema, database objects, sample data, and queries
|-- CampusConnect_Report.pdf    Project report
|-- Screenshot of Output.png    Example execution output
`-- README.md
```

## Data And Security Notes

The sample `PasswordHash` values are placeholders. A production application must hash passwords with a password-specific algorithm such as Argon2id or bcrypt, never store plaintext passwords, use least-privilege database accounts, validate input, and protect database credentials outside source control.

The capacity trigger protects registration inserts, but production systems should also consider transaction isolation and concurrency behavior when multiple registrations occur at the same time.

## Report

See [CampusConnect_Report.pdf](CampusConnect_Report.pdf) for the full database design, rationale, implementation details, and output evidence.

## Author

Muhammed Salah Hussain  
GitHub: [M-S-H-Git](https://github.com/M-S-H-Git)  
LinkedIn: [Muhammed Salah Hussain](https://linkedin.com/in/muhammed-salah-hussain-231797388)
