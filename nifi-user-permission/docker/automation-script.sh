#!/bin/bash

update_nifi_user_policy() {
    # nifi communication
    /opt/nifi-toolkit/nifi-toolkit-1.15.0/bin/cli.sh session set nifi.props $1

    # parse user-permission.yaml file
    local userPolicyList=$(yq eval '.userPolicyList' $2 -o=json)
    local userPolicyListLength=$(cat $2 | yq e '.userPolicyList | length' -)
    
    # update user policy
    if [ $userPolicyListLength -gt 0 ]
    then
        local i=0
        local text_cmd=""

        while [ $i -lt $userPolicyListLength ]
        do
            local policy=$(echo $userPolicyList | jq --argjson e $i '.[$e]') 
            local resource=$(echo $policy | jq '.resource')
            local permission=$(echo $policy | jq '.permission')
            local userGroupNameList=$(echo $policy | jq -r '.userGroupNameList | join(",")')
            local userGroupIdList=$(echo $policy | jq -r '.userGroupIdList | join(",")')
            local userNameList=$(echo $policy | jq -r '.userNameList | join(",")')
            local userIdList=$(echo $policy | jq -r '.userIdList | join(",")')

            # echo "
            #     resource $resource
            #     permission $permission
            #     userGroupNameList $userGroupNameList
            #     userGroupIdList $userGroupIdList
            #     userNameList $userNameList
            #     userIdList $userIdList"

            text_cmd="${text_cmd}
            /opt/nifi-toolkit/nifi-toolkit-1.15.0/bin/cli.sh nifi update-policy -owp -poa $permission -por $resource $([ ! -z "$userGroupNameList" ] && echo -n "-gnl ${userGroupNameList}") $([ ! -z "$userGroupIdList" ] && echo -n "-gil ${userGroupIdList}") $([ ! -z "$userNameList" ] && echo -n "-unl ${userNameList}") $([ ! -z "$userIdList" ] && echo -n "-uil ${userIdList}") "

            echo "$text_cmd"
            
            i=$(($i + 1))
        done

        command $text_cmd        
    else
        return 0
    fi 
}

update_nifi_user_policy $1 $2