-- Online Proctoring and Cheating Detection System
-- Member 1 PostgreSQL Sample Data
-- Run this file after postgres/01_schema.sql.

INSERT INTO users (user_id, full_name, email, password_hash, role, phone, department) VALUES
('11111111-1111-1111-1111-111111111111', 'Aarav Sharma', 'aarav.student@example.com', 'hashed_password_student', 'student', '9876543210', 'Computer Science'),
('22222222-2222-2222-2222-222222222222', 'Meera Iyer', 'meera.teacher@example.com', 'hashed_password_teacher', 'teacher', '9876543211', 'Computer Science'),
('33333333-3333-3333-3333-333333333333', 'Rohan Gupta', 'rohan.proctor@example.com', 'hashed_password_proctor', 'proctor', '9876543212', 'Examination Cell'),
('44444444-4444-4444-4444-444444444444', 'Admin User', 'admin@example.com', 'hashed_password_admin', 'admin', '9876543213', 'Administration');

INSERT INTO exams (
    exam_id, title, description, created_by, start_time, end_time,
    duration_minutes, total_marks, passing_marks, status,
    allow_camera, allow_microphone, proctoring_enabled
) VALUES (
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    'DBMS Unit Test 1',
    'Sample online proctored test for DBMS basics.',
    '22222222-2222-2222-2222-222222222222',
    '2026-05-10 10:00:00+05:30',
    '2026-05-10 11:00:00+05:30',
    60,
    20.00,
    8.00,
    'scheduled',
    TRUE,
    TRUE,
    TRUE
);

INSERT INTO questions (question_id, exam_id, question_no, question_text, question_type, marks, negative_marks) VALUES
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb1', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 1, 'Which key uniquely identifies a row in a table?', 'MCQ_SINGLE', 5.00, 0.00),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb2', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 2, 'Which SQL command is used to retrieve data from a table?', 'MCQ_SINGLE', 5.00, 0.00),
('bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb3', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 3, 'Explain the difference between primary key and foreign key.', 'SHORT_TEXT', 10.00, 0.00);

INSERT INTO question_options (option_id, question_id, option_label, option_text, is_correct) VALUES
('cccccccc-cccc-cccc-cccc-cccccccccc11', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb1', 'A', 'Primary Key', TRUE),
('cccccccc-cccc-cccc-cccc-cccccccccc12', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb1', 'B', 'Foreign Key', FALSE),
('cccccccc-cccc-cccc-cccc-cccccccccc13', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb1', 'C', 'Candidate List', FALSE),
('cccccccc-cccc-cccc-cccc-cccccccccc14', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb1', 'D', 'Index File', FALSE),

('cccccccc-cccc-cccc-cccc-cccccccccc21', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb2', 'A', 'INSERT', FALSE),
('cccccccc-cccc-cccc-cccc-cccccccccc22', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb2', 'B', 'SELECT', TRUE),
('cccccccc-cccc-cccc-cccc-cccccccccc23', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb2', 'C', 'UPDATE', FALSE),
('cccccccc-cccc-cccc-cccc-cccccccccc24', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb2', 'D', 'DELETE', FALSE);

INSERT INTO answers (
    answer_id, student_id, exam_id, question_id, selected_option_id,
    answer_text, is_final, is_correct, marks_awarded, answered_at
) VALUES
('dddddddd-dddd-dddd-dddd-dddddddddd01', '11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb1', 'cccccccc-cccc-cccc-cccc-cccccccccc11', NULL, TRUE, TRUE, 5.00, '2026-05-10 10:10:00+05:30'),
('dddddddd-dddd-dddd-dddd-dddddddddd02', '11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb2', 'cccccccc-cccc-cccc-cccc-cccccccccc22', NULL, TRUE, TRUE, 5.00, '2026-05-10 10:18:00+05:30'),
('dddddddd-dddd-dddd-dddd-dddddddddd03', '11111111-1111-1111-1111-111111111111', 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa', 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbb3', NULL, 'A primary key uniquely identifies records in its own table. A foreign key refers to a primary key in another table and creates a relationship.', TRUE, TRUE, 8.00, '2026-05-10 10:45:00+05:30');

INSERT INTO scores (
    score_id, student_id, exam_id, total_marks, obtained_marks,
    result_status, submitted_at, evaluated_by, evaluated_at
) VALUES (
    'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee',
    '11111111-1111-1111-1111-111111111111',
    'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
    20.00,
    18.00,
    'pass',
    '2026-05-10 10:50:00+05:30',
    '22222222-2222-2222-2222-222222222222',
    '2026-05-10 11:05:00+05:30'
);

INSERT INTO disputes (
    dispute_id, score_id, raised_by, assigned_to, reason, status, resolution_note, created_at
) VALUES (
    'ffffffff-ffff-ffff-ffff-ffffffffffff',
    'eeeeeeee-eeee-eeee-eeee-eeeeeeeeeeee',
    '11111111-1111-1111-1111-111111111111',
    '22222222-2222-2222-2222-222222222222',
    'Student requested rechecking of descriptive answer marks.',
    'open',
    NULL,
    '2026-05-10 12:00:00+05:30'
);
