#!/bin/bash
clearing_rollcage() {
    sleep 0.5
    echo "####################################################"
    echo "Clearing rollcage id $1"
    echo "####################################################"
    data=`sudo -u postgres psql -U postgres -d resources -c "select id,data,srids,state,owner_id from gresource where id in(select id from barcode where barcode ='$1')"`
    echo $data
    echo ""
    id=`sudo -u postgres psql -U postgres -d resources -c "select id from gresource where id in(select id from barcode where barcode ='$1')" | head -3 | tail -1 |  sed -r 's/([^0-9]*([0-9]*)){1}.*/\2/'`
    data_lpn_attached=`sudo -u postgres psql -U postgres -d resources -c "select data from gresource where id in(select id from barcode where barcode ='$1')" | head -3 | tail -1 |  sed -r 's/([^0-9]*([0-9]*)){1}.*/\2/'`
    srids_attached=`sudo -u postgres psql -U postgres -d resources -c "select srids from gresource where id in(select id from barcode where barcode ='$1')" | head -3 | tail -1 |  sed -r 's/([^0-9]*([0-9]*)){1}.*/\2'/`
    state=`sudo -u postgres psql -U postgres -d resources -c "select state from gresource where id in(select id from barcode where barcode ='$1')" | head -3 | tail -1 | tr -d ' '`
    owner_id=`sudo -u postgres psql -U postgres -d resources -c "select owner_id from gresource where id in(select id from barcode where barcode ='$1')" | head -3 | tail -1 |  sed -r 's/([^0-9]*([0-9]*)){1}.*/\2/'`
    
    if [ "$id" == 0 ]
    then
       echo "Wrong tote id"
    elif [ "$srids_attached" == 0 ] || [ ! -n "$srids_attached" ] 
    then
        echo "No Srid attached"
        if [ "$data_lpn_attached" == 0 ] || [ ! -n "$data_lpn_attached" ]
        then
        echo "No LPN Found"
        else
            echo "Srid not there but LPN Attached, clearing Data slot"
    #        sudo -u postgres psql -U postgres -d resources -c "update gresource set data = null where id ='$id'"
        fi
        if [ "$owner_id" == 0 ] || [ ! -n "$owner_id" ]
        then
            echo "No Owner id Found"
        else
            echo "Srid not there but Owner id is there clearing owner_id"
    #        sudo -u postgres psql -U postgres -d resources -c "update gresource set owner_id = null where id ='$id'"
        fi
        if [ "$state" == 'READY_FOR_REUSE' ]
        then
            echo "state is also good"
        else
            echo "State is not good, changing it to re-use"
    #        sudo -u postgres psql -U postgres -d resources -c "update gresource set state = 'READY_FOR_REUSE' where id ='$id'"
        fi
    else
        srid_state=`sudo -u postgres psql -U postgres -d platform_srms -c "select state from service_request where id = '$srids_attached'" | head -3 | tail -1 | tr -d ' '`
        srid_status=`sudo -u postgres psql -U postgres -d platform_srms -c "select status from service_request where id = '$srids_attached'" | head -3 | tail -1 | tr -d ' '`
        echo "State:"$srid_state
        echo "Status:"$srid_status
        echo ""
        if [ "$srid_state" == 'stage_requested' ] 
        then
            echo "state is stage_requested updating to CREATED "
    #        sudo -u postgres psql -U postgres -d platform_srms -c "update service_request set state='created',status='CREATED' where id = '$srids_attached'"
        fi
        if [ "$srid_state" == 'created' ] 
        then
            echo "State is already in created, checking owner_id, state and LPN attached"
            if [ "$owner_id" == 0 ] || [ ! -n "$owner_id" ]
            then
                echo "No Owner id Found, All are good"
            else
                echo "Srid is present but Owner id also exist,clearing owner id"
    #            sudo -u postgres psql -U postgres -d resources -c "update gresource set owner_id = null where id ='$id'"
            fi  
            if [ "$state" == 'IN_USE' ]
            then
                echo "Srid is present and STATE is in IN_USE, hence tote is good to go"
            else
                echo "State is not in IN_USE, something wrong, State is in:" $state
                echo "Contact GOR"
            fi
            if [ "$data_lpn_attached" == 0 ] || [ ! -n "$data_lpn_attached" ]
            then
            echo "No LPN Found, some issue is there. Contact GOR"
            else
                echo "Srid there and LPN is also attached, All are good"
            fi
        else
            echo "SRID is not in Created nor in stage_requested, please contact GOR"
        fi
    fi
    echo ""
    echo "id is:"$id
    echo "data is:"$data_lpn_attached
    echo "srids id:"$srids_attached
    echo "state is:"$state
    echo "owner id is:" $owner_id

}

first="sbs_$1"
second="sbs_$1_01"
third="sbs_$1_02"
four="sbs_$1_03"
echo $first
echo $second
echo $third
echo $four

clearing_rollcage $first
clearing_rollcage $second
clearing_rollcage $third
clearing_rollcage $four

