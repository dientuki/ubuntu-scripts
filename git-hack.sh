# taked from http://github.com/mikewest/homedir/blob/master/etc/bash/rc/git
function git_status_prompt {
    git rev-parse --git-dir &> /dev/null
    [ $? -ne 0 ] && return
    git_status="$(git status 2> /dev/null)"
    branch_pattern="^On branch ([^${IFS}]*)"
    if [[ ! ${git_status} =~ "working tree clean" ]]; then
        state="⚡"
    fi
    if [[ ${git_status} =~ "Your branch is (.*) of" ]]; then
        if [[ ${BASH_REMATCH[1]} == "ahead" ]]; then
            remote="↑"
        else
            remote="↓"
        fi
    fi
    if [[ ${git_status} =~ "Unmerged paths:" ]]; then
      remote="[conflict]"
    fi
    if [[ ${git_status} =~ "Your branch and (.*) have diverged" ]]; then
        remote="↕"
    fi
    if [[ ${git_status} =~ ${branch_pattern} ]]; then
        branch="(${BASH_REMATCH[1]})"
        # [ "$branch" = "(master)>" ] && branch=''
        echo "${branch}${remote}${state}>"
    else
        if [[ ${git_status} =~ "Not currently on any branch." ]]; then
          echo "(no branch) ${remote}${state}>"
        fi
    fi
}
GIT_STATUS='$(git_status_prompt)'

function prompt_command_function() {

	reset='\['`tput sgr0`'\]'
	yellow='\['`tput sgr0; tput setaf 3`'\]'
	yellow='\[\e[0;33m\]' #yellow regular
	green='\[\e[1;32m\]' #green bold
	blue='\[\e[1;34m\]' #blue regular

	PS1="${green}\h${reset}:${blue}$(pwd)>${yellow}${GIT_STATUS}${reset}"
}

PROMPT_COMMAND=prompt_command_function
