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

SCRATCH=scratch/qout/12-compile

# Create dir for qsub's out and err files
if [ "$SGE" == true ]; then
	mkdir -p $SCRATCH
fi

if [ "$SGE" == true ]; then
	qsub -N "compile" \
		-v COMMAND="src/12-compile.R" \
		-o $SCRATCH/12-compile.out \
		-e $SCRATCH/12-compile.err \
		bin/qsub.sub
else
	"$RSCRIPT" src/12-compile.R
fi
