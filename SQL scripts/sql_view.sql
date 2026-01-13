CREATE VIEW vw_dashboard_quiz_analytics AS
SELECT
    -- Identifiers
    q.quiz_id,
    q.quiz_type,
    q.mode,
    q.language,

    -- Content metadata
    q.live_quiz_subject,
    q.live_quiz_topic,
    q.live_quiz_difficulty,

    -- Original metrics (raw, for transparency)
    q.participants AS reported_participants,
    q.results_users AS reported_results_users,

    -- Safe metrics (business-approved)
    CASE
        WHEN q.results_users > q.participants THEN q.results_users
        ELSE q.participants
    END AS effective_participants,

    q.results_users AS completed_users,

    CASE
        WHEN q.participants IS NULL OR q.participants = 0 THEN NULL
        ELSE ROUND((q.results_users * 100.0) / q.participants, 2)
    END AS safe_completion_rate,

    q.quiz_duration_min,

    -- Time
    q.created_at,
    CAST(q.created_at AS DATE) AS quiz_date,
    YEAR(q.created_at) AS quiz_year,
    MONTH(q.created_at) AS quiz_month,
    DATENAME(MONTH, q.created_at) AS quiz_month_name,
    DATENAME(WEEKDAY, q.created_at) AS quiz_day,
    DATEPART(HOUR, q.created_at) AS quiz_hour,

    -- Flags (for filtering)
    CASE 
        WHEN q.results_users > q.participants THEN 1
        ELSE 0
    END AS has_participant_mismatch

FROM fact_quizzes q;


SELECT COUNT(*) FROM vw_dashboard_quiz_analytics;

SELECT
    SUM(has_participant_mismatch) AS mismatches,
    COUNT(*) AS total_quizzes
FROM vw_dashboard_quiz_analytics;

SELECT TOP 5 *
FROM vw_dashboard_quiz_analytics
ORDER BY safe_completion_rate DESC;

SELECT * FROM vw_dashboard_quiz_analytics