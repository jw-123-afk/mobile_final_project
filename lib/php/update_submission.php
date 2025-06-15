<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: POST');
header('Access-Control-Allow-Headers: Content-Type');

// Handle preflight OPTIONS request
if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

// Check if the request method is POST
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['success' => false, 'message' => 'Only POST method is allowed']);
    exit();
}

// Get JSON input
$data = json_decode(file_get_contents('php://input'), true);

// Validate input
if (!isset($data['submission_id']) || empty($data['submission_id']) || 
    !isset($data['submission_text']) || empty($data['submission_text'])) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Submission ID and text are required']);
    exit();
}

// Database connection
$host = 'localhost';
$dbname = 'worker_db';
$username = 'root';
$password = '';

try {
    $conn = new PDO("mysql:host=$host;dbname=$dbname", $username, $password);
    $conn->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    // First, get the current submission to confirm it exists
    $checkStmt = $conn->prepare("
        SELECT id, submission_text 
        FROM tbl_submissions 
        WHERE id = :submission_id
    ");
    
    $checkStmt->bindParam(':submission_id', $data['submission_id']);
    $checkStmt->execute();
    
    $currentSubmission = $checkStmt->fetch(PDO::FETCH_ASSOC);
    
    if (!$currentSubmission) {
        http_response_code(404);
        echo json_encode(['success' => false, 'message' => 'Submission not found']);
        exit();
    }
    
    // Update the submission
    $updateStmt = $conn->prepare("
        UPDATE tbl_submissions 
        SET submission_text = :submission_text,
            submitted_at = CURRENT_TIMESTAMP
        WHERE id = :submission_id
    ");
    
    $updateStmt->bindParam(':submission_id', $data['submission_id']);
    $updateStmt->bindParam(':submission_text', $data['submission_text']);
    $updateStmt->execute();
    
    if ($updateStmt->rowCount() > 0) {
        echo json_encode([
            'success' => true,
            'message' => 'Submission updated successfully',
            'old_text' => $currentSubmission['submission_text'],
            'new_text' => $data['submission_text']
        ]);
    } else {
        echo json_encode([
            'success' => false,
            'message' => 'No changes were made to the submission'
        ]);
    }
    
} catch(PDOException $e) {
    error_log("Database Error: " . $e->getMessage());
    
    http_response_code(500);
    echo json_encode([
        'success' => false,
        'message' => 'Database error occurred',
        'error_details' => $e->getMessage()
    ]);
}

$conn = null;
?> 