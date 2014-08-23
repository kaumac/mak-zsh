function battery_pct() {
  local smart_battery_status="$(ioreg -rc "AppleSmartBattery")"
  typeset -F maxcapacity=$(echo $smart_battery_status | grep '^.*"MaxCapacity"\ =\ ' | sed -e 's/^.*"MaxCapacity"\ =\ //')
  typeset -F currentcapacity=$(echo $smart_battery_status | grep '^.*"CurrentCapacity"\ =\ ' | sed -e 's/^.*CurrentCapacity"\ =\ //')
  integer i=$(((currentcapacity/maxcapacity) * 100))
  echo $i
}

function plugged_in {
  [ $(ioreg -rc AppleSmartBattery | grep -c '^.*"ExternalConnected"\ =\ Yes') -eq 1 ]
}

function battery_pct_remaining() {
  if plugged_in ; then
    echo "⚡️"
  else
    battery_pct
  fi
}

# A purely .zsh method inspired by Steve Losh's Python script for displaying battery power with zsh:
# http://stevelosh.com/blog/2010/02/my-extravagant-zsh-prompt/#my-right-prompt-battery-capacity
#
# For best results assign to RPROMPT
function battery_charge {
  # Adjust to your preferred number of segments
  typeset -i SEGMENTS
  SEGMENTS=10

  # Get maximum and current capacity as floats via ioreg
  results="$(ioreg -rc AppleSmartBattery)"
  typeset -F max_capacity
  typeset -F current_capacity
  max_capacity="$(echo $results | grep 'MaxCapacity' | awk '{print $3}')"
  current_capacity="$(echo $results | grep 'CurrentCapacity' | awk '{print $3}')"

  # Calculate the number of green, yellow and red segments
  segments_left=$(( $current_capacity / $max_capacity * $SEGMENTS ))
  typeset -i green_segments
  typeset -i yellow_segments
  typeset -i red_segments
  green_segments=$segments_left
  yellow_segments=$(( $segments_left - $green_segments > 0.5 ))
  red_segments=$(( $SEGMENTS - $green_segments - $yellow_segments ))

  # Display everything
  echo -n "%{$fg[green]%}"
  repeat $green_segments echo -n "•"
  echo -n "%{$fg[yellow]%}"
  repeat $yellow_segments echo -n "•"
  echo -n "%{$fg[red]%}"
  repeat $red_segments echo -n "•"
  echo -n "%{$reset_color%}"
}



# Add the branch name and the working tree status information
git_prompt_info () {
  ref=$(git symbolic-ref HEAD 2> /dev/null) || return
  echo "$ZSH_THEME_GIT_PROMPT_PREFIX${ref#refs/heads/}$(parse_git_dirty)$(git_prompt_status)$(git_stash_info)$(git_upstream_info)$ZSH_THEME_GIT_PROMPT_SUFFIX"
}

# show the differences between HEAD and its upstream
git_upstream_info() {
  # find how many commits we are ahead/behind our upstream
  COUNT=$(git rev-list --count --left-right @{upstream}...HEAD 2> /dev/null)
  STATUS=""
  case "$COUNT" in
    "") # no upstream
      STATUS="" ;;
    "0	0") # equal to upstream
      STATUS="$ZSH_THEME_GIT_PROMPT_UPSTREAM_EQUAL" ;;
    "0	"*) # ahead of upstream
      STATUS="$ZSH_THEME_GIT_PROMPT_UPSTREAM_AHEAD" ;;
    *"	0") # behind upstream
      STATUS="$ZSH_THEME_GIT_PROMPT_UPSTREAM_BEHIND" ;;
    *) # diverged from upstream
      STATUS="$ZSH_THEME_GIT_PROMPT_UPSTREAM_DIVERGED" ;;
  esac
  echo $STATUS
}
#
# show stash info
git_stash_info() {
  STATUS=""
  git rev-parse --verify refs/stash >/dev/null 2>&1 && STATUS="$ZSH_THEME_GIT_PROMPT_STASHED"
  echo $STATUS
}

# Copied from fletcherm's theme. modified the git prompt info
PROMPT='%{$fg_no_bold[magenta]%}🚀  %{$fg_no_bold[green]%}%3~$(git_prompt_info)%{$reset_color%} %{$fg_no_bold[gray]%} '
RPROMPT='🔋 $(battery_pct_remaining) adjoifsfiosafijo $(battery_charge) %{$fg_no_bold[cyan]%} 🕑  %*%{$reset_color%}'

# git theming
ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}(%{$fg_no_bold[yellow]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$fg_bold[blue]%})"
ZSH_THEME_GIT_PROMPT_CLEAN=""
ZSH_THEME_GIT_PROMPT_DIRTY=""
ZSH_THEME_GIT_PROMPT_STASHED="%{$fg_bold[cyan]%}•"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg_bold[red]%}•"
ZSH_THEME_GIT_PROMPT_MODIFIED="%{$fg_bold[yellow]%}•"
ZSH_THEME_GIT_PROMPT_ADDED="%{$fg_bold[green]%}•"
ZSH_THEME_GIT_PROMPT_UPSTREAM_EQUAL=""
ZSH_THEME_GIT_PROMPT_UPSTREAM_AHEAD="%{$fg_bold[cyan]%}»"
ZSH_THEME_GIT_PROMPT_UPSTREAM_BEHIND="%{$fg_bold[cyan]%}«"
ZSH_THEME_GIT_PROMPT_UPSTREAM_DIVERGED="%{$fg_bold[cyan]%}«»"

export LSCOLORS="exfxcxdxbxegedabagacad"
