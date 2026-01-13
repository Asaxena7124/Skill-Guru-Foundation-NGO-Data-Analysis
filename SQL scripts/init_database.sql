CREATE DATABASE SkillGuruDataBase;
GO

USE SkillGuruDataBase;
GO


-- DROP DATABASE SkillGuruAnalytics

CREATE TABLE dim_users (
    user_id VARCHAR(50) PRIMARY KEY,
    full_name VARCHAR(200),
    email VARCHAR(200),
    phone_number VARCHAR(20),
    class VARCHAR(10),
    class_group VARCHAR(50),
    school VARCHAR(200),
    language VARCHAR(50),
    gender VARCHAR(20),
    state VARCHAR(100),
    city VARCHAR(100),
    created_at DATETIME,
    is_active BIT,
    rating_as_learner FLOAT,
    time_spent_as_learner FLOAT
);

CREATE TABLE fact_quizzes (
    quiz_id VARCHAR(50) PRIMARY KEY,
    quiz_type VARCHAR(50),
    mode VARCHAR(50),
    language VARCHAR(50),
    participants INT,
    results_users INT,
    completion_rate FLOAT,
    quiz_duration_min FLOAT,
    live_quiz_subject VARCHAR(200),
    live_quiz_topic VARCHAR(200),
    live_quiz_difficulty VARCHAR(50),
    created_at DATETIME
);

BULK INSERT dim_users
FROM 'D:\Data Analyst\The Skill Guru Foundation Project\final_clean_user_data.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2,
    FIELDQUOTE = '"',
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n'
);

SELECT * FROM dim_users

CREATE TABLE staging_users (
    user_id VARCHAR(50),
    full_name VARCHAR(200),
    email VARCHAR(200),
    phone_number VARCHAR(20),
    class VARCHAR(10),
    class_group VARCHAR(50),
    school VARCHAR(200),
    language VARCHAR(50),
    gender VARCHAR(20),
    state VARCHAR(100),
    city VARCHAR(100),
    created_at DATETIME,
    is_active INT,
    rating_as_learner FLOAT,
    time_spent_as_learner FLOAT
);

BULK INSERT staging_users
FROM 'D:\Data Analyst\The Skill Guru Foundation Project\final_clean_user_data.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2
);

SELECT * FROM staging_users

CREATE TABLE staging_quizzes (
    quiz_id VARCHAR(50),
    quiz_type VARCHAR(50),
    mode VARCHAR(50),
    language VARCHAR(50),
    participants INT,
    results_users INT,
    completion_rate FLOAT,
    quiz_duration_min FLOAT,
    live_quiz_subject VARCHAR(200),
    live_quiz_topic VARCHAR(200),
    live_quiz_difficulty VARCHAR(50),
    created_at DATETIME
);

BULK INSERT staging_quizzes
FROM 'D:\Data Analyst\The Skill Guru Foundation Project\final_clean_quiz_data.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001',
    TABLOCK
);

SELECT * FROM staging_quizzes

DROP TABLE staging_quizzes;

CREATE TABLE staging_quizzes (
    quiz_id VARCHAR(50),
    quiz_type VARCHAR(50),
    mode VARCHAR(50),
    language VARCHAR(50),
    participants VARCHAR(50),          -- 👈 VARCHAR on purpose
    results_users VARCHAR(50),          -- 👈 VARCHAR
    completion_rate VARCHAR(50),        -- 👈 VARCHAR
    quiz_duration_min VARCHAR(50),      -- 👈 VARCHAR
    live_quiz_subject VARCHAR(200),
    live_quiz_topic VARCHAR(200),
    live_quiz_difficulty VARCHAR(50),
     created_at VARCHAR(MAX)   -- 👈 increased size (KEY FIX)
);


BULK INSERT staging_quizzes
FROM 'D:\Data Analyst\The Skill Guru Foundation Project\final_clean_quiz_data.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001',
    TABLOCK
);

SELECT * FROM staging_quizzes

SELECT created_at
FROM fact_quizzes;


EXEC sp_help fact_quizzes;


ALTER TABLE fact_quizzes
ALTER COLUMN created_at DATETIMEOFFSET;


INSERT INTO fact_quizzes (
    quiz_id,
    quiz_type,
    mode,
    language,
    participants,
    results_users,
    completion_rate,
    quiz_duration_min,
    live_quiz_subject,
    live_quiz_topic,
    live_quiz_difficulty,
    created_at
)
SELECT DISTINCT
    quiz_id,
    quiz_type,
    mode,
    language,

    TRY_CAST(participants AS INT),
    TRY_CAST(results_users AS INT),
    TRY_CAST(completion_rate AS FLOAT),
    TRY_CAST(quiz_duration_min AS FLOAT),

    live_quiz_subject,
    live_quiz_topic,
    live_quiz_difficulty,

    TRY_CAST(created_at AS DATETIMEOFFSET)
FROM staging_quizzes
WHERE quiz_id IS NOT NULL
  AND quiz_id <> '';

SELECT 
    kc.name AS constraint_name,
    c.name AS column_name
FROM sys.key_constraints kc
JOIN sys.index_columns ic 
    ON kc.parent_object_id = ic.object_id 
   AND kc.unique_index_id = ic.index_id
JOIN sys.columns c 
    ON ic.object_id = c.object_id 
   AND ic.column_id = c.column_id
WHERE kc.parent_object_id = OBJECT_ID('fact_quizzes');


ALTER TABLE fact_quizzes
DROP CONSTRAINT PK__fact_qui__2D7053EC1A5C2891;

ALTER TABLE fact_quizzes
ADD CONSTRAINT PK_fact_quizzes PRIMARY KEY (quiz_id);

SELECT DISTINCT quiz_id
FROM staging_quizzes;

SELECT TOP 1 *
FROM staging_quizzes;


INSERT INTO fact_quizzes (
    quiz_id,
    quiz_type,
    mode,
    language,
    participants,
    results_users,
    completion_rate,
    quiz_duration_min,
    live_quiz_subject,
    live_quiz_topic,
    live_quiz_difficulty,
    created_at
)
SELECT DISTINCT
    quiz_type AS quiz_id,          -- 👈 REAL FIX
    quiz_id   AS quiz_type,        -- 👈 swap
    mode,
    language,
    TRY_CAST(participants AS INT),
    TRY_CAST(results_users AS INT),
    TRY_CAST(completion_rate AS FLOAT),
    TRY_CAST(quiz_duration_min AS FLOAT),
    live_quiz_subject,
    live_quiz_topic,
    live_quiz_difficulty,
    TRY_CAST(created_at AS DATETIMEOFFSET)
FROM staging_quizzes
WHERE quiz_type IS NOT NULL
  AND quiz_type <> '';


SELECT DISTINCT quiz_id
FROM fact_quizzes;

SELECT DISTINCT quiz_id FROM staging_quizzes;

DROP TABLE staging_quizzes;

CREATE TABLE staging_quizzes (
    quiz_type            VARCHAR(MAX),
    quiz_id              VARCHAR(MAX),
    status               VARCHAR(MAX),
    mode                 VARCHAR(MAX),
    language             VARCHAR(MAX),
    questions            VARCHAR(MAX),
    sec_per_question     VARCHAR(MAX),
    creator_name         VARCHAR(MAX),
    creator_id           VARCHAR(MAX),
    school               VARCHAR(MAX),
    participants         VARCHAR(MAX),
    results_users        VARCHAR(MAX),
    winner_name          VARCHAR(MAX),
    winner_score         VARCHAR(MAX),
    winner_time          VARCHAR(MAX),
    winner_final_score   VARCHAR(MAX),
    created_at           VARCHAR(MAX),
    started_at           VARCHAR(MAX),
    completed_at         VARCHAR(MAX),
    description          VARCHAR(MAX),
    live_quiz_label      VARCHAR(MAX),
    live_quiz_subject    VARCHAR(MAX),
    live_quiz_topic      VARCHAR(MAX),
    live_quiz_difficulty VARCHAR(MAX),
    live_quiz_slot       VARCHAR(MAX),
    completion_rate      VARCHAR(MAX),
    quiz_duration_min    VARCHAR(MAX),
    quiz_category        VARCHAR(MAX),
    is_completed         VARCHAR(MAX),
    engagement_bucket    VARCHAR(MAX),
    quiz_year            VARCHAR(MAX),
    quiz_month           VARCHAR(MAX),
    quiz_month_name      VARCHAR(MAX),
    quiz_day             VARCHAR(MAX),
    quiz_hour            VARCHAR(MAX)
);

BULK INSERT staging_quizzes
FROM 'D:\Data Analyst\The Skill Guru Foundation Project\final_clean_quiz_data.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001',
    TABLOCK
);

SELECT COUNT(*) FROM staging_quizzes;

SELECT TOP 5
    quiz_id,
    quiz_type,
    created_at,
    description
FROM staging_quizzes;



TRUNCATE TABLE fact_quizzes;
INSERT INTO fact_quizzes (
    quiz_id,
    quiz_type,
    mode,
    language,
    participants,
    results_users,
    completion_rate,
    quiz_duration_min,
    live_quiz_subject,
    live_quiz_topic,
    live_quiz_difficulty,
    created_at
)
SELECT DISTINCT
    quiz_id,
    quiz_type,
    mode,
    language,
    TRY_CAST(participants AS INT),
    TRY_CAST(results_users AS INT),
    TRY_CAST(completion_rate AS FLOAT),
    TRY_CAST(quiz_duration_min AS FLOAT),
    live_quiz_subject,
    live_quiz_topic,
    live_quiz_difficulty,
    TRY_CAST(created_at AS DATETIMEOFFSET)
FROM staging_quizzes
WHERE quiz_id IS NOT NULL
  AND quiz_id <> '';


ALTER TABLE fact_quizzes
ALTER COLUMN live_quiz_difficulty VARCHAR(MAX);

SELECT COUNT(*) FROM fact_quizzes;
SELECT TOP 5 live_quiz_difficulty FROM fact_quizzes;

