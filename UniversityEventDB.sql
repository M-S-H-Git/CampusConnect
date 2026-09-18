-- University Event Management Database (MySQL)

-- Users Table
CREATE TABLE Users (
  UserID INT AUTO_INCREMENT PRIMARY KEY,
  UserName VARCHAR(100) NOT NULL,
  Email VARCHAR(100) UNIQUE NOT NULL,
  PasswordHash VARCHAR(255) NOT NULL,
  Role VARCHAR(20) NOT NULL CHECK (Role IN ('Admin', 'Attendee'))
);

-- Venues Table
CREATE TABLE Venues (
  VenueID INT AUTO_INCREMENT PRIMARY KEY,
  VenueName VARCHAR(100) NOT NULL,
  Location VARCHAR(200),
  Capacity INT CHECK (Capacity >= 0)
);

-- Events Table
CREATE TABLE Events (
  EventID INT AUTO_INCREMENT PRIMARY KEY,
  EventName VARCHAR(200) NOT NULL,
  StartDateTime DATETIME NOT NULL,
  EndDateTime DATETIME,
  VenueID INT NOT NULL,
  Capacity INT CHECK (Capacity >= 0),
  Status VARCHAR(20),
  Description TEXT,
  FOREIGN KEY (VenueID) REFERENCES Venues(VenueID)
);

-- Registrations Table
CREATE TABLE Registrations (
  RegistrationID INT AUTO_INCREMENT PRIMARY KEY,
  EventID INT NOT NULL,
  UserID INT NOT NULL,
  RegistrationDate DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (EventID) REFERENCES Events(EventID),
  FOREIGN KEY (UserID) REFERENCES Users(UserID),
  UNIQUE (EventID, UserID)
);

-- Feedback Table
CREATE TABLE Feedback (
  FeedbackID INT AUTO_INCREMENT PRIMARY KEY,
  EventID INT NOT NULL,
  UserID INT NOT NULL,
  Rating TINYINT CHECK (Rating BETWEEN 1 AND 5),
  Comments TEXT,
  FeedbackDate DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (EventID) REFERENCES Events(EventID),
  FOREIGN KEY (UserID) REFERENCES Users(UserID)
);

-- Trigger to enforce event capacity
DELIMITER $$
CREATE TRIGGER trg_check_capacity
BEFORE INSERT ON Registrations
FOR EACH ROW
BEGIN
  DECLARE currentCount INT;
  SELECT COUNT(*) INTO currentCount
  FROM Registrations
  WHERE EventID = NEW.EventID;

  IF currentCount >= (SELECT Capacity FROM Events WHERE EventID = NEW.EventID) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Event has reached maximum capacity';
  END IF;
END;
$$
DELIMITER ;

-- Procedure to get event feedback statistics
DELIMITER $$
CREATE PROCEDURE GetEventStats(IN eventID INT)
BEGIN
  SELECT 
    AVG(Rating) AS AvgRating,
    COUNT(*) AS TotalFeedbacks
  FROM Feedback
  WHERE EventID = eventID;
END;
$$
DELIMITER ;

-- View to show public event listing with status
CREATE VIEW PublicEventView AS
SELECT 
  e.EventID,
  e.EventName,
  e.StartDateTime,
  e.EndDateTime,
  v.VenueName,
  CASE
    WHEN NOW() < e.StartDateTime THEN 'Upcoming'
    WHEN NOW() BETWEEN e.StartDateTime AND e.EndDateTime THEN 'Ongoing'
    ELSE 'Completed'
  END AS Status
FROM Events e
JOIN Venues v ON e.VenueID = v.VenueID;

-- Sample Data Inserts
INSERT INTO Users (UserName, Email, PasswordHash, Role) VALUES
  ('AliceAdmin', 'alice@uni.edu', 'hashed_pwd_1', 'Admin'),
  ('BobStudent', 'bob@uni.edu', 'hashed_pwd_2', 'Attendee'),
  ('CarolStudent', 'carol@uni.edu', 'hashed_pwd_3', 'Attendee');

INSERT INTO Venues (VenueName, Location, Capacity) VALUES
  ('Main Auditorium', 'Block A', 200),
  ('Tech Hall', 'Block B', 100);

INSERT INTO Events (EventName, StartDateTime, EndDateTime, VenueID, Capacity, Status, Description) VALUES
  ('AI Seminar', '2025-07-20 10:00:00', '2025-07-20 12:00:00', 1, 100, 'Upcoming', 'Discussion on AI trends'),
  ('Cloud Workshop', '2025-06-10 14:00:00', '2025-06-10 17:00:00', 2, 50, 'Completed', 'Hands-on cloud session');

INSERT INTO Registrations (EventID, UserID) VALUES
  (1, 2),
  (1, 3),
  (2, 3);

INSERT INTO Feedback (EventID, UserID, Rating, Comments) VALUES
  (2, 3, 4, 'Great session!');

-- Sample Queries
-- Event List
SELECT * FROM PublicEventView;

-- Registration Confirmation
SELECT r.RegistrationID, u.UserName, e.EventName, r.RegistrationDate
FROM Registrations r
JOIN Users u ON r.UserID = u.UserID
JOIN Events e ON r.EventID = e.EventID;

-- Feedback Stats
CALL GetEventStats(2);
