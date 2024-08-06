CREATE TABLE load_balancer_requests (
    type            varchar(24) NOT NULL,
    "time"          timestamptz NOT NULL,
    http_status     varchar(4) NOT NULL,
    backend_ip      varchar(40) NULL,
    request_time    numeric NULL
);
