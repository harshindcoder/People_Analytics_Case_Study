-- Query 1: Overall Retention Rate
SELECT 
    COUNT(*) AS total_employees,
    SUM(CASE WHEN stayed = TRUE THEN 1 ELSE 0 END) AS employees_retained,
    SUM(CASE WHEN stayed = FALSE THEN 1 ELSE 0 END) AS employees_left,
    ROUND(100.0 * SUM(CASE WHEN stayed = TRUE THEN 1 ELSE 0 END) / COUNT(*), 2) AS retention_rate_percent
FROM employee_survey_2024;

-- Query 2: Average Scores: Retained vs. Left Employees
SELECT 
    stayed,
    ROUND(AVG(hiring_process_duration_days), 2) AS avg_hiring_duration,
    ROUND(AVG(onboarding_rating), 2) AS avg_onboarding_rating,
    ROUND(AVG(evaluation_feedback_rating), 2) AS avg_feedback_rating,
    ROUND(AVG(job_satisfaction_rating), 2) AS avg_job_satisfaction,
    ROUND(AVG(compensation_rating), 2) AS avg_compensation_rating
FROM employee_survey_2024
GROUP BY stayed;

-- Query 3: Distribution of Job Satisfaction Ratings by Retention Status
SELECT 
    stayed,
    job_satisfaction_rating
FROM employee_survey_2024
ORDER BY stayed;

-- Query 4: Long Hiring Duration vs. Leaving
SELECT 
    COUNT(*) AS total_long_hiring,
    SUM(CASE WHEN stayed = FALSE THEN 1 ELSE 0 END) AS left_after_long_hiring,
    ROUND(100.0 * SUM(CASE WHEN stayed = FALSE THEN 1 ELSE 0 END) / COUNT(*), 2) AS percent_left
FROM employee_survey_2024
WHERE hiring_process_duration_days > 30;

-- Query 5: Frequency of Reasons for Leaving
SELECT 
    reason_for_leaving,
    COUNT(*) AS frequency
FROM employee_survey_2024
WHERE stayed = FALSE
GROUP BY reason_for_leaving
ORDER BY frequency DESC;

-- Query 6: Export Reasons for Leaving for LLM Processing
SELECT 
    employee_id,
    reason_for_leaving
FROM employee_survey_2024
WHERE stayed = FALSE;

-- Query 7: Retention Rate by Job Satisfaction Levels
SELECT 
    CASE 
        WHEN job_satisfaction_rating BETWEEN 1 AND 2 THEN 'Low'
        WHEN job_satisfaction_rating BETWEEN 3 AND 4 THEN 'Medium'
        WHEN job_satisfaction_rating = 5 THEN 'High'
    END AS satisfaction_level,
    COUNT(*) AS total_employees,
    SUM(CASE WHEN stayed = TRUE THEN 1 ELSE 0 END) AS retained,
    ROUND(100.0 * SUM(CASE WHEN stayed = TRUE THEN 1 ELSE 0 END) / COUNT(*), 2) AS retention_rate_percent
FROM employee_survey_2024
GROUP BY satisfaction_level
ORDER BY retention_rate_percent DESC;

-- Query 8: Net Promoter Score (NPS) Calculation
-- Promoters: NPS score 9-10 | Passives: 7-8 | Detractors: 0-6
SELECT
    ROUND(100.0 * SUM(CASE WHEN nps_score BETWEEN 9 AND 10 THEN 1 ELSE 0 END) / COUNT(*), 2) AS promoters_percent,
    ROUND(100.0 * SUM(CASE WHEN nps_score BETWEEN 7 AND 8 THEN 1 ELSE 0 END) / COUNT(*), 2) AS passives_percent,
    ROUND(100.0 * SUM(CASE WHEN nps_score BETWEEN 0 AND 6 THEN 1 ELSE 0 END) / COUNT(*), 2) AS detractors_percent,
    ROUND(
        (SUM(CASE WHEN nps_score BETWEEN 9 AND 10 THEN 1 ELSE 0 END) * 1.0 / COUNT(*) * 100) -
        (SUM(CASE WHEN nps_score BETWEEN 0 AND 6 THEN 1 ELSE 0 END) * 1.0 / COUNT(*) * 100),
        2
    ) AS net_promoter_score
FROM employee_survey_2024;