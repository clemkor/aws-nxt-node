[
  {
    "name": "$${name}",
    "image": "$${image}",
    "memoryReservation": 256,
    "essential": true,
    "command": $${command},
    "portMappings": [
      {
        "containerPort": ${peer_server_port},
        "hostPort": ${peer_server_port}
      },
      {
        "containerPort": ${api_server_port},
        "hostPort": ${api_server_http_port}
      },
      {
        "containerPort": ${ui_server_port},
        "hostPort": ${ui_server_port}
      }
    ],
    "environment": [
      { "name": "AWS_REGION", "value": "$${region}" },
      { "name": "SECRETS_BUCKET_NAME", "value": "${secrets_bucket_name}" }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "$${log_group}",
        "awslogs-region": "$${region}"
      }
    }
  }
]
