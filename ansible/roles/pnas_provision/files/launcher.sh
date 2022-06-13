#!/bin/bash

COMPOSE_HTTP_TIMEOUT=500 tmux new-session -d -s "PNAS" docker-compose up

cat << EOF
 __  __ __  __       ____  _   _    _    ____  
|  \/  |  \/  |     |  _ \| \ | |  / \  / ___| 
| |\/| | |\/| |_____| |_) |  \| | / _ \ \___ \ 
| |  | | |  | |_____|  __/| |\  |/ ___ \ ___) |
|_|  |_|_|  |_|     |_|   |_| \_/_/   \_\____/ 
Created a tmux session for MM-PNAS container services to run in.

You can see their status by attaching to the session:
    tmux attach-session -t "PNAS"  # NOTE 'tmux attach' will work if it's the only session

Once inside the session, you can detach from it with:
    C-b d                          # NOTE 'C' means 'CTRL'

You can take down the services with:
    docker-compose down
EOF
