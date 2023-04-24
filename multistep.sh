# else

#     # # multistep runs
#     # # right now I've spun these off into their own function because they're a mess to deal with
#     # # this needs testing and should always be inspected manually

#     # echo "attempting to copy a multistep system"
#     # echo "these are not named consistently and copying may be unreliable, please verify your output is what you intended"

#     # # copy control files

#     # mkdir ${output_path}/${output_sysname}/control -p
#     # cp ${input_path}/*.mdp ${output_path}/${output_sysname}/control/ # copy all mdps for multistep run
#     # cd ${output_path}/${output_sysname}/control/
#     # rename_files ${input_sysname}"." ${output_sysname}_control_000 # rename mdps from ${input_sysname}.01.mdp to ${output_sysname}_control_00001.mdp
#     # cd $working # in case $output_path is relative to working directory

#     # # copy energy files if any exist

#     # mkdir ${output_path}/${output_sysname}/energy -p
#     # cp ${input_path}/*.edr energy/ # copy all edrs for multistep run
#     # cd ${output_path}/${output_sysname}/energy
#     # rename_files ${input_sysname}"." ${output_sysname}_energy_000 # rename edrs from ${input_sysname}.01.edr to ${output_sysname}_energy_00001.edr
#     # cd $working # in case $output_path is relative to working directory

#     # # copy final coordinates if any exist
#     # mkdir ${output_path}/${output_sysname}/final-coordinates -p
#     # cd ${input_path}
#     # flist=$(find . -type f -name "${input_sysname}.[0-9]+.gro")
#     # final=$(echo "$flist" | sort -n | tail -n 1)
#     # cd $working # in case $output_path is relative to working directory
#     # cp ${input_path}/$final ${output_path}/${output_sysname}/${output_sysname}_final-coordinates_00001.gro

#     # # copy input coordinates if any exist
#     # mkdir ${output_path}/${output_sysname}/input-coordinates -p
#     # if [ -f "${input_path}/${input_sysname}.00.gro" ]; then 
#     #     cp ${input_path}/${input_sysname}".00.gro" ${output_path}/${output_sysname}/input-coordinates/${output_sysname}_input-coordinates_00001.gro
#     # fi

#     # # copy forcefield files itp files etc)
#     # mkdir ${output_path}/${output_sysname}/forcefield-files -p
#     # cp ${ff_path}/* ${output_path}/${output_sysname}/forcefield-files/

#     # # grab extra itp files if any were specified, like the protein.itp you get from go_martinize, add them to the forcefield files
#     # if [ ${#extra_itp[@]} -gt 0 ]; then
#     #   for itp in ${extra_itp[@]}; do
#     #     fname=$(basename "${itp}")
#     #     if test -e "${output_path}/${output_sysname}/forcefield-files/${fname}"
#     #     then
#     #       echo "ERROR: You have specified --extra_itp ${itp} , however a file with the name ${fname} already exists in ${output_path}/${output_sysname}/forcefield-files/"
#     #       echo "Please fix this and run your command again"
#     #       exit 1
#     #     fi
#     #     cp $itp  ${output_path}/${output_sysname}/forcefield-files/
#     #   done
#     # fi

#     # # copy log file if it exists
#     # mkdir ${output_path}/${output_sysname}/log -p
#     # cp ${input_path}/*.log ${output_path}/${output_sysname}/log/*
#     # cd ${output_path}/${output_sysname}/log/
#     # rename_files ${input_sysname}"." ${output_sysname}_log_000 # rename logs from ${input_sysname}.01.log to ${output_sysname}_log_00001.log
#     # cd $working # in case $output_path is relative to working directory

#     # # make a reference coordinates folder (required)
#     # # user will have to add any reference coordinates manually for now
#     # mkdir ${output_path}/${output_sysname}/reference-coordinates -p

#     # # copy topology file
#     # mkdir ${output_path}/${output_sysname}/topology -p
#     # echo "copying topology files:"
#     # toplist=$(ls "${input_path}/*.top")
#     # if [ ${#toplist[@]} -gt 1 ]; then
#     #   echo "ERROR:  more than one file found matching name ${input_path}/*.top"
#     #   echo "Copying all files, you will need to resolve this yourself."
#     #   cp ${input_path}/*.top ${output_path}/${output_sysname}/topology
#     # else
#     #   cp ${input_path}/*.top ${output_path}/${output_sysname}/topology/${output_sysname}_topology_00001.top
#     # fi    

    
#     # mkdir ${output_path}/${output_sysname}/trajectory -p # folder is required regardless of whether trajectories are included
#     # # copy trajectories unless --notrj was specified
#     # if [ "$notrj" = false ]; then
#     #     files=false
#     #     xtclist=(ls "${input_path}/*.xtc")
#     #     if [ ${#xtclist[@]} -gt 0 ]; then
#     #         echo "copying trajectory file ${input_path}/*.xtc"
#     #         rsync --progress --include="*.xtc" --exclude="*" ${input_path}/"*" ${output_path}/${output_sysname}/trajectory/ # use rsync for a progress bar and for data fidelity; trajectories are big
#     #         files=true
#     #     fi
#     #     trrlist=(ls "${input_path}/*.trr")
#     #         if [ ${#trrlist[@]} -gt 0 ]; then
#     #         echo "copying trajectory files ${input_path}/*.trr"
#     #         echo "ALERT: MAKE SURE YOU ACTUALLY WANT THIS, .trr FILES ARE USUALLY ENOURMOUS"
#     #         rsync --progress --include="*.trr" --exclude="*" ${input_path}/"*" ${output_path}/${output_sysname}/trajectory/ # use rsync for a progress bar and for data fidelity; trajectories are big
#     #         files=true
#     #       fi
#     #     if [ $files=false ]; then
#     #         "ALERT: no trajectory files were found with file names ${input_path}/*.(xtc|trr)"
#     #     else
#     #       cd $working
#     #       cd ${output_path}/${output_sysname}/trajectory/
#     #       rename_files ${input_sysname}"." ${output_sysname}_trajectory_000 # rename trajectory from ${input_sysname}.01.(xtc|trr) to ${output_sysname}_trajectory_00001.(xtc|trr)

#     #     fi
#     # else
#     #     echo "--notrj specified, trajectories not copied"
#     # fi
# fi