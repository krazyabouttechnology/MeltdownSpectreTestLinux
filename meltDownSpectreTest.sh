#! /bin/bash

#    Intel CPUs Meltdown and Spectre Test script
#    Author : Sumit Bhardwaj

#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.


#Color Constants
RED_COLOR='\033[0;33m'
GREEN_COLOR='\033[0;32m'
YELLOW_COLOR='\033[1;33m'
BLUE_COLOR='\033[1;34m'
NO_COLOR='\033[0m'

echo
echo -e "${YELLOW_COLOR}Test Script for Meltdown and Spectre Bugs on Intel Processors by Sumit Bhardwaj v1.0"
echo -e "-----------------------------------------------------------------------------------------${NO_COLOR}"
echo

#Check for presence of Intel Processor
is_proc_intel=`cat /proc/cpuinfo | grep -i GenuineIntel | wc -l`

if [ "$is_proc_intel" -lt 1 ]; then
    echo -e "${BLUE_COLOR}You do not seem to have an Intel Processor in this system. This test is not applicable to you.${NO_COLOR}"
	echo
    exit
fi

#Get CPU Model Name String
proc_name=`cat /proc/cpuinfo | grep -i -m1 "model name" | cut -d: -f 2 | sed 's/^[ \t]*//;s/[ \t]*$//'`
echo -e "${BLUE_COLOR}Checking CPU : $proc_name ...${NO_COLOR}"
echo

#Test 1 : Check for CONFIG_PAGE_TABLE_ISOLATION = y entry in /boot/config of current kernel
un=`uname -r`
res1=`grep -q CONFIG_PAGE_TABLE_ISOLATION=y /boot/config-$un && echo "${GREEN_COLOR}PASSED${NO_COLOR}" || echo "${RED_COLOR}FAILED${NO_COLOR}"`
echo -e "CONFIG_PAGE_TABLE_ISOLATION check : $res1"
echo 

#Test 2 : Check for presence of cpu_insecure text in output of /proc/cpuinfo. Its presence means its being reported as patched.
res2=`grep -q cpu_insecure /proc/cpuinfo && echo "${GREEN_COLOR}PASSED${NO_COLOR}" || echo "${RED_COLOR}FAILED${NO_COLOR}"`
echo -e "CPUINFO cpu_insecure flag check : $res2"
echo

#Test 3 : Check for presence of specific text in dmesg output emitted during the boot process.
res3=`dmesg | grep -q "Kernel/User page tables isolation: enabled" && echo "${GREEN_COLOR}PASSED${NO_COLOR}" || echo "${RED_COLOR}FAILED${NO_COLOR}"`
echo -e "DMESG message check : $res3"
echo 

#If all tests passed, its good news
if [ "$res1" == "${GREEN_COLOR}PASSED${NO_COLOR}" ] && [ "$res2" == "${GREEN_COLOR}PASSED${NO_COLOR}" ] && [ "$res3" == "${GREEN_COLOR}PASSED${NO_COLOR}" ]; then
	echo -e "${GREEN_COLOR} It seems that Kernel Page Table Isolation (KPTI) is enabled on your system. You are patched against Meltdown and Spectre bugs.${NO_COLOR}"
else #Bad news
	echo -e "${RED_COLOR} At least one of the tests failed, which means Kernel Page Table Isolation (KPTI) is either not enabled or not being correctly reported."
	echo -e " Please check your kernel patching status with your distribution's website documentation.${NO_COLOR}"
fi
echo

#Standard disclaimer in any case.
echo "Disclaimer: These tests are by no means exhaustive or 100% acurate and can result in false positives/negatives being reported." 
echo "            Please consider the test results as indicative values only. There are no guanrantees claimed whatsoever."
echo
