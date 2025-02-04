#!/bin/sh

set -e

script=$(readlink -f "$0")
scriptdir=$(dirname "$script")
rootdir=$(readlink -f "${scriptdir}/..")
rootdir="${rootdir}/osl"

function help() {
    echo "usage: scan-packages.sh [OPTIONS] VERSION COMPONENT..."
    echo
    echo "Available positional items:"
    echo "    VERSION                   OSL version"
    echo "    COMPONENT                 Component list"
    echo
    echo "Available options:"
    echo "    -a, --arch=ARCH           Scan packages for selected architectures [default: all]"
    echo "    -r, --release             Update release file at the end"
    echo "    -h, --help                Prints help information"
}

# additional commands
print_arch_list=0
update_release=0

# command arguments
version=""
arch_list=()
component_list=()

while [ $# -gt 0 ]; do
    case "$1" in
        "-a")
            arch_list+=("$2")
            shift
            ;;
        "--arch="*)
            arch_list+=("${1#--arch=*}")
            ;;
        "-l" | "--list-arch")
            print_arch_list=1
            ;;
        "-r" | "--release")
            update_release=1
            ;;
        "-h" | "--help")
            help
            exit
            ;;
        *)
            if [[ -z "${version}" ]]; then
                version="$1"
            else
                component_list+=("$1")
            fi
            ;;
    esac
    shift
done

if [[ -z "${version}" ]]; then
    help
    exit 1
fi

repodir="${rootdir}/${version}"
distdir="${repodir}/dists/${suite}"
pooldir="pool"

if [[ ${print_arch_list} -eq 1 ]]; then
    arch_list=()
fi

if [[ "${#arch_list[@]}" -eq 0 ]]; then
    for dir in ${repodir}/${pooldir}/main/*; do
        arch=$(basename ${dir})
        arch_list+=(${arch})
    done
fi

if [[ ${print_arch_list} -eq 1 ]]; then
    echo "${arch_list[@]}"
    exit
fi

if [[ ! -d "${repodir}" ]]; then
    echo "error: repository does not exist ${repodir}"
    exit 1
fi

cd "${repodir}"

if [ "${#component_list[@]}" -eq 0 ]; then
    component_list=($(find ${pooldir} -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | sort))
fi

echo "Scanning packages..."
echo "   Version: ${version}"
echo "      Arch: ${arch_list[@]}"
echo "Repository: ${repodir}"
echo " Component: ${component_list[@]}"
echo

for component in ${component_list[@]}; do
    component_dir="${pooldir}/${component}"
    for arch in ${arch_list[@]}; do
        component_arch_dir="${component_dir}/${arch}"
        if [[ ! -d "${component_arch_dir}" ]]; then
            echo "warning: component does not exist ${component_arch_dir}"
            continue
        fi
        echo
        echo "Scaning ${component_arch_dir}..."
        binary_dir=${distdir}/${component}/binary-${arch}
        output=${binary_dir}/Packages
        mkdir -p ${binary_dir}
        dpkg-scanpackages --multiversion --arch ${arch} ${component_dir} > ${output}
    done
done

echo

if [[ ${update_release} -eq 1 ]]; then
    echo "Updating release file..."
    ${scriptdir}/update-release.sh ${version}
fi
