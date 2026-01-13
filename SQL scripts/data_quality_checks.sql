SELECT quiz_id, COUNT(*)
FROM fact_quizzes
GROUP BY quiz_id
HAVING COUNT(*) > 1;

SELECT user_id, COUNT(*)
FROM dim_users
GROUP BY user_id
HAVING COUNT(*) > 1;


SELECT
    COUNT(*) AS total_rows,
    SUM(CASE WHEN quiz_id IS NULL THEN 1 ELSE 0 END) AS null_quiz_id,
    SUM(CASE WHEN created_at IS NULL THEN 1 ELSE 0 END) AS null_created_at
FROM fact_quizzes;


SELECT
    COUNT(*) AS total_rows,
    SUM(CASE WHEN user_id IS NULL THEN 1 ELSE 0 END) AS null_user_id,
    SUM(CASE WHEN created_at IS NULL THEN 1 ELSE 0 END) AS null_created_at
FROM dim_users;

-- For views 
SELECT participants,
results_users,
CASE 
    WHEN results_users > participants THEN results_users
    ELSE participants
END AS effective_participants
FROM fact_quizzes
WHERE results_users > participants;


SELECT
    COUNT(*) AS total_quizzes,
    SUM(CASE WHEN results_users > participants THEN 1 ELSE 0 END) AS mismatched_rows
FROM fact_quizzes;

SELECT *
FROM fact_quizzes
WHERE participants < 0
   OR results_users < 0
   OR completion_rate < 0;

SELECT
    MIN(participants),
    MAX(participants),
    AVG(participants)
FROM fact_quizzes;


SELECT DISTINCT live_quiz_difficulty
FROM fact_quizzes;

SELECT * FROM fact_quizzes


SELECT * FROM vw_dashboard_quiz_analytics
