#! /usr/bin/env bash

# catch most errors
set -eE
trap 'echo "[ERROR] Error occurred at $BASH_SOURCE:$LINENO command: $BASH_COMMAND"' ERR

function publish_main() {
  local src='asf-staging' dst='asf-site' r yn remotes=()
  for r in $(git remote); do
    remotes+=("$r ($(git config "remote.$r.url"))")
  done
  echo 'Select a remote:'
  select r in "${remotes[@]}"; do
    if [[ -n $r ]]; then
      r="${r%% *}"
      git remote update --prune "${r:?}"
      echo 'Updating would perform the following (if anything):'
      git push --dry-run "$r" "$r/$src:refs/heads/$dst"
      if [[ "$(git rev-parse "remotes/$r/$src")" == "$(git rev-parse "remotes/$r/$dst")" ]]; then
        return 0
      fi
      read -r -p "Are you sure you want to publish '$r/$src' to '$r/$dst'? " yn
      if [[ $yn =~ ^[yY]$|^[yY][eE][sS]$ ]]; then
        git push "$r" "$r/$src:refs/heads/$dst"
      else
        echo "You did not answer 'y' or 'yes', so no updates were made."
      fi
      return 0
    else
      echo 'ERROR - Invalid selection'
      return 1
    fi
  done
}

publish_main "$@" || exit 1
