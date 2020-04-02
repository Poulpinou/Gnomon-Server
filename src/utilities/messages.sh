#!/bin/sh

# Displays an info message
# - $1 : the message to display
logInfo(){
        echo -e "${s_info}$1${s_normal}"
}

# Displays a success message
# - $1 : the message to display
logSuccess(){ 
        echo -e "${s_success}$1${s_normal}"
}

# Displays an error message
# - $1 : the message to display
logError(){ 
        echo -e "${s_error}☠ Error : $1 ☠ ${s_normal}"
        # Todo : Log into file
}

# Displays a warning message
# - $1 : the message to display
logWarning(){
        echo -e "${s_warning}⚠ Warning : $1 ⚠ ${s_normal}"
}

# Exits the script and echoes custom error if there is an error
# - $1 : the exit code
# - $2 : the error message
exitIfError() {
  local exit_code=$1
  shift
  [[ $exit_code ]] &&               # do nothing if no error code passed
    ((exit_code != 0)) && {         # do nothing if error code is 0
      logError "$@"
      exit "$exit_code"
    }
}