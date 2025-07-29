# BSD 3-Clause License
#
# Copyright (c) 2024, Maksim Elizarev
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice, this
#    list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its
#    contributors may be used to endorse or promote products derived from
#    this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

# Reference: https://docs.opengosim.com/installing/ubuntu_install/

FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y git build-essential gfortran python3 python3-six python-six flex bison

# PETSc installation

WORKDIR /opt

RUN mkdir petsc

RUN git clone https://gitlab.com/petsc/petsc.git /opt/petsc

WORKDIR /opt/petsc

RUN git checkout v3.19.1

ENV PETSC_DIR=/opt/petsc
ENV PETSC_ARCH=ubuntu-opt

# WARNING: could not build PFLOTRAN-OGS with HDF5 enabled
RUN ./configure --download-mpich=yes --download-hdf5=yes --with-hdf5-fortran-bindings=yes --download-fblaslapack=yes --download-ptscotch=yes --download-hypre=yes --with-debugging=0 COPTFLAGS=-O3 CXXOPTFLAGS=-O3 FOPTFLAGS=-O3

RUN make PETSC_DIR=/opt/petsc PETSC_ARCH=ubuntu-opt all
RUN make PETSC_DIR=/opt/petsc PETSC_ARCH=ubuntu-opt check

# Add a user to install PFLOTRAN-OGS successfully

RUN useradd -ms /bin/bash dockerer
ENV USER=dockerer

# OGS PFLOTRAN installation

WORKDIR /opt

RUN git clone https://bitbucket.org/opengosim/pflotran_ogs_1.8.git

WORKDIR /opt/pflotran_ogs_1.8/src/pflotran
RUN make -j4 pflotran modern_gfortran=1
RUN make test

# Copy input files

WORKDIR /home/dockerer

COPY common common

COPY endurance endurance
RUN mkdir ./endurance/out

COPY east-mey east-mey
RUN mkdir ./east-mey/out

# Finalize

ENV PATH="${PETSC_DIR}/${PETSC_ARCH}/bin:${PATH}"
ENV PATH="/opt/pflotran_ogs_1.8/src/pflotran:${PATH}"

EXPOSE 8888
CMD ["/bin/bash"]
