#!/bin/sh

set -e

script=$(readlink -f "$0")
scriptdir=$(dirname "$script")
rootdir=$(readlink -f "${scriptdir}/..")
rootdir="${rootdir}/osl"

version_list=()

while [ $# -gt 0 ]; do
    version_list+=("$1")
    shift
done

if [[ "${#version_list[@]}" -eq 0 ]]; then
    for dir in ${rootdir}/*; do
        version_list+=($(basename ${dir}))
    done
fi

for version in ${version_list[@]}; do
    codename="${version}"
    suite="${version}"

    repodir="${rootdir}/${version}"
    distdir="${repodir}/dists/${suite}"
    pooldir="pool"

    mkdir -vp "${distdir}"
    cd "${distdir}"

    arch_list=($(find -type d -name 'binary-*' -printf '%f\n' | sort -u | cut -c8-))
    component_list=($(find -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort))

    echo "   Version: ${version}"
    echo "      Arch: ${arch_list[@]}"
    echo "Repository: ${repodir}"
    echo " Component: ${component_list[@]}"
    echo

    release_file=${distdir}/Release
    cat > ${release_file} << EOF
Origin: Elbrus Linux Repository
Label: Elbrus
Suite: ${suite}
Codename: ${codename}
Version: ${version}
Architectures: ${arch_list[@]}
Components: ${component_list[@]}
Description: Elbrus Linux software repository
Date: $(date -Ru)
EOF

    do_compress() {
        for file in $(find -type f -name Packages); do
            local file=$(echo ${file} | cut -c3-) # remove ./ prefix
            gzip -9 -f -k ${file}
            xz -9 -f -k ${file}
        done
    }

    do_hash_file() {
        local hash_cmd=$1
        local file=$2
        echo " $(${hash_cmd} ${file} | cut -d' ' -f1) $(wc -c ${file})"
    }

    do_hash() {
        hash_name=$1
        hash_cmd=$2
        echo "${hash_name}:"
        for file in $(find -type f -name Packages); do
            local file=$(echo ${file} | cut -c3-) # remove ./ prefix
            do_hash_file ${hash_cmd} ${file}
            do_hash_file ${hash_cmd} ${file}.gz
            do_hash_file ${hash_cmd} ${file}.xz
        done
    }

    do_compress
    do_hash "MD5Sum" "md5sum" >> ${release_file}
    do_hash "SHA1" "sha1sum" >> ${release_file}
    do_hash "SHA256" "sha256sum" >> ${release_file}
done
