#!/bin/bash
echo ""

usage() {

  echo "hoarder: a Helpful OMara to ACSC Repository Dataset Exporter & Reshaper"
  echo ""
  echo "Script to copy a simulation replicate into a dataset with the directory structure"
  echo "suitable for the atb acsc repository at https://molecular-dynamics.atb.uq.edu.au"
  echo "Intended for validation with https://atb-uq.github.io/csc-tools/"
  echo ""
  echo ""
  echo "options:"
  echo ""
  echo "  -i or --input_sysname  : the system name of the simulation replicate.  Required."
  echo "                           Input files should have names like input_sysname.mdp,"
  echo "                           input_sysname.tpr, input_sysname.top, etc, etc "
  echo ""
  echo "  -p or --input_path     : the path to the simulation replicate.  Required."
  echo ""
  echo "  -o or --output_sysname : System name to be used by the ATB ACSC repository. Required."
  echo "                           This must be unique.  Our standard structure is "
  echo "                           OMara_[Detailed-project-name]-[publication-year]_[Detailed-system-name]_r[number]"
  echo "                           for example, replicate one of the ring oxidised cholesterol system from"
  echo "                           our Neuronal OxChol paper doi.org/10.1021/acschemneuro.1c00395"
  echo "                           would have the name: OMara_NeuronalOxChol-2021_ringOHC_r1"
  echo ""
  echo "  -q or --output_path    : place to save output. Default is current working directory."
  echo ""
  echo "  -f or --ff_path        : path to the folder containing the majority of .itp files. Required."
  echo "                           needs to be different to --input_path otherwise it will copy your entire system"
  echo "                           into the forcefield-files folder."
  echo ""
  echo "  --rep                  : replicate number of this replicate.  Optional."
  echo "                           Changes replicate number in atbrepo.yaml metadata file."
  echo ""
  echo "  --reps                 : total number of replicates that exist for this system. Optional."
  echo "                           Changes total replicate number in atbrepo.yaml metadata file."
  echo ""
  echo "  -x or --extra_itp      : path to an additional .itp file from outside --ff_path. Optional."
  echo "                           Can be repeated multiple times."
  echo ""
  echo "  --dry-run              : print all inputs, check input_path and ff_path are valid, then exit"
  echo ""
  echo "  --notrj                : copy all simulation data except trajectory files. Optional."  
  echo ""
  echo "  --notrr                : do not copy .trr trajectory files. Optional."  
  echo ""
  echo "  -h                     : print this message then exit."  
  echo ""
  exit 0
}

# Default values

working=$(pwd)
extra_itp=()
dry_run=false
notrj=false
notrr=false
output_path="./"
multistep=false

# Parse command line arguments
ARGS=$(getopt -o hi:p:o:q:f::x: --long help,input_sysname:,input_path:,output_sysname:,ff_path:,rep:,reps:,extra_itp:,dry-run,notrj,notrr,multistep -- "$@")

eval set -- "$ARGS"

# Process options and their arguments
while true; do
  case "$1" in
    -i|--input_sysname)
      input_sysname="$2"
      shift 2
      ;;
    -p|--input_path)
      input_path="$2"
      shift 2
      ;;
    -o|--output_sysname)
      output_sysname="$2"
      shift 2
      ;;
    -q|--output_path)
      output_path="$2"
      shift 2
      ;;
    -f|--ff_path)
      ff_path="$2"
      shift 2
      ;;
    --rep)
      rep="$2"
      shift 2
      ;;
    --reps)
      reps="$2"
      shift 2
      ;;
    -x|--extra_itp)
      extra_itp+=("$2")
      shift 2
      ;;
    --dry-run)
      dry_run=true
      shift
      ;;
    --multistep)
      multistep=true
      shift
      ;;
    --notrj)
      notrj=true
      shift
      ;;
    --notrr)
      notrr=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    --)
      shift
      break
      ;;
    *)
      echo "Invalid option: $1"
      usage
      exit 1
      ;;
  esac
done


# check that variables are set
if [ -z "$input_sysname" ] ; then
  echo "Error: --input_sysname not specified"
  exit 1
fi

if [ -z "$input_path" ] ; then
  echo "Error: --input_path not specified"
  exit 1
fi

# Check that input path folder exists
if [ ! -d "$input_path" ]; then
  echo "Error: --input_path folder '$input_path' not found"
  exit 1
fi

if [ -z "$output_sysname" ] ; then
  echo "Error: --output_sysname not specified"
  exit 1
fi

# Check that output path folder exists
if [ ! -d "$output_path" ]; then
  echo "Error: --output_path folder '$output_path' not found "
  exit 1
fi


if [ -z "$ff_path" ] ; then
  echo "Error: --forcefield_folder not specified"
  exit 1
fi

# Check that forcefield folder exists
if [ ! -d "$ff_path" ]; then
  echo "Error: --ff_path folder '$ff_path' not found "
  exit 1
fi

# print output

# Output the values of the variables
echo "Input sysname: $input_sysname"
echo "Input filepath: $input_path"
echo "Output sysname: $output_sysname"
echo "Output filepath: $output_path"
echo "--notrj:" $notrj 
echo "--notrr:" $notrr 

if [ -n "$rep" ]; then
  echo "This replicate: $rep"
fi
if [ -n "$reps" ]; then
  echo "Total replicates: $reps"
fi
echo "Forcefield folder path: $ff_path"
if [ ${#extra_itp[@]} -gt 0 ]; then
  echo "Extra ITP files: ${extra_itp[@]}"
fi
if [ "$dry_run" = true ]; then
  echo "" 
  echo "Dry run; exiting now"
  exit 0
else
  echo "--dry-run:" $dry_run
fi
#   echo "--multistep:" $multistep
# if [ "$multistep" = true ]; then
#   echo "Will look for all files distributed across multiple run steps" 

    # set up rename_files function for multistep runs
      rename_files() {
        local old_pattern="$1"
        local new_pattern="$2"
        for file in "$old_pattern"*; do
          mv "$file" "${file/$old_pattern/$new_pattern}"
        done
        }

fi

# if [ "$trj" = true ]; then
#   echo "--trj specified; trajectory files will be copied"
# fi

# do the damn thing

echo ""
echo "Beginning system copy"

if [ -d "${output_path}/${output_sysname}" ]; then
  echo "ALERT: directory '${output_path}/$output_sysname' already exists"
  echo
fi


mkdir ${output_path}/${output_sysname} -p

cat <<EOF > ${output_path}/${output_sysname}/atbrepo.yaml
title: "This will appear as the title of the simulation on the ACSC website. Should be enclosed in quotation marks. {replicate TKTKTK of KTKTKT}"
notes: "This will appear as a description of the simulation on the ACSC website. Should be enclosed in quotation marks.  If the data is related to a publication, the DOI of the publication can also be included in this field. {replicate TKTKTK of KTKTKT}"
program: GROMACS
organization: omara
tags:
    - replicate-TKTKTK of KTKTKT
    - forcefield-[forcefield name and version]
    - membrane-[type of membrane]
    - PDB-[pdb code]
    - protein-[example name of protein]
    - peptide-[example name of peptide]
    - lipid-[example name of lipid]
THE NEXT LINES ARE TAGS FOR EVERY MOLECULE IN THE SYSTEM.  CHANGE THEM from molecule-MOLNAME to whatever type of molecule they are, eg "lipid-POPC" or "solvent-PW" or "protein-GlyT2".  Remove this line when complete, and the example molecule tags above
EOF

if [ -n "$rep" ]; then # if --rep defined, find and replace placeholder with rep number
  sed -i 's/TKTKTK/'"$rep"'/g' ${output_path}/${output_sysname}/atbrepo.yaml
fi

if [ -n "$reps" ]; then # if --reps defined, replace placeholder with total rep number
  sed -i 's/KTKTKT/'"$reps"'/g' ${output_path}/${output_sysname}/atbrepo.yaml
fi

  # copying for normal runs; this should be most cases

  # copy control files

  mkdir ${output_path}/${output_sysname}/control -p
  cp ${input_path}/${input_sysname}.mdp ${output_path}/${output_sysname}/control/${output_sysname}_control_00001.mdp

  if [ -f "${input_path}/${input_path}.ndx" ]; then       # for now I'm capturing the index files in the control directory, but sharif is going to chat to his team about how we want to handle these going forward
    cp ${input_path}/${input_sysname}.ndx ${output_path}/${output_sysname}/control/${output_sysname}_control_00002.ndx
  fi
  # copy energy files if any exist

  mkdir ${output_path}/${output_sysname}/energy -p
  if [ -f "${input_path}/${input_path}.edr" ]; then 
      cp ${input_path}/${input_sysname}.edr ${output_path}/${output_sysname}/energy/${output_sysname}_energy_00001.edr
  fi

  # copy final coordinates if any exist
  mkdir ${output_path}/${output_sysname}/final-coordinates -p
  if [ -f "${input_path}/${input_sysname}.gro" ]; then 
      cp ${input_path}/${input_sysname}.gro ${output_path}/${output_sysname}/final-coordinates/${output_sysname}_final-coordinates_00001.gro
  fi

  # copy input coordinates if any exist
  mkdir ${output_path}/${output_sysname}/input-coordinates -p
  if [ -f "${input_path}/${input_sysname}_start.gro" ]; then 
      cp ${input_path}/${input_sysname}_start.gro ${output_path}/${output_sysname}/input-coordinates/${output_sysname}_input-coordinates_00001.gro
  fi

  # copy forcefield files itp files etc)
  mkdir ${output_path}/${output_sysname}/forcefield-files -p
  cp ${ff_path}/* ${output_path}/${output_sysname}/forcefield-files/

  # grab extra itp files if any were specified, like the protein.itp you get from go_martinize, add them to the forcefield files
  if [ ${#extra_itp[@]} -gt 0 ]; then
    for itp in ${extra_itp[@]}; do
      fname=$(basename "$itp")
      if test -e "${output_path}/${output_sysname}/forcefield-files/${fname}"
      then
        echo "ERROR: You have specified --extra_itp ${itp} , however a file with the name ${fname} already exists in ${output_path}/${output_sysname}/forcefield-files/"
        echo "Please fix this and run your command again"
        exit 1
      fi
      cp $itp  ${output_path}/${output_sysname}/forcefield-files/
    done
  fi

  # copy log file if it exists
  mkdir ${output_path}/${output_sysname}/log -p
  if [ -f "${input_path}/${input_sysname}.log" ]; then 
      cp ${input_path}/${input_sysname}.log ${output_path}/${output_sysname}/log/${output_sysname}_log_00001.log
  fi

  # make a reference coordinates folder (required)
  # user will have to add any reference coordinates manually for now
  mkdir ${output_path}/${output_sysname}/reference-coordinates -p

  # copy topology file
  mkdir ${output_path}/${output_sysname}/topology -p
  cp ${input_path}/${input_sysname}.top ${output_path}/${output_sysname}/topology/${output_sysname}_topology_00001.top

  # parse the log file to generate a molecule tag for every molecule
  INFILE=${output_path}/${output_sysname}/topology/${output_sysname}_topology_00001.top
  OUTPUT=""

  while read line 
  do 
      if [[ $line == "[ molecules ]" ]]
      then # find every line afterwards that includes a single unbroken string of characters, followed by whitespace of undetermined nonzero length, and then a number 
          while read line 
          do 
              if [[ $line != "\;*" ]] 
                  then 
                  if [[ $line =~ ^([^[:blank:]]+)[[:blank:]]+([[:digit:]]+)  && ${BASH_REMATCH[2]} != "0" ]] 
                      then
                      OUTPUT="$OUTPUT${BASH_REMATCH[1]} ${BASH_REMATCH[2]}\n" # save all these lines to the variable
                  fi 
              fi 
          done < "$INFILE" 
      fi 
  done < "$INFILE"

  # use awk to modify the output variable, excluding all diplicates or molecules that are present zero times
  MODIFIED=$(echo -e "$OUTPUT" | awk '{print $1}' | awk '!seen[$0]++')

  # process these into tags
  FINAL=$(echo "$MODIFIED" | awk '{print "    - molecule-"$1}')

  # append molecule tag lines to file
  echo "$FINAL" >> ${output_path}/${output_sysname}/atbrepo.yaml
  echo "DUMMY LINE. This meaningless line will make this dataset fail validation.  Remove this line when you are finished editing" >> ${output_path}/${output_sysname}/atbrepo.yaml


  # copy trajectory data

  mkdir ${output_path}/${output_sysname}/trajectory -p # folder is required regardless of whether trajectories are included
  # copy trajectories unless --notrj was specified
  if [ "$notrj" == false ]; then
      files=false
      if [ -f "${input_path}/${input_sysname}.xtc" ]; then 
          echo "copying trajectory file ${input_path}/${input_sysname}.xtc"
          echo
          rsync --progress ${input_path}/${input_sysname}.xtc ${output_path}/${output_sysname}/trajectory/${output_sysname}_trajectory_00001.xtc # use rsync for a progress bar and for data fidelity; trajectories are big
          files=true
      fi
      if [ -f "${input_path}/${input_sysname}.trr" ] && [ "$notrr" == false ]; then 
          echo "copying trajectory file ${input_path}/${input_sysname}.trr"
          echo "ALERT: MAKE SURE YOU ACTUALLY WANT THIS, .trr FILES ARE USUALLY ENOURMOUS"
          echo
          rsync --progress ${input_path}/${input_sysname}.trr ${output_path}/${output_sysname}/trajectory/${output_sysname}_trajectory_00001.trr # use rsync for a progress bar and for data fidelity; trajectories are big
          files=true
      fi
      if [ $files == false ]; then
          "ALERT: no trajectory files were found with file names ${input_path}/${input_sysname}.(xtc|trr)"
      fi
  else
      echo "--notrj specified, trajectories not copied"
  fi



echo ""
echo "Copying complete."
echo "You will need to edit ${output_sysname}/atbrepo.yaml with information relevant to your system."
echo "Please also check the contents of ${output_sysname}/topology for unecessary leftover files."
echo "Thanks for hoarding!"
