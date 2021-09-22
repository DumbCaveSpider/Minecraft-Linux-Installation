set -e

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

output "What server do you want to setup? (Java)"

vanilla() {
  bash <(curl -s https://raw.githubusercontent.com/DumbCaveSpider/Minecraft-Linux-Installation/main/JavaInstallScripts/VanillaInstall)
}

paper() {
  bash <(curl -s https://raw.githubusercontent.com/DumbCaveSpider/Minecraft-Linux-Installation/main/JavaInstallScripts/PaperInstall)
}

fabric() {
  bash <(curl -s https://raw.githubusercontent.com/DumbCaveSpider/Minecraft-Linux-Installation/main/JavaInstallScripts/FabricInstall)
}

forge() {
  bash <(curl -s https://raw.githubusercontent.com/DumbCaveSpider/Minecraft-Linux-Installation/main/JavaInstallScripts/ForgeInstall)
}

sponge() {
  bash <(curl -s https://raw.githubusercontent.com/DumbCaveSpider/Minecraft-Linux-Installation/main/JavaInstallScripts/SpongeInstall)
}
while [ "$done" == false ]; do
  options=(
    "Vanilla"
    "PaperMC"
    "FabricMC"
    "Forge"
    "Sponge"
  )

  actions=(
    "vanilla"
    "paper"
    "fabric"
    "forge"
    "sponge"
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
