#!/bin/bash

# Declare arrays to store user data
declare -a user_names
declare -a user_weights
declare -a user_heights
declare -a user_bmis

# Function to calculate BMI
calculate_bmi() {
    weight=$1
    height_meters=$2
    bmi=$(echo "scale=2; $weight / ($height_meters * $height_meters)" | bc)
    echo "$bmi"
}

# Function to interpret the BMI result
interpret_bmi() {
    bmi=$1
    if (( $(echo "$bmi < 18.5" | bc -l) )); then
        echo "Underweight"
        echo "You are below the healthy range. It is recommended to gain weight."
    elif (( $(echo "$bmi >= 18.5 && $bmi < 24.9" | bc -l) )); then
        echo "Normal"
        echo "Good! You are in the healthy range and stand a low risk of heart disease."
    elif (( $(echo "$bmi >= 25 && $bmi < 29.9" | bc -l) )); then
        echo "Overweight"
        echo "You are above the healthy range. It is recommended to lose weight."
    else
        echo "Obese"
        echo "You are significantly above the healthy range. Please consult a doctor."
    fi
}

# Function to convert height from feet and inches to meters
convert_height_to_meters() {
    feet=$1
    inches=$2
    total_inches=$(( (feet * 12) + inches ))
    height_meters=$(echo "scale=2; $total_inches * 0.0254" | bc)
    echo "$height_meters"
}

# Function to add a user and calculate BMI using dialog
add_user() {
    step=1
    while true; do
        case $step in
            1)
                name=$(dialog --inputbox "Enter your name:" 8 40 3>&1 1>&2 2>&3 3>&-)
                if [ $? -ne 0 ]; then
                    # If "Cancel" is pressed, exit add_user function
                    return
                fi
                step=2
                ;;
            2)
                weight=$(dialog --inputbox "What is your weight (kg)?" 8 40 3>&1 1>&2 2>&3 3>&-)
                if [ $? -ne 0 ]; then
                    # Go back to the name input step if "Cancel" is pressed
                    step=1
                    continue
                fi
                step=3
                ;;
            3)
                feet=$(dialog --inputbox "Enter your height (feet):" 8 40 3>&1 1>&2 2>&3 3>&-)
                if [ $? -ne 0 ]; then
                    # Go back to the weight input step if "Cancel" is pressed
                    step=2
                    continue
                fi
                step=4
                ;;
            4)
                inches=$(dialog --inputbox "Enter your height (inches):" 8 40 3>&1 1>&2 2>&3 3>&-)
                if [ $? -ne 0 ]; then
                    # Go back to the feet input step if "Cancel" is pressed
                    step=3
                    continue
                fi
                # Proceed if all inputs are given
                height_meters=$(convert_height_to_meters $feet $inches)
                bmi=$(calculate_bmi $weight $height_meters)

                # Store user data
                user_names+=("$name")
                user_weights+=("$weight")
                user_heights+=("$feet feet $inches inches")
                user_bmis+=("$bmi")

                bmi_message=$(interpret_bmi $bmi)
                dialog --msgbox "Your BMI: $bmi\n$bmi_message" 10 50
                break
                ;;
        esac
    done
}

# Function to display all user data using dialog
show_users() {
    if [ ${#user_names[@]} -eq 0 ]; then
        dialog --msgbox "No users added yet." 6 40
    else
        user_data=""
        for i in "${!user_names[@]}"; do
            user_data+="Name: ${user_names[$i]}\n"
            user_data+="Weight: ${user_weights[$i]} kg\n"
            user_data+="Height: ${user_heights[$i]}\n"
            user_data+="BMI: ${user_bmis[$i]}\n"
            user_data+=$(interpret_bmi ${user_bmis[$i]})
            user_data+="\n------------------------\n"
        done
        dialog --msgbox "$user_data" 15 60
    fi
}

# Main menu with dialog interface
main_menu() {
    while true; do
        choice=$(dialog --menu "BMI Management Calculator\nThis project was created by Saifulla Tanim and Mim Akter" 15 60 3 \
        1 "Add User" \
        2 "Show Users" \
        3 "Exit" 3>&1 1>&2 2>&3)

        case $choice in
            1)
                add_user
                ;;
            2)
                show_users
                ;;
            3)
                dialog --msgbox "Exiting..." 6 20
                break
                ;;
            *)
                dialog --msgbox "Invalid option. Please try again." 6 40
                ;;
        esac
    done
}

# Call the main menu function
main_menu
