set -e

# Debug mode
set -x

# Script directory variable
SCRIPT_DIRECTORY=$(dirname $0)

ARTIFACTS_DIR=private-testnet

NETWORK_MAGIC="42"

HARD_FORK_BABBAGE_AT_EPOCH=0
HARD_FORK_CONWAY_AT_EPOCH=0
NUM_BFT_NODES="1"
NUM_POOL_NODES="2"
SLOT_LENGTH="0.75"
EPOCH_LENGTH="4"
LISTENING_ADDR="127.0.0.1"

# Display configuration summary
echo ">> Artifacts Directory[env::ARTIFACTS_DIR]: ${ARTIFACTS_DIR}"
echo ">> Cardano BFT nodes [env::NUM_BFT_NODES]: ${NUM_BFT_NODES}"
echo ">> Cardano SPO nodes [env::NUM_POOL_NODES]: ${NUM_POOL_NODES}"
echo ">> Cardano Network Magic [env::NETWORK_MAGIC]: ${NETWORK_MAGIC}"
echo ">> Cardano Hard Fork Babbage At Epoch [env::HARD_FORK_BABBAGE_AT_EPOCH]: ${HARD_FORK_BABBAGE_AT_EPOCH}"
echo ">> Cardano Hard Fork Conway At Epoch [env::HARD_FORK_CONWAY_AT_EPOCH]: ${HARD_FORK_CONWAY_AT_EPOCH}"
echo ">> Cardano Slot Length [env::SLOT_LENGTH]: ${SLOT_LENGTH}s"
echo ">> Cardano Epoch Length [env::EPOCH_LENGTH]: ${EPOCH_LENGTH}s"
echo ">> Cardano Listening Address [env::LISTENING_ADDR]: ${LISTENING_ADDR}"

# Check if root directory already exists
if ! mkdir -p "${ARTIFACTS_DIR}"; then
  echo "The ${ARTIFACTS_DIR} directory already exists, please move or remove it"
  exit
fi

# Switch to artifacts directory
# pushd ${ARTIFACTS_DIR} > /dev/null

# Switch to artifacts directory
old_dir=$PWD
cd ${ARTIFACTS_DIR}

# Create addresses sub-directory
mkdir addresses
