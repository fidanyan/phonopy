date

# terminate on error
set -e

AIMS_EXE=''

for dir1 in constrained-new-phonopy constrained-supercell-new full-new-phonopy full-old-phonopy full-supercell-new full-supercell-old
do
    cd ${dir1}
        for i in `seq -w 66`
        do
            if [ -d phonopy-FHI-aims-displacement-0$i ]; then
                cd phonopy-FHI-aims-displacement-0$i
#                    printf "i = %s...     " "$i" 
#                    cp ../D_spin_01_kpt_000001.csc ./
#                    srun -N 1 -n 32 $AIMS_EXE > phonopy-FHI-aims-displacement-0${i}.out &
                    printf "%s/phonopy-FHI-aims-displacement-0%s ...\t\t" "${dir1}" "$i"
                    wait
                    printf "done\n"
                    sleep 1
                cd ..
            elif [ $i -eq 19 ]; then break
            fi
        done
    cd ..
done
echo "The last task!"
date
