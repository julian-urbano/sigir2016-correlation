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

# Create array with names of test collections in 'data/*.csv'. If you want to use specific files, create an array here:
# COLLECTIONS=(mycol1 mycol2)
COLLECTIONS=(data/*.csv)

# Clean collection names (remove path and file extension)
for I in ${!COLLECTIONS[*]}; do
	COLLECTION=${COLLECTIONS[$I]}
	COLLECTION=${COLLECTION##*/} # remove path
	COLLECTION=${COLLECTION%.*} # remove '.csv' extension
	COLLECTIONS[$I]=$COLLECTION
done

# Create array with names of estimators in 'src/estimators/estimator.*.R'. If you want to use specific estimators,
# create an array here:
# ESTIMATORS=(myestimator1 myestimator2)
ESTIMATORS=(src/estimators/estimator.*.R)

# Clean estimator names (remove path and file extension)
for I in ${!ESTIMATORS[*]}; do
        ESTIMATOR=${ESTIMATORS[$I]}
        ESTIMATOR=${ESTIMATOR##*/estimator.} # remove path and 'estimator.'
        ESTIMATOR=${ESTIMATOR%.*} # remove '.R'
        ESTIMATORS[$I]=$ESTIMATOR
done