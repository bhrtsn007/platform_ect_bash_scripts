#!/bin/bash
sudo -u postgres psql -U postgres -d platform_srms -c "select id,state,status from service_request where external_service_request_id = '$1'"
