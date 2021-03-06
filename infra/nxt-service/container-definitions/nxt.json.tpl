[
  {
    "name": "$${name}",
    "image": "$${image}",
    "memoryReservation": 384,
    "essential": true,
    "command": $${command},
    "portMappings": [
      {
        "containerPort": ${peer_server_port},
        "hostPort": ${peer_server_port}
      },
      {
        "containerPort": ${api_server_port},
        "hostPort": ${api_server_port}
      }
    ],
    "environment": [
      { "name": "AWS_REGION", "value": "$${region}" },
      { "name": "AWS_S3_CONFIGURATION_OBJECT", "value": "${aws_s3_configuration_object}" }
    ],
    "mountPoints": [
      {
        "sourceVolume": "nxt-data",
        "containerPath": "/opt/nxt/nxt_db"
      },
      {
        "sourceVolume": "nxt-certs",
        "containerPath": "/opt/nxt/nxt_certs"
      }
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
