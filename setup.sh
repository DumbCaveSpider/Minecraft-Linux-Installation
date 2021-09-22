SCRIPT_VERSION="v1.0"

# exit with error status code if user is not root
if [[ $EUID -ne 0 ]]; then
  echo "* User MUST be under a root user. (sudo -s)." 1>&2
  exit 1
fi

# check for curl
if ! [ -x "$(command -v curl)" ]; then
  echo "* curl is required in order for this script to work."
  echo "* install using apt (Debian and derivatives) or yum/dnf (CentOS)"
  exit 1
fi

output() {
  echo -e "* ${1}"
}

error() {
  COLOR_RED='\033[0;31m'
  COLOR_NC='\033[0m'

  echo ""
  echo -e "* ${COLOR_RED}ERROR${COLOR_NC}: $1"
  echo ""
}

done=false

output "Minecraft Instalation Script | $SCRIPT_VERSION"
output
output "Support Server"
output "https://discord.arcticwoof.ga"
output
output "This script is ONLY used for owned Virtual Machine! NOT SHELL MACHINE!"

output

vanilla() {
  bash <(curl -s https://raw.githubusercontent.com/DumbCaveSpider/Minecraft-Linux-Installation/main/JavaInstallScripts/VanillaInstall)
}

paper() {
  bash <(curl -s https://raw.githubusercontent.com/DumbCaveSpider/Minecraft-Linux-Installation/main/JavaInstallScripts/VanillaInstall)
}

while [ "$done" == false ]; do
  options=(
    "Java"
    "Bedrock"
  )

  actions=(
    "vanilla"
    "paper"
  )

  output "Numeber:"

  for i in "${!options[@]}"; do
    output "[$i] ${options[$i]}"
  done

  echo -n "* Input 0-$((${#actions[@]} - 1)): "
  read -r action

  [ -z "$action" ] && error "Input is required" && continue
  
  valid_input=("$(for ((i = 0; i <= ${#actions[@]} - 1; i += 1)); do echo "${i}"; done)")
  [[ ! " ${valid_input[*]} " =~ ${action} ]] && error "Invalid option"
  [[ " ${valid_input[*]} " =~ ${action} ]] && done=true && eval "${actions[$action]}"
done
