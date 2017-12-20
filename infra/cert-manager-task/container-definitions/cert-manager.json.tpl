[
  {
    "name": "${name}",
    "image": "${image}",
    "memoryReservation": 128,
    "essential": true,
    "command": ${command},
    "environment": [
      { "name": "AWS_REGION", "value": "${aws_region}" },
      { "name": "AWS_S3_CONFIGURATION_OBJECT", "value": "${aws_s3_configuration_object}" }
    ],
    "mountPoints": [
      {
        "sourceVolume": "nxt-certs",
        "containerPath": "/opt/cert-manager/certs"
      }
    ],
    "logConfiguration": {
      "logDriver": "awslogs",
      "options": {
        "awslogs-group": "${log_group}",
        "awslogs-region": "${aws_region}"
      }
    }
  }
]
