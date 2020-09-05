#!/bin/bash
sudo -u postgres psql -U postgres -d wms_masterdata -c "select id from item where productattributes::text like '%$1%'"

