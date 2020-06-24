
SHELL=/bin/bash # shell make will use to execute commands

########################################
# Run shell commands to fetch info from environment

dir=$(shell cd "$(shell dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )
cwd=$(shell pwd)
commit=$(shell git rev-parse HEAD | head -c 8)

username=$(shell cat $(dir)/credentials.json | grep '"username":' | head -n 1 | cut -d '"' -f 4)

id=$(shell genesis ps)

########################################
# Build Shortcuts

default: test

########################################
# Command & Control Shortcuts

test:
	genesis run test-definition.yaml $(username)

list: 
	genesis ps

stop: 
	genesis stop $(id)