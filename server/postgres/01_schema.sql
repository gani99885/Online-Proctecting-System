-- Online Proctoring and Cheating Detection System
-- Member 1 PostgreSQL Schema
-- Run this file first in pgAdmin Query Tool or psql.

CREATE EXTENSION IF NOT EXISTS pgcrypto;

DROP TABLE IF EXISTS disputes CASCADE;
DROP TABLE IF EXISTS scores CASCADE;
DROP TABLE IF EXISTS answers CASCADE;
DROP TABLE IF EXISTS question_options CASCADE;
DROP TABLE IF EXISTS questions CASCADE;
DROP TABLE IF EXISTS exams CASCADE;
DROP TABLE IF EXISTS users CASCADE;

CREATE TABLE users (
    user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    full_name VARCHAR(120) NOT NULL,
    email VARCHAR(160) NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    role VARCHAR(30) NOT NULL CHECK (role IN ('student', 'teacher', 'proctor', 'admin')),
    phone VARCHAR(20),
    department VARCHAR(100),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE exams (
    exam_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title VARCHAR(180) NOT NULL,
    description TEXT,
    created_by UUID NOT NULL REFERENCES users(user_id) ON DELETE RESTRICT,
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ NOT NULL,
    duration_minutes INT NOT NULL CHECK (duration_minutes > 0),
    total_marks NUMERIC(7,2) NOT NULL DEFAULT 0 CHECK (total_marks >= 0),
    passing_marks NUMERIC(7,2) NOT NULL DEFAULT 0 CHECK (passing_marks >= 0),
    status VARCHAR(20) NOT NULL DEFAULT 'draft'
        CHECK (status IN ('draft', 'scheduled', 'active', 'completed', 'cancelled')),
    allow_camera BOOLEAN NOT NULL DEFAULT TRUE,
    allow_microphone BOOLEAN NOT NULL DEFAULT TRUE,
    proctoring_enabled BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    CONSTRAINT chk_exam_time CHECK (end_time > start_time),
    CONSTRAINT chk_passing_marks CHECK (passing_marks <= total_marks)
);

CREATE TABLE questions (
    question_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    exam_id UUID NOT NULL REFERENCES exams(exam_id) ON DELETE CASCADE,
    question_no INT NOT NULL CHECK (question_no > 0),
    question_text TEXT NOT NULL,
    question_type VARCHAR(20) NOT NULL
        CHECK (question_type IN ('MCQ_SINGLE', 'MCQ_MULTI', 'TRUE_FALSE', 'SHORT_TEXT')),
    marks NUMERIC(5,2) NOT NULL CHECK (marks > 0),
    negative_marks NUMERIC(5,2) NOT NULL DEFAULT 0 CHECK (negative_marks >= 0),
    correct_text_answer TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (exam_id, question_no),
    UNIQUE (exam_id, question_id)
);

-- Helper table for normalized options. This avoids storing all MCQ options in one column.
CREATE TABLE question_options (
    option_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    question_id UUID NOT NULL REFERENCES questions(question_id) ON DELETE CASCADE,
    option_label VARCHAR(10) NOT NULL,
    option_text TEXT NOT NULL,
    is_correct BOOLEAN NOT NULL DEFAULT FALSE,
    UNIQUE (question_id, option_label),
    UNIQUE (question_id, option_id)
);

CREATE TABLE answers (
    answer_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    exam_id UUID NOT NULL REFERENCES exams(exam_id) ON DELETE CASCADE,
    question_id UUID NOT NULL REFERENCES questions(question_id) ON DELETE CASCADE,
    selected_option_id UUID,
    answer_text TEXT,
    is_final BOOLEAN NOT NULL DEFAULT TRUE,
    is_correct BOOLEAN,
    marks_awarded NUMERIC(5,2) NOT NULL DEFAULT 0 CHECK (marks_awarded >= 0),
    answered_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (student_id, exam_id, question_id),
    FOREIGN KEY (exam_id, question_id) REFERENCES questions(exam_id, question_id) ON DELETE CASCADE,
    FOREIGN KEY (question_id, selected_option_id) REFERENCES question_options(question_id, option_id),
    CONSTRAINT chk_answer_has_value CHECK (selected_option_id IS NOT NULL OR answer_text IS NOT NULL)
);

CREATE TABLE scores (
    score_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    student_id UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    exam_id UUID NOT NULL REFERENCES exams(exam_id) ON DELETE CASCADE,
    total_marks NUMERIC(7,2) NOT NULL CHECK (total_marks >= 0),
    obtained_marks NUMERIC(7,2) NOT NULL DEFAULT 0 CHECK (obtained_marks >= 0),
    percentage NUMERIC(5,2) GENERATED ALWAYS AS (
        CASE
            WHEN total_marks = 0 THEN 0
            ELSE ROUND((obtained_marks / total_marks) * 100, 2)
        END
    ) STORED,
    result_status VARCHAR(20) NOT NULL DEFAULT 'pending'
        CHECK (result_status IN ('pending', 'pass', 'fail', 'under_review')),
    submitted_at TIMESTAMPTZ,
    evaluated_by UUID REFERENCES users(user_id) ON DELETE SET NULL,
    evaluated_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (student_id, exam_id),
    CONSTRAINT chk_obtained_total CHECK (obtained_marks <= total_marks)
);

CREATE TABLE disputes (
    dispute_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    score_id UUID NOT NULL REFERENCES scores(score_id) ON DELETE CASCADE,
    raised_by UUID NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    assigned_to UUID REFERENCES users(user_id) ON DELETE SET NULL,
    reason TEXT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'open'
        CHECK (status IN ('open', 'in_review', 'resolved', 'rejected')),
    resolution_note TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    resolved_at TIMESTAMPTZ,
    CONSTRAINT chk_resolution_time CHECK (resolved_at IS NULL OR resolved_at >= created_at)
);

CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_exams_status_time ON exams(status, start_time, end_time);
CREATE INDEX idx_questions_exam ON questions(exam_id);
CREATE INDEX idx_options_question ON question_options(question_id);
CREATE INDEX idx_answers_student_exam ON answers(student_id, exam_id);
CREATE INDEX idx_answers_exam_question ON answers(exam_id, question_id);
CREATE INDEX idx_scores_exam ON scores(exam_id);
CREATE INDEX idx_scores_student ON scores(student_id);
CREATE INDEX idx_disputes_status ON disputes(status);

-- Useful view for teacher/proctor dashboard.
CREATE OR REPLACE VIEW exam_score_summary AS
SELECT
    e.exam_id,
    e.title AS exam_title,
    COUNT(s.score_id) AS submitted_students,
    ROUND(AVG(s.obtained_marks), 2) AS average_marks,
    MAX(s.obtained_marks) AS highest_marks,
    MIN(s.obtained_marks) AS lowest_marks
FROM exams e
LEFT JOIN scores s ON s.exam_id = e.exam_id
GROUP BY e.exam_id, e.title;
