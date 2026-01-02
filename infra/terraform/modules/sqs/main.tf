resource "aws_sqs_queue" "this" {
  name = var.queue_name
  message_retention_seconds = 86400 # 1 day

}