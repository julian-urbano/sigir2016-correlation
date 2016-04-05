# Copyright (C) 2016  Julián Urbano <urbano.julian@gmail.com>
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see http://www.gnu.org/licenses/.

source config/environment.sh
source config/params.sh

SCRATCH=scratch/qout/01-simulation

# Create dir for qsub's out and err files
if [ "$SGE" == true ]; then
	mkdir -p $SCRATCH
fi

BATCHES=100

for COLLECTION in "${COLLECTIONS[@]}"; do
	if [ "$SGE" == true ]; then
		qsub -N "$COLLECTION" \
			-v COMMAND="src/01-simulation.R $COLLECTION" \
			-t 1-$BATCHES \
			-o $SCRATCH/$COLLECTION-'$TASK_ID.out' \
			-e $SCRATCH/$COLLECTION-'$TASK_ID.err' \
			bin/qsub.sub
		sleep $SGE_WAIT
	else
		for BATCH in $(seq 1 $BATCHES); do
			"$RSCRIPT" src/01-simulation.R $COLLECTION $BATCH $BATCHES
		done
	fi
done
