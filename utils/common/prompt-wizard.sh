#!/bin/bash

prompt_wizard() {
    local generator_args=""
    local templates=()
    local styles=()

    pushd "$(dirname "${BASH_SOURCE[0]}")/../../art/prompt/templates/" &> /dev/null

    # To avoid filling a description for each template item, here's a unicode space v
    templates=($(ls -d */|sed 's#/##'|awk '{a[$1]=$1}END{for(i in a)printf " "a[i]"   on "}'))

    # Show dialog only if more than one template
    if [ ${#templates[@]} -gt 3 ]; then
        exec 3>&1;
        local selected_template=$(dialog --keep-tite --title "Templates" \
            --radiolist "Pick a Bash prompt template" 16 32 10\
            ${templates[@]} \
            2>&1 1>&3 \
        )
        exec 3>&-

        # Throw error if none selected
        [ -z "${selected_template}" ] && return 1
    else
        # Use the only template available
        selected_template=$(ls -d */|sed 's#/##')
    fi
    generator_args="${generator_args} --template=${selected_template}"

    # Get into the template folder
    if [ -d ${selected_template}/styles/ ]; then
        pushd "${selected_template}/styles/" &> /dev/null

        # To avoid filling a description for each style item, I used a unicode space here v too
        styles=($(ls *.json|sed 's#.json##'|awk '{a[$1]=$1}END{for(i in a)printf " "a[i]"   on "}'))

        # Take a moment to appreciate how I nailed the unicode space position in those two comments

        # Show dialog only if more than one style
        if [ ${#styles[@]} -gt 3 ]; then
            exec 3>&1;
            selected_style=$(dialog --keep-tite --title "Template style" \
                --radiolist "Pick a style from this template's options" 16 40 10\
                ${styles[@]} \
                2>&1 1>&3 \
            )
            exec 3>&-

            # Throw error if none selected
            [ -z "${selected_style}" ] && return 1
        else
            # Use the only style available
            selected_template=$(ls *.json|sed 's#.json##')
        fi
        generator_args="${generator_args} --style=${selected_style}"

        # Out of template's styles folder
        popd &>/dev/null
    else
        log WARN "No style folder found for template ${selected_template}"
    fi

    dialog --keep-tite --title "Customization" --yesno "Do you want to change the displayed hostname?" 6 39
    if [ $? -eq 0 ]; then
        exec 3>&1;
        local custom_hostname=$(dialog --keep-tite --title "Customize displayed hostname" \
                                --inputbox "Enter a custom hostname:" 8 36 2>&1 1>&3)
        exec 3>&-
    fi

    if [ -n "${custom_hostname}" ]; then
        generator_args="${generator_args} --hostname=${custom_hostname}"
    fi

    # Get into the generator's folder
    pushd ".." &>/dev/null

    python generate.py ${generator_args}
    if [ $? -eq 0 ] && [ -f bash_prompt ]; then
        if [ -f "$HOME/.bash_prompt" ]; then
            mv "$HOME/.bash_prompt" "../../backups/$(date +%Y%m%d-%H%M%S)-bash_prompt"
            log NOTICE "Backed up previous .bash_prompt"
        fi
        mv bash_prompt "$HOME/.bash_prompt"
    fi

    # Out of generator folder
    popd &>/dev/null

    # Out of templates folder
    popd &>/dev/null
}
