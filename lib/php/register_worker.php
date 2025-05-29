<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

include_once './php/database.php';

$database = new Database();
$db = $database->getConnection();

$data = json_decode(file_get_contents("php://input"));

if (
    !empty($data->full_name) &&
    !empty($data->email) &&
    !empty($data->password) &&
    !empty($data->phone) &&
    !empty($data->address)
) {
    // Validate email format
    if (!filter_var($data->email, FILTER_VALIDATE_EMAIL)) {
        http_response_code(400);
        echo json_encode(array("message" => "Invalid email format."));
        exit();
    }

    // Validate password length
    if (strlen($data->password) < 6) {
        http_response_code(400);
        echo json_encode(array("message" => "Password must be at least 6 characters."));
        exit();
    }

    try {
        // Check if email already exists
        $check_query = "SELECT id FROM workers WHERE email = ?";
        $check_stmt = $db->prepare($check_query);
        $check_stmt->execute([$data->email]);

        if ($check_stmt->rowCount() > 0) {
            http_response_code(400);
            echo json_encode(array("message" => "Email already exists."));
            exit();
        }

        // Insert the new worker
        $query = "INSERT INTO workers SET full_name=:full_name, email=:email, password=:password, phone=:phone, address=:address";
        $stmt = $db->prepare($query);

        $stmt->bindParam(":full_name", $data->full_name);
        $stmt->bindParam(":email", $data->email);
        $stmt->bindParam(":phone", $data->phone);
        $stmt->bindParam(":address", $data->address);

        // Hash the password using SHA1
        $hashed_password = sha1($data->password);
        $stmt->bindParam(":password", $hashed_password);

        if ($stmt->execute()) {
            http_response_code(201);
            echo json_encode(array(
                "message" => "Worker registered successfully.",
                "id" => $db->lastInsertId()
            ));
        } else {
            http_response_code(503);
            echo json_encode(array("message" => "Unable to register worker."));
        }
    } catch (PDOException $e) {
        http_response_code(503);
        echo json_encode(array("message" => "Database error: " . $e->getMessage()));
    }
} else {
    http_response_code(400);
    echo json_encode(array("message" => "Unable to register worker. Data is incomplete."));
}
?>