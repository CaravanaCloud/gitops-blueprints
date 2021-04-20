DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
pushd $DIR
./aws-nuke -c ./sample-nuke.yaml --profile sandbox --no-dry-run --force
popd
