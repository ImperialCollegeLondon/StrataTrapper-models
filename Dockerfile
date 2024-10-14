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
RUN ./configure --download-mpich=yes --download-hdf5=no --download-fblaslapack=yes --download-ptscotch=yes --download-hypre=yes --with-debugging=0 COPTFLAGS=-O3 CXXOPTFLAGS=-O3 FOPTFLAGS=-O3

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

# Finalize

ENV PATH="${PETSC_DIR}/${PETSC_ARCH}/bin:${PATH}"
ENV PATH="/opt/pflotran_ogs_1.8/src/pflotran:${PATH}"

EXPOSE 8888
CMD ["/bin/bash"]
