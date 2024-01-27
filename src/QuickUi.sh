#!/bin/bash

source ../bash-sdk/src/say.sh
source ../bash-sdk/src/file.sh
source ../bash-sdk/src/string.sh
source ../bash-sdk/src/os.sh
source ../bash-sdk/src/package.sh
source ../bash-sdk/src/repo.sh
source ../bash-sdk/src/ask.sh

QuickUiDir="${HOME}/.QuickUi";

os.is_userland &&
StyleDir="/host-rootfs/data/data/tech.ula/files/home/.termux";
os.is_termux &&
StyleDir="${HOME}/.termux";

banner(){
  echo "
╔═╗╔╦╗╦═╗╔═╗╔╗╔╔═╗╔═╗
╚═╗ ║ ╠╦╝╠═╣║║║║ ╦║╣ 
╚═╝ ╩ ╩╚═╩ ╩╝╚╝╚═╝╚═╝
  ";
  echo "Start coding with yourself.";
  echo "---------------------------";
}
banner;

execute_zsh_auto(){
  path.isdir "${HOME}/.zsh-autocomplete" &&
  repo.clone "marlonrichert/zsh-autocomplete ${HOME}/.zsh-autocomplete";
  { grep 'zsh-autocomplete.plugin.zsh' "${HOME}/.zshrc" &>/dev/null; } &&
  {
    say.warn "You have already zsh autocomplete.";
    return 1;
  };
  echo "source ${HOME}/.zsh-autocomplete/zsh-autocomplete.plugin.zsh" >> "${HOME}/.zshrc";
  echo;
  say.success "Successly installed zsh autocomplete.\n";
  say.warn "Please restart your Terminal.\n";
}

execute_zsh_syntax(){
  path.isdir "${HOME}/.zsh-syntax-highlighting" &&
  repo.clone "zsh-users/.zsh-syntax-highlighting ${HOME}/.zsh-syntax-highlighting";
  { grep 'zsh-syntax-highlighting.zsh' "${HOME}/.zshrc" &>/dev/null; } &&
  {
    say.warn "You have already zsh syntax highlighting.";
    return 1;
  };
  echo "source ${HOME}/.zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> "${HOME}/.zshrc";
  echo;
  say.success "Successly installed zsh syntax.\n";
  say.warn "Please restart your Terminal.\n";
}

execute_oh_zsh(){
  path.isdir "${HOME}/.oh-my-zsh" || {
    repo.clone "ohmyzsh/ohmyzsh ${HOME}/.oh-my-zsh";
    mv "${HOME}/.zshrc" "${HOME}/.zshrc.bak.$(date +%Y.%m.%d-%H:%M:%S)";
    cp "${HOME}/.oh-my-zsh/templates/zshrc.zsh-template" "${HOME}/.zshrc";
  };
  path.dirArray "${HOME}/.oh-my-zsh/themes" --no-extension;
  ask.choice 'Choose One' "${STRIP[@]}";
  sed -i '/^ZSH_THEME/d' "${HOME}/.zshrc";
  sed -i "1iZSH_THEME='${askChoice}'" "${HOME}/.zshrc";
  say.success "Please restart your Terminal.\n";
}

execute_zsh(){
  os.is_shell.zsh && {
    say.warn "You have already 'zsh' installed.";
    return 1;
  };
  pkg.install 'zsh';
  os.is_userland && {
    echo 'su' >> /home/user/.bashrc;
    echo '/bin/zsh' >> /root/.bashrc;
  };
  if os.is_termux; then
    chsh -s zsh;
  elif os.is_userland; then
    echo 'su' >> /home/user/.bashrc;
    echo '/bin/zsh' >> /root/.bashrc;
  else
    say.error "No function is available for your Os.\n";
    return 1;
  fi
  say.success "Please restart your Terminal.\n";
}
  
# colorsAndFonts(fonts~colors,font.ttf~colors.properties)
colorsAndFonts(){
  local ARGFolder="${1}";
  local ARGFile="${2}";
  path.dirArray "${QuickUiDir}/${ARGFolder}";
  ask.choice 'Choose One' "${STRIP[@]}";
  cp -rf "${QuickUiDir}/${ARGFolder}/${askChoice}" "${StyleDir}/${ARGFile}";
  if os.is_termux; then
    termux-reload-settings;
  elif os.is_userland; then
    echo && say.success "Please restart userland session.\n";
  else
    echo && say.error "No function is available for your Os.\n";
  fi
}

# setting up files and dirs.
path.isdir "${QuickUiDir}/fonts" || {
  os.is_func 'git' || pkg.install 'git';
  path.isdir "${QuickUiDir}" || mkdir -p "${QuickUiDir}";
  cd "${QuickUiDir}";
  path.isdir "${QuickUiDir}/.git" || git init &>/dev/null;
  git remote add origin https://github.com/OurCodeBase/QuickUi.git
  git config core.sparseCheckout true
  echo 'fonts/**' >> .git/info/sparse-checkout
  echo 'colors/**' >> .git/info/sparse-checkout
  git pull origin master &>/dev/null
};

# choice of user.
_ASK_CHOICE=(
  'Install Fonts'
  'Install Colors'
  'Install Zsh'
  'Install Oh-My-Zsh'
  'Install Zsh Syntax Highlighting'
  'Install Zsh Autocompletion'
  'Exit'
)

ask.choice 'Choose One' "${_ASK_CHOICE[@]}";
case "${askReply}" in
  1) colorsAndFonts 'fonts' 'font.ttf';;
  2) colorsAndFonts 'colors' 'colors.properties';;
  3) execute_zsh;;
  4) execute_oh_zsh;;
  5) execute_zsh_syntax;;
  6) execute_zsh_auto;;
  7) exit 1;;
esac
