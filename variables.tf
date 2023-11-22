variable "name" {
  type        = string
  description = "the name of the topic/subscription"
}

variable "name_subscription" {
  type        = string
  description = "the name of the subscription (specified only for backwards compatibility to imported resources)"

  default = ""
}

variable "extra_subscriptions" {
  type        = list(any)
  description = "the other subscriptions (map containing name and settings, NO ROLES)"

  default = []
}

variable "project" {
  type        = string
  description = "the project in GCP"
}

variable "topic_only" {
  type        = bool
  description = "whether we only want a topic or also a subscription"

  default = false
}

variable "roles_topic" {
  type        = map(any)
  description = "the roles of the SA for the topic: specify 'roleName: [account1, account2]'"

  default = {}
}

variable "roles_subscription" {
  type        = map(any)
  description = "the roles of the SA for the subscription: specify 'roleName: [account1, account2]'"

  default = {}
}

variable "labels" {
  type        = map(any)
  description = "the labels of the pubsub topic/subscription"

  default = {}
}

variable "ttl" {
  type        = string
  description = "the ttl (contains an array with ONE string. If null, google sets 2678400s; if present BUT empty, google sets to never expire)"

  default = "2678400s"
}

variable "push" {
  type        = string
  description = "the push_config (contains an array with ONE string, or empty)"

  default = ""
}

variable "message_retention_duration" {
  type        = string
  description = "message_retention_duration"

  default = "604800s"
}

variable "ack_deadline_seconds" {
  type        = string
  description = "ack_deadline_seconds"

  default = "600"
}

variable "retain_acked_messages" {
  type        = bool
  description = "retain_acked_messages"

  default = true
}

variable "dead_letter" {
  type        = map(any)
  description = "dead letter policy"

  default = {}
}

variable "retry_policy" {
  type = object({
    minimum_backoff = string
    maximum_backoff = string
  })
  description = "(Optional) A policy that specifies how Pub/Sub retries message delivery for this subscription."

  default = null
}
