#!/bin/bash

set -euo pipefail

# Extension for so-called text files
_TXT_EXT="txt"

# user input validation
check_user_input() {
	local user_input="$1"
	if [[ ! $user_input =~ ^[[:alnum:]_]+[[:alnum:]_\.\ -]*$ ]]; then
		echo "This name is not allowed!"
		return 1
	fi
}

# Створити окрему папку
create_directory() {
	echo "---------------------------------------------------------------------"
	while [[ -z "${new_dir:-}" ]]; do
		read -r -p "Enter directory name: " new_dir
		check_user_input "$new_dir" || unset new_dir
		if [[ -e ${new_dir:-} ]]; then
			echo "Already exists! Use other name!"
			unset new_dir
		fi
	done
	echo "---------------------------------------------------------------------"
	mkdir -v -- "$new_dir"
	cd -- "$new_dir"
}

# Створити 3 текстові файли в новій папці
create_3_text_files() {
	echo "---------------------------------------------------------------------"
	for index in {0..2}; do
		# echo "Current file names: ${_INITIAL_FILES[@]}"
		while [[ -z "${_INITIAL_FILES[$index]:-}" ]]; do
			read -r -p "Enter file name ($index): " new_file
			check_user_input "$new_file" || continue
			# check for duplicates
			for f in "${_INITIAL_FILES[@]}"; do
				if [[ "$f" == "${new_file}.${_TXT_EXT}" ]]; then
					echo "Duplicate! Please enter some other name!"
					continue 2
				fi
			done
			_INITIAL_FILES+=("${new_file}.${_TXT_EXT}")
			# echo "Current element: ${_INITIAL_FILES[$index]}"
		done
	done
	touch "${_INITIAL_FILES[@]}"
	echo "---------------------------------------------------------------------"
	echo "The files have been created:"
	echo "----------------------------"
	ls -l "${_INITIAL_FILES[@]}"
	echo "---------------------------------------------------------------------"
}

# організувати зміну розширення файлів, через запит
change_files_extensions() {
	echo "---------------------------------------------------------------------"
	while [[ -z "${new_ext:-}" ]]; do
		read -r -p "Enter a new extension for the files: " new_ext
		check_user_input "$new_ext" || unset new_ext
		if [[ ${new_ext:-} == "$_TXT_EXT" ]]; then
			echo "This is the same as the old one!"
			unset new_ext
		fi
	done
	for file in "${_INITIAL_FILES[@]}"; do
		mv -Tv -- "$file" "${file%"$_TXT_EXT"}${new_ext}"
		_NEW_FILES+=("${file%"$_TXT_EXT"}${new_ext}")
	done
	echo "---------------------------------------------------------------------"
	echo "The files extensions have been changed:"
	echo "---------------------------------------"
	ls -l "${_NEW_FILES[@]}"
	echo "---------------------------------------------------------------------"
}

# Організувати заповнення файлів будь-якими даними через введення з консолі
fill_the_files_with_data_from_input() {
	# Here we are switching our terminal to Non-Canonical Mode Input Processing
	# to accept long lines from user input.
	#
	# Check `man 3 termios` regarding 4096 chars maximum line length limit for input.

	# save current terminal line settings
	local stty_settings
	stty_settings="$(stty -g)"

	# switch terminal to non-canonical mode and disable echo of Ctrl character
	stty -icanon -echoctl

	# handle INT signal (Ctrl+c)
	trap : SIGINT

	for file in "${_NEW_FILES[@]}"; do
		echo "---------------------------------------------------------------------"
		echo "Fill the file <$file> with some data."
		echo "Press <Ctrl+c> when done.."
		echo "---------------------------------------------------------------------"
		cat >"$file" || true
		echo
		echo "---------------------------------------------------------------------"
		echo -n "Size (in bytes) of <$file>: "
		du -b "$file" | cut -f1
		echo "---------------------------------------------------------------------"
	done

	# restore INT signal handling
	trap - SIGINT

	# restore terminal line settings
	stty "$stty_settings"
}

# Перевірити розміри файлів. Якщо розмір менше 5кб, збільшити розмір файлу до 5кб, випадковими текстовими даними
check_file_sizes() {
	echo "---------------------------------------------------------------------"
	echo "Checking sizes of files and extending them to 5kB if needed.."
	echo "---------------------------------------------------------------------"
	for file in "${_NEW_FILES[@]}"; do
		echo ">>>> Working on file: $file"
		file_size=$(du -b "$file" | cut -f1)
		echo "The file size is $file_size bytes."
		if [[ $file_size -lt 5120 ]]; then
			echo "Adding some random text data to grow it to 5kB"
			bytes_to_add=$((5120 - file_size))
			{ base64 -w 0 /dev/urandom || true; } | head -c $bytes_to_add >>"$file"
		else
			echo "OK: the file is greater than or equal to 5kB"
		fi
	done
	echo "---------------------------------------------------------------------"
	echo "Resulting file sizes (in bytes):"
	echo "--------------------------------"
	du -b "${_NEW_FILES[@]}"
	echo "---------------------------------------------------------------------"
}

# Вивести кількість символів "а" у всіх файлах
count_symbols() {
	local symbol=${1:?Missing symbol}
	echo "---------------------------------------------------------------------"
	echo -n "Count of <${symbol}> in all files: "
	{ grep -o "$symbol" "${_NEW_FILES[@]}" || true; } | wc -l
	echo "---------------------------------------------------------------------"
}

# main logic
create_directory
create_3_text_files
change_files_extensions
fill_the_files_with_data_from_input
check_file_sizes
count_symbols a
