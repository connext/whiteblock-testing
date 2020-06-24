# Whiteblock Test Definition

## Setup

- https://docs.whiteblock.io/quick_start.html

## Useful Commands

- Without make

```bash
# RUN
genesis run test-definition.yaml <WHITEBLOCK_USERNAME>

# LIST
genesis ps

# STOP - do this to conserve credits!
genesis stop <TEST_ID>
```

- With make (insert username into a `credentials.json`, as structured in `credentials_example.json`)

```bash
# RUN
make test

# LIST
make list

# STOP - do this to conserve credits!
make stop
```
