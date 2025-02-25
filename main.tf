locals {
  push_list = var.push != "" ? [var.push] : []

  dead_letter_list = length(var.dead_letter) != 0 ? [var.dead_letter] : []

  all_subscriptions = concat(
    [
      {
        "name"                       = coalesce(var.name_subscription, var.name)
        "roles"                      = var.roles_subscription
        "message_retention_duration" = var.message_retention_duration
        "ack_deadline_seconds"       = var.ack_deadline_seconds
        "retain_acked_messages"      = var.retain_acked_messages
        "ttl_list"                   = [var.ttl]
        "push_list"                  = var.push != "" ? [var.push] : []
        "dead_letter_list"           = length(var.dead_letter) != 0 ? [var.dead_letter] : []
      }
    ],
    var.extra_subscriptions
  )
}


resource "google_pubsub_topic" "topic" {
  project = var.project

  name = var.name

  labels = var.labels
}

resource "google_pubsub_subscription" "subscription" {
  count = var.topic_only ? "0" : length(local.all_subscriptions)

  project = var.project

  name = local.all_subscriptions[count.index].name

  topic = google_pubsub_topic.topic.name

  message_retention_duration = try(local.all_subscriptions[count.index].message_retention_duration, var.message_retention_duration)
  ack_deadline_seconds       = try(local.all_subscriptions[count.index].ack_deadline_seconds, var.ack_deadline_seconds)
  retain_acked_messages      = try(local.all_subscriptions[count.index].retain_acked_messages, var.retain_acked_messages)

  dynamic "expiration_policy" {
    for_each = try(local.all_subscriptions[count.index].ttl_list, [var.ttl])

    content {
      ttl = expiration_policy.value
    }
  }

  dynamic "retry_policy" {
    for_each = var.retry_policy != null ? [1] : []

    content {
      minimum_backoff = var.retry_policy.minimum_backoff
      maximum_backoff = var.retry_policy.maximum_backoff
    }
  }

  dynamic "push_config" {
    for_each = try(local.all_subscriptions[count.index].push_list, local.push_list)

    content {
      push_endpoint = push_config.value

      dynamic "oidc_token" {
        for_each = compact([try(local.all_subscriptions[count.index].oidc_token_service_account_email, null)])

        content {
          service_account_email = oidc_token.value
        }
      }
    }
  }

  dynamic "dead_letter_policy" {
    for_each = [for s in try(local.all_subscriptions[count.index].dead_letter_list, local.dead_letter_list) : {
      dead_letter_topic     = s.dead_letter_topic
      max_delivery_attempts = s.max_delivery_attempts
    }]

    content {
      dead_letter_topic     = dead_letter_policy.value.dead_letter_topic
      max_delivery_attempts = dead_letter_policy.value.max_delivery_attempts
    }
  }

  labels = var.labels
}

resource "google_pubsub_topic_iam_binding" "pubsub_topic_role" {
  count = length(keys(var.roles_topic))

  topic = google_pubsub_topic.topic.id

  role = "roles/pubsub.${element(keys(var.roles_topic), count.index)}"

  members = formatlist("serviceAccount:%s", lookup(var.roles_topic, element(keys(var.roles_topic), count.index)))
}

resource "google_pubsub_subscription_iam_binding" "pubsub_subscription_role" {
  count = length(keys(var.roles_subscription))

  subscription = google_pubsub_subscription.subscription[0].id

  role = "roles/pubsub.${element(keys(var.roles_subscription), count.index)}"

  members = formatlist("serviceAccount:%s", lookup(var.roles_subscription, element(keys(var.roles_subscription), count.index)))
}
