#!/usr/bin/env bash
#
# NAME
#
#   add-command
#
# DESCRIPTION
#
#   add command to module
#

# Source common function library
source $RERUN_MODULES/stubbs/lib/functions.sh || { echo "failed laoding function library" ; exit 1 ; }


# Init the handler
rerun_init 

TEMPLATE=$RERUN_MODULES/stubbs/templates/default.sh

# Get the options
while [ "$#" -gt 0 ]; do
    OPT="$1"
    case "$OPT" in
        # options without arguments
	# options with arguments
	-c|--command)
	    rerun_option_check "$#"
	    COMMAND="$2"
	    shift
	    ;;
	--description)
	    rerun_option_check "$#"
	    DESC="$2"
	    shift
	    ;;
	-m|--module)
	    rerun_option_check "$#"
	    MODULE="$2"
	    shift
	    ;;
	--overwrite)
	    rerun_option_check "$#"
	    OVERWRITE="$2"
	    shift
	    ;;
	-t|--template)
	    rerun_option_check "$#"
	    TEMPLATE="$2"
	    shift
	    ;;
        # unknown option
	-?)
	    rerun_option_error
	    ;;
	  # end of options, just arguments left
	*)
	    break
    esac
    shift
done

# Post processes the options
[ -z "$COMMAND" ] && {
    echo "Command: "
    read COMMAND
}

[ -z "$DESC" ] && {
    echo "Description: "
    read DESC
}

[ -z "$MODULE" ] && {
    echo "Module: "
    select MODULE in $(rerun_modules $RERUN_MODULES);
    do
	echo "You picked module $MODULE ($REPLY)"
	break
    done
}

[ ! -r "$TEMPLATE" ] && {
    rerun_die "TEMPLATE does not exist: $TEMPLATE"
}

# Create command structure
mkdir -p $RERUN_MODULES/$MODULE/commands/$COMMAND || rerun_die

# Generate a boiler plate implementation
[ ! -f $RERUN_MODULES/$MODULE/commands/$COMMAND/default.sh -o -n "$OVEWRITE" ] && {
    sed -e "s/@NAME@/$COMMAND/g" \
	-e "s/@MODULE@/$MODULE/g" \
	-e "s/@DESCRIPTION@/$DESC/g" \
	$TEMPLATE > $RERUN_MODULES/$MODULE/commands/$COMMAND/default.sh || rerun_die
    echo "Wrote command script: $RERUN_MODULES/$MODULE/commands/$COMMAND/default.sh"
}

# Generate a unit test script
mkdir -p $RERUN_MODULES/$MODULE/tests/commands/$COMMAND || rerun_die "failed creating tests directory"
[ ! -f $RERUN_MODULES/$MODULE/tests/$COMMAND/commands.sh -o -n "$OVEWRITE" ] && {
    sed -e "s/@NAME@/default/g" \
	-e "s/@MODULE@/$MODULE/g" \
	-e "s/@COMMAND@/$COMMAND/g" \
	-e "s;@RERUN@;${RERUN};g" \
	-e "s;@RERUN_MODULES@;${RERUN_MODULES};g" \
	$RERUN_MODULES/stubbs/templates/test.sh > $RERUN_MODULES/$MODULE/tests/commands/$COMMAND/default.sh || rerun_die
    echo "Wrote test script: $RERUN_MODULES/$MODULE/tests/commands/$COMMAND/default.sh"
}

# Generate command metadata
(
cat <<EOF
# generated by stubbs:add-command
# $(date)
NAME=$COMMAND
DESCRIPTION="$DESC"

EOF
) > $RERUN_MODULES/$MODULE/commands/$COMMAND/metadata || rerun_die

# Done
