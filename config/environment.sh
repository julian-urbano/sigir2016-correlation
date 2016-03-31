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

# If you want to use a single machine (and single process), set SGE=false and make RSCRIPT point to the Rscript binary
# in your machine.  Set SGE=true if you want to use an SGE cluster through qsub.
# You may need to edit file 'bin/qsub.sub' to change how R is loaded, as well as the notification e-mail address.
SGE=true
RSCRIPT=/cygdrive/c/Program\ Files/R/R-3.2.3/bin/x64/Rscript.exe

# Number of seconds to wait between qsub calls
SGE_WAIT=0.5

