# name: Integral
# fork by: Froloket

# Colors
set blue (set_color blue)
set yellow (set_color yellow)
set normal (set_color normal)
set green (set_color green)
set dark_gray (set_color 222)

# Overwrite mode prompt as we use another approach
function fish_mode_prompt
end

function _git_branch_name
  echo (command git symbolic-ref HEAD 2> /dev/null | sed -e 's|^refs/heads/||')
end

function _upstream_count
  echo (command git rev-list --count --left-right origin/(_git_branch_name)...HEAD 2> /dev/null)
end

function _git_up_info
  if [ (_upstream_count) ]
    set -l count (_upstream_count)

    switch $count
      case "" # no upstream
        echo ''
      case "0?0" # equal to upstream
        echo ''
      case "0??" # ahead of upstream
        echo 'u+'(echo $count | cut -f2)
      case "??0" # behind upstream
        echo 'u-'(echo $count | cut -f1)
      case '???'      # diverged from upstream
        echo $count 'u+'(echo $count | cut -f2)'-'(echo $count | cut -f1)
      case '*'
        echo ''
    end
  end
end

function _is_git_dirty
  echo (command git status -s --ignore-submodules=dirty 2> /dev/null)
end

function fish_prompt
  set -l arrow "∫"
  set -l cwd $blue(prompt_pwd) $normal

  if [ (_git_branch_name) ]
    set -l git_branch (_git_branch_name)
    set -l git_vs_upstream (_git_up_info)

    if [ (_is_git_dirty) ]
      set git_info $yellow'('$git_branch "±" "$git_vs_upstream"')' $normal
    else if [ (_git_up_info) ]
      set git_info $yellow'('$git_branch "$git_vs_upstream"')' $normal
    else
      set git_info $green'('$git_branch')' $normal
    end
  end

  # Set $arrow color depending on mode (when in vi mode)
  if test "$fish_key_bindings" = fish_vi_key_bindings
    or test "$fish_key_bindings" = fish_hybrid_key_bindings
    switch $fish_bind_mode
      case default
        set arrow_color (set_color brblack)
      case insert
        set arrow_color (set_color brwhite)
      case replace_one
        set arrow_color (set_color green)
      case replace
        set arrow_color (set_color yellow)
      case visual
        set arrow_color (set_color magenta)
    end
  else
    set arrow_color $normal
  end

  echo -n -s ' ' $cwd ' ' "$git_info" $arrow_color $arrow $normal ' '
end

function fish_right_prompt
  echo -n -s $dark_gray ' ['(date +%H:%M:%S)'] ' $normal
end
