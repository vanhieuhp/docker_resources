#!/bin/bash

# TOPICS=$(docker exec -it broker kafka-topics --bootstrap-server broker:9092 --list )

TOPICS="connect_configs connect_statuses connect_offsets"

for T in $TOPICS
do
  if [ "$T" != "__consumer_offsets" -a "$T" != "_confluent" ]; then
    echo "Deleting topic $T"
    docker exec -it broker kafka-topics --bootstrap-server broker:9092 --delete --topic $T
  fi
done

# cat <<EOF > delete_topics.sh
# #!/bin/bash

# TOPICS=$(kafka-topics --zookeeper --bootstrap-server broker:9092 --list )

# for T in $TOPICS
# do
#   if [ "$T" != "__consumer_offsets" ]; then
#     kafka-topics --zookeeper --bootstrap-server broker:9092 --delete --topic $T
#   fi
# done
# EOF

