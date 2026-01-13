WITH quiz_data AS (
    SELECT
        quiz_id,
        CAST(created_at AS DATE) AS activity_date,
        participants,
        results_users,
        completion_rate
    FROM fact_quizzes
),
user_data AS (
    SELECT
        user_id,
        CAST(created_at AS DATE) AS join_date,
        is_active,
        rating_as_learner,
        time_spent_as_learner
    FROM dim_users
)
SELECT
    q.activity_date,
    COUNT(DISTINCT q.quiz_id) AS quizzes_created,
    SUM(q.participants) AS total_participants,
    COUNT(DISTINCT u.user_id) AS users_joined,
    SUM(CASE WHEN u.is_active = 1 THEN 1 ELSE 0 END) AS active_users
FROM quiz_data q
LEFT JOIN user_data u
    ON q.activity_date = u.join_date
GROUP BY q.activity_date
ORDER BY q.activity_date;
