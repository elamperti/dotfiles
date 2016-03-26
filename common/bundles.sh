#!/bin/bash

# Hi there!
# To add or modify bundles go to the `bundles` folder.
# The `about-bundles.md` document may help you.

# pushd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null
# source 'progressbar/progressbar.sh'
# popd &> /dev/null

# Used to find selected bundles
declare -A bundle_ids
# Stores options for bundle picker
declare -a bundle_option_list
declare -a bundle_queue

create_bundle_list() {
    local main_script=
    local description=
    local friendly_name=
    pushd "$(dirname "${BASH_SOURCE[0]}")/../bundles/" &> /dev/null

    log NOTICE "Looking for bundles..."
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

                bundle_option_list+=("$friendly_name" "$description" on)

                log DEBUG "Bundle found: $bundle"
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
            log DEBUG "$bundle produced no output for $2()"
        fi
        rm .tmpcommands
    fi
    return $result
}

execute_bundle_after_installs() {
    if [ ${#bundle_queue[@]} -gt 0 ]; then
        log INFO "Installing bundles..."
        pushd "$(dirname "${BASH_SOURCE[0]}")/../bundles/" &> /dev/null
        for bundle in ${bundle_queue[@]}; do
            log DEBUG "Installing bundle $bundle"
            call_bundle_function $bundle after_installs EVAL_OUTPUT
            echo -ne "     " # Hacky indentation
            if [ $? -eq 0 ]; then
                pretty_print OK "${bundle_ids[$bundle]}"
            else
                pretty_print FAIL "${bundle_ids[$bundle]}"
            fi
        done
        popd &>/dev/null
    fi
}

execute_bundle_inits() {
    if [ ${#bundle_queue[@]} -gt 0 ]; then
        log INFO "Initializing bundles..."
        pushd "$(dirname "${BASH_SOURCE[0]}")/../bundles/" &> /dev/null
        for bundle in ${bundle_queue[@]}; do
            call_bundle_function $bundle on_init EVAL_OUTPUT
        done
        popd &>/dev/null
        pretty_print OK "Done (${#bundle_option_list[@]} bundles)"
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

    unset bundle_option_list
}

show_bundle_picker() {
    local dialog_description="Select the bundles to be executed. Each bundle may run several tasks."


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
            12 80 5 \
            ${bundle_option_list[@]} \
            2>&1 1>&5 \
        )
    fi
        exec 5>&-
        IFS=$oIFS

    # Translate fancy name back to a bundle folder name
    if [ ${#selected_bundles[@]} -gt 0 ]; then
        for bundle in ${selected_bundles[@]}; do
            bundle_queue+=($(get_bundle_by_name $bundle))
        done
    fi
}

