<?php
// submit_work.php

// Database connection
$host = 'localhost';
$dbname = 'worker_db';
$username = 'root'; // Adjust if you have a different MySQL username
$password = ''; // Adjust if you have a MySQL password

try {
    $pdo = new PDO("mysql:host=$host;dbname=$dbname", $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['error' => 'Database connection failed: ' . $e->getMessage()]);
    exit();
}

// Check if required POST parameters are provided
if (!isset($_POST['work_id']) || !isset($_POST['worker_id']) || !isset($_POST['submission_text'])) {
    http_response_code(400);
    echo json_encode(['error' => 'work_id, worker_id, and submission_text are required']);
    exit();
}

$work_id = intval($_POST['work_id']);
$worker_id = intval($_POST['worker_id']);
$submission_text = trim($_POST['submission_text']);

// Validate input
if (empty($submission_text)) {
    http_response_code(400);
    echo json_encode(['error' => 'submission_text cannot be empty']);
    exit();
}

try {
    // Insert submission into tbl_submissions
    $stmt = $pdo->prepare("
        INSERT INTO tbl_submissions (work_id, worker_id, submission_text, submitted_at)
        VALUES (:work_id, :worker_id, :submission_text, NOW())
    ");
    $stmt->execute([
        'work_id' => $work_id,
        'worker_id' => $worker_id,
        'submission_text' => $submission_text
    ]);

    // Optionally update task status in tbl_works to 'completed'
    $stmt = $pdo->prepare("
        UPDATE tbl_works 
        SET status = 'completed' 
        WHERE id = :work_id AND assigned_to = :worker_id
    ");
    $stmt->execute(['work_id' => $work_id, 'worker_id' => $worker_id]);

    // Return success response
    http_response_code(200);
    echo json_encode(['message' => 'Submission successful']);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['error' => 'Submission failed: ' . $e->getMessage()]);
}
?>