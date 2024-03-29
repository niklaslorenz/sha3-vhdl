#!/bin/bash

src_dir=$(pwd)/src
test_dir=$(pwd)/test

sources=("keccak_types" \
"keccak_theta" \
"keccak_rho" \
"keccak_pi" \
"keccak_chi" \
"keccak_iota" \
"keccak_p" \
"keccak_f" \
"sha3_types" \
"sha3")

test_instances=("keccak_theta_test" \
"keccak_rho_test" \
"keccak_pi_test" \
"keccak_chi_test" \
"keccak_iota_test" \
"keccak_p_test" \
"keccak_f_test" \
"sha_pad_test" \
"sha3_helloworld_test" \
"hash_zero_test")

test_sources=("testutil")
test_sources+=(${test_instances[@]})

echo export test instances
mkdir -p ../build/sha3-vhdl
echo ${test_instances[@]} > ../build/sha3-vhdl/test_instances

pushd . > /dev/null
cd ../build/sha3-vhdl
echo clear vhdl work directory
rm -r -f ./work
echo build vhdl sources
for f in ${sources[@]}; do
nvc -a "${src_dir}/${f}.vhdl"
if [ $? -ne 0 ]; then
echo build aborted
exit 1
fi
done
echo build vhdl test sources
for f in ${test_sources[@]}; do
nvc -a "${test_dir}/${f}.vhdl"
if [ $? -ne 0 ]; then
echo build aborted
exit 1
fi
done
echo elaborate vhdl test instances
for f in ${test_instances[@]}; do
nvc -e ${f}
done
popd > /dev/null
