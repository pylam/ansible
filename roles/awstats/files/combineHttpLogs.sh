#!/bin/bash

# This file is part of Fedora Project Infrastructure Ansible
# Repository.
#
# Fedora Project Infrastructure Ansible Repository is free software:
# you can redistribute it and/or modify it under the terms of the GNU
# General Public License as published by the Free Software Foundation,
# either version 3 of the License, or (at your option) any later
# version.
#
# Fedora Project Infrastructure Ansible Repository is distributed in
# the hope that it will be useful, but WITHOUT ANY WARRANTY; without
# even the implied warranty of MERCHANTABILITY or FITNESS FOR A
# PARTICULAR PURPOSE.  See the GNU General Public License for more
# details.
#
# You should have received a copy of the GNU General Public License
# along with Fedora Project Infrastructure Ansible Repository.  If
# not, see <http://www.gnu.org/licenses/>.

# Because sync-http may not get all logs for 3 days, we only merge
# things after 4 days. 

NUMDAYS=4
YEAR=$(/bin/date -d "-${NUMDAYS} days" +%Y)
MONTH=$(/bin/date -d "-${NUMDAYS} days" +%m)
DAY=$(/bin/date -d "-${NUMDAYS} days" +%d)

LOGDIR=/var/log/hosts
HTTPLOG=${LOGDIR}/proxy*/${YEAR}/${MONTH}/${DAY}/http/

TARGET=/mnt/fedora_stats/combined-http/${YEAR}/${MONTH}/${DAY}

AWSTATS=/usr/share/awstats/tools/logresolvemerge.pl

FILES=$( ls -1 ${HTTPLOG}/*access.log.xz | awk '{x=split($0,a,"/"); print a[x]}' | sort -u )

mkdir -p ${TARGET}

for FILE in ${FILES}; do
    TEMP=$(echo ${FILE} | sed 's/\.xz$//')
    perl ${AWSTATS} ${HTTPLOG}/${FILE} > ${TARGET}/${TEMP}
done
