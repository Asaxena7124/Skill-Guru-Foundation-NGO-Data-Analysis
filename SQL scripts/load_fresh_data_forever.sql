TRUNCATE TABLE staging_quizzes;
BULK INSERT staging_quizzes
FROM 'D:\Data Analyst\The Skill Guru Foundation Project\final_clean_quiz_data.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001'
);

WITH new_quizzes AS (
    SELECT DISTINCT
        quiz_id,
        quiz_type,
        mode,
        language,
        TRY_CAST(participants AS INT) AS participants,
        TRY_CAST(results_users AS INT) AS results_users,
        TRY_CAST(completion_rate AS FLOAT) AS completion_rate,
        TRY_CAST(quiz_duration_min AS FLOAT) AS quiz_duration_min,
        live_quiz_subject,
        live_quiz_topic,
        live_quiz_difficulty,
        TRY_CAST(created_at AS DATETIMEOFFSET) AS created_at
    FROM staging_quizzes s
    WHERE quiz_id IS NOT NULL
      AND quiz_id <> ''
      AND NOT EXISTS (
          SELECT 1
          FROM fact_quizzes f
          WHERE f.quiz_id = s.quiz_id
      )
)
INSERT INTO fact_quizzes
SELECT * FROM new_quizzes;
