# Set OIDCD_PID & OIDC_SOCK if env file exists,
# otherwise start oidc-agent
if [ -f /tmp/oidc-agent-$USER.env ]; then
    # check if the oidc-agent is actually running
    kill -s 0 $(cat /tmp/oidc-agent-$USER.env | grep 'PID=' | cut -d '=' -f 2 | cut -d ';' -f 1) 2>/dev/null 
    # if running apply env
    if [[ $? -eq 0 ]]; then
        source /tmp/oidc-agent-$USER.env
    else
        oidc-agent > /tmp/oidc-agent-$USER.env
        source /tmp/oidc-agent-$USER.env
    fi
else
    oidc-agent > /tmp/oidc-agent-$USER.env
    source /tmp/oidc-agent-$USER.env
fi
