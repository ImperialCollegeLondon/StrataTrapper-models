model_name=$1
num_proc=${2-4}
date_time=$(date '+%Y-%m-%d-%H-%M-%S')

out_dir="./out/${model_name}/${date_time}"
mkdir -p "${out_dir}"

mpiexec -n "${num_proc}$" pflotran -pflotranin "${model_name}.in" -output_prefix "${out_dir}/${model_name}-${date_time}"
