#!/bin/bash

mongosh <<EOF
var config = {
    "_id": "dbrs",
    "version": 1,
    "members": [
        {
            "_id": 1,
            "host": "127.0.0.1:27017",
            "priority": 3
        }
    ]
};
rs.initiate(config, { force: true });
rs.status();
EOF
