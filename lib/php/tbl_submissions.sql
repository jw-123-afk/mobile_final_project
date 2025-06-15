-- Drop the table if it exists
DROP TABLE IF EXISTS tbl_submissions;

-- Create the submissions table
CREATE TABLE tbl_submissions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    work_id INT NOT NULL,
    worker_id INT NOT NULL,
    submission_text TEXT NOT NULL,
    submitted_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (work_id) REFERENCES tbl_works(id),
    FOREIGN KEY (worker_id) REFERENCES workers(id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4; 