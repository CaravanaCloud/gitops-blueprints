DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
pushd $DIR

if [ ! -f ./aws-nuke ]; then
    echo "./aws-nuke not found, downloading..."
    NUKE_VERSION="aws-nuke-v2.15.0-linux-amd64"
    NUKE_URL="https://github.com/rebuy-de/aws-nuke/releases/download/v2.15.0/aws-nuke-v2.15.0-linux-amd64.tar.gz"
    curl -L -s -o aws-nuke.tar.gz $NUKE_URL
    tar zxvf aws-nuke.tar.gz
    mv "$NUKE_VERSION" "aws-nuke"
    rm -f "aws-nuke.tar.gz"
    echo "aws-nuke downloaded"
fi

./aws-nuke -c ./sample-nuke.yaml --no-dry-run --force  --force-sleep 3
popd
