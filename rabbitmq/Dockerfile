# FROM rabbitmq:3.8.5-management

FROM rabbitmq:3.12.12-management-alpine

RUN apk update && apk add curl

COPY rabbitmq_delayed_message_exchange-3.12.0.ez .$RABBITMQ_HOME/plugins/rabbitmq_delayed_message_exchange-3.12.0.ez

RUN rabbitmq-plugins enable rabbitmq_top rabbitmq_shovel rabbitmq_consistent_hash_exchange rabbitmq_delayed_message_exchange rabbitmq_management rabbitmq_web_dispatch rabbitmq_stomp rabbitmq_web_stomp rabbitmq_prometheus