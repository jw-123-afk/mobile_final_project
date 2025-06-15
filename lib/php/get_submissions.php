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
if (!isset($data['worker_id']) || empty($data['worker_id'])) {
    http_response_code(400);
    echo json_encode(['success' => false, 'message' => 'Worker ID is required']);
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
    
    // Check if table exists
    $tableCheck = $conn->query("SHOW TABLES LIKE 'tbl_submissions'");
    $tableExists = $tableCheck->rowCount() > 0;
    
    if (!$tableExists) {
        // Create table if it doesn't exist
        $conn->exec("
            CREATE TABLE tbl_submissions (
                id INT AUTO_INCREMENT PRIMARY KEY,
                work_id INT NOT NULL,
                worker_id INT NOT NULL,
                submission_text TEXT NOT NULL,
                submitted_at DATETIME DEFAULT CURRENT_TIMESTAMP
            )
        ");
    }
    
    $worker_id = $data['worker_id'];
    
    // Get all submissions for this worker with task details
    $stmt = $conn->prepare("
        SELECT 
            s.id,
            s.work_id,
            s.worker_id,
            s.submission_text,
            s.submitted_at,
            w.title as task_title,
            w.description as task_description,
            w.status as task_status
        FROM tbl_submissions s
        LEFT JOIN tbl_works w ON s.work_id = w.id
        WHERE s.worker_id = :worker_id
        ORDER BY s.submitted_at DESC
    ");
    
    $stmt->bindParam(':worker_id', $worker_id);
    $stmt->execute();
    
    $submissions = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // Format the response
    $formattedSubmissions = array_map(function($submission) {
        return [
            'id' => $submission['id'],
            'work_id' => $submission['work_id'],
            'worker_id' => $submission['worker_id'],
            'submission_text' => $submission['submission_text'],
            'submitted_at' => $submission['submitted_at'],
            'task_title' => $submission['task_title'] ?? 'Unknown Task',
            'task_description' => $submission['task_description'] ?? 'No description available',
            'task_status' => $submission['task_status'] ?? 'Unknown'
        ];
    }, $submissions);
    
    echo json_encode([
        'success' => true,
        'submissions' => $formattedSubmissions
    ]);
    
} catch(PDOException $e) {
    // Log the error for debugging
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