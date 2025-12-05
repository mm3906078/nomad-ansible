<!DOCTYPE html>
<html>
<head>
    <title>Nomad Nginx Container</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 50px auto;
            padding: 20px;
            background-color: #f5f5f5;
        }
        .container {
            background-color: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        h1 {
            color: #333;
        }
        .info {
            background-color: #e7f3ff;
            padding: 15px;
            border-left: 4px solid #2196F3;
            margin: 20px 0;
        }
        .metadata {
            font-family: monospace;
            background-color: #f4f4f4;
            padding: 10px;
            border-radius: 4px;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 Nginx on Nomad</h1>
        <p>This Nginx server is running as a Docker container managed by Nomad.</p>

        <div class="info">
            <h3>Deployment Information:</h3>
            <div class="metadata">
                <p><strong>Allocation ID:</strong> {{ env "NOMAD_ALLOC_ID" }}</p>
                <p><strong>Job Name:</strong> {{ env "NOMAD_JOB_NAME" }}</p>
                <p><strong>Task Name:</strong> {{ env "NOMAD_TASK_NAME" }}</p>
                <p><strong>Datacenter:</strong> {{ env "NOMAD_DC" }}</p>
                <p><strong>Region:</strong> {{ env "NOMAD_REGION" }}</p>
                <p><strong>Node Name:</strong> {{ env "node.unique.name" }}</p>
            </div>
        </div>

        <h3>Features:</h3>
        <ul>
            <li>Docker container driver</li>
            <li>Dynamic port mapping</li>
            <li>Health checks via Consul</li>
            <li>Custom configuration templates</li>
            <li>Auto-restart on failure</li>
            <li>External template files</li>
        </ul>
    </div>
</body>
</html>
