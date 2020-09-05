#!/bin/bash
sudo -u postgres psql -U postgres -d platform_srms -c "update service_request set state= 'cancelled', status='CANCELLED' where external_service_request_id = '$1'"
