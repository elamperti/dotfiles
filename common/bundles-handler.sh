#!/bin/bash

# Hi there!
# To add or modify bundles go to the `bundles` folder.
# The `about-bundles.md` document may help you.

# Used to find selected bundles
declare -A bundle_ids
# Stores options for bundle picker
declare -a bundle_option_list
declare -a bundle_queue

bundle_count=0

bundle_exists() {
    pushd "$(dirname "${BASH_SOURCE[0]}")/../bundles/" &> /dev/null
    [ -f "$1/$1.sh" ]
    local ret=$?
    popd &>/dev/null
    return $ret
}

create_bundle_list() {
    local main_script=
    local description=
    local friendly_name=
    pushd "$(dirname "${BASH_SOURCE[0]}")/../bundles/" &> /dev/null

    log INFO "Looking for bundles..."
    for bundle in $(ls -d */); do
        bundle=${bundle::-1} # remove trailing slash

        log DEBUG "Bundle folder: $bundle"

        main_script="${bundle}/${bundle}.sh"
        if [ -f "$main_script" ]; then
            call_bundle_function "${bundle}" "verify_requirements"
            if [ $? -eq 0 ]; then
                friendly_name="$(. $main_script get_name 2>/dev/null)"
                description="$(. $main_script get_desc 2>/dev/null)"

                bundle_ids[$bundle]="$friendly_name"

                bundle_option_list+=("$friendly_name" "$description" "off")

                log DEBUG "Bundle found: $bundle"
                ((bundle_count++))
            else
                log WARN "Bundle requirements didn't pass ($bundle)"
            fi
        fi
    done
    popd &>/dev/null
}

# Params: bundle function_name [EVAL_OUTPUT]
call_bundle_function() {
    # Call the bundle function
    pushd $1 &>/dev/null
    bash ${1}.sh $2
    local result=$?
    popd &>/dev/null

    if [ -f .tmpcommands ]; then
        if [[ $3 == "EVAL_OUTPUT" ]]; then
            eval $(cat .tmpcommands)
        else
            log DEBUG "$bundle produced no output for ${2}()"
        fi
        rm .tmpcommands
    fi
    return $result
}

enqueue_bundle() {
    bundle_queue+=($1)
    log DEBUG "Added bundle $1 to the queue"
}

execute_bundle_after_installs() {
    local bundle_name=""
    if [ ${#bundle_queue[@]} -gt 0 ]; then
        log INFO "Installing bundles..."
        pretty_print INDENT RIGHT 6
        pushd "$(dirname "${BASH_SOURCE[0]}")/../bundles/" &> /dev/null
        for bundle in ${bundle_queue[@]}; do
            log DEBUG "Installing bundle $bundle"

            bundle_name="${bundle_ids[$bundle]:-$bundle}"
            pretty_print TITLE "${bundle_name}"

            # pretty_print INDENT RIGHT 1
            call_bundle_function $bundle after_installs EVAL_OUTPUT
            local ret=$?

            if [ $ret -eq 0 ]; then
                pretty_print OK "ok!"
            else
                pretty_print FAIL "FAILED"
            fi
            # pretty_print INDENT LEFT 1
            echo
        done
        popd &>/dev/null
        pretty_print INDENT LEFT 6
    fi
}

execute_bundle_inits() {
    if [ ${#bundle_queue[@]} -gt 0 ]; then
        log INFO "Searching for bundles..."
        pushd "$(dirname "${BASH_SOURCE[0]}")/../bundles/" &> /dev/null
        for bundle in ${bundle_queue[@]}; do
            call_bundle_function $bundle on_init EVAL_OUTPUT
        done
        popd &>/dev/null
        pretty_print OK "Done (${bundle_count} bundles found)"
    fi
}

# ToDo: optimize this.
get_bundle_by_name() {
    for id in ${!bundle_ids[@]}; do
        if [[ "${bundle_ids[$id]}" == "$1" ]]; then
            echo $id
        fi
    done
}

pick_bundles() {
    create_bundle_list

    if [ ${#bundle_option_list[@]} -gt 0 ]; then
        show_bundle_picker
    else
        log WARN "No bundles found."
    fi
}

show_bundle_picker() {
    local dialog_description="Select the bundles to be executed. Each bundle may run several tasks."
    local bundle_list_height=12

    # This is so the $bundle_option_list separates were it should
    oIFS=$IFS
    IFS=$'\n'

    # Display dialog if there are bundles
    if [ ${#bundle_option_list[@]} -gt 0 ]; then
        # fd 5 because I liked that one. It could be just 3.
        exec 5>&1;
        selected_bundles=$(dialog --keep-tite \
            --title "Pick your bundles" \
            --checklist "$dialog_description" \
            $(( 7 + $bundle_list_height )) 80 $bundle_list_height \
            ${bundle_option_list[@]} \
            2>&1 1>&5 \
        )
    fi
    exec 5>&-

    # Translate fancy name back to a bundle folder name
    IFS=" "
    if [ -n "${selected_bundles[@]}" ]; then
        for bundle in ${selected_bundles[@]}; do
            enqueue_bundle $(get_bundle_by_name $bundle)
        done
    else
        log INFO "No bundle will be installed."
    fi
    IFS=$oIFS
}
