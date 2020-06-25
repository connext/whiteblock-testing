# Whiteblock Test Definition

## Setup

### Prerequisites

Install the software required as described in the [Whiteblock Quickstart](https://docs.whiteblock.io/quick_start.html)

### Configure Env

If you plan on using `make`, make sure to insert your whiteblock username into your own `credentials.json`.

## Useful Commands

- With make (insert username into a `credentials.json`, as structured in `credentials_example.json`)

```bash
# RUN
make test

# LIST
make list

# STOP - do this to conserve credits!
make stop
```

- Without make

```bash
# RUN
genesis run test-definition.yaml <WHITEBLOCK_USERNAME>

# LIST
genesis ps

# STOP - do this to conserve credits!
genesis stop <TEST_ID>
```
