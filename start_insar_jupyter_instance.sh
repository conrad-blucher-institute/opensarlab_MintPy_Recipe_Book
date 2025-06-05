#!/bin/bash
# A modified version of the start script that looks to self-contain the project instance inside its own project folder.

# Check if the correct number of arguments is provided
if [ $# -ne 3 ]
then
  echo "Incorrect usage. Correct usage: ./script_name <project name> <hostname> <port>"
  exit 1
fi

# Set the hostname and port from the input arguments
PROJECTNAME=$1
HOSTNAME=$2
PORT=$3

# Make directories
mkdir -m 775 -p "$(pwd)/$PROJECTNAME/logs"
mkdir -m 775 -p "$(pwd)/$PROJECTNAME/home"
mkdir -m 775 -p "$(pwd)/$PROJECTNAME/data"

# Clone Git repo
git clone https://github.com/conrad-blucher-institute/opensarlab_MintPy_Recipe_Book.git "$PROJECTNAME/home"

# Start the Singularity instance with mounted home directory and specified hostname, and log the output
singularity instance start -B $(pwd)/"${PROJECTNAME}"/home:/home/jovan --hostname $HOSTNAME earthscope_insar_oct_2024_latest.sif insar_jupyter_"${USER}"_"${PROJECTNAME}"  > "$PROJECTNAME/logs/singularity_start__${USER}_${HOSTNAME}.log" 2>&1

# Check if singularity instance started successfully
if [ $? -ne 0 ]; then
    echo "Failed to start singularity instance. Check ${PROJECTNAME}/logs/singularity_start_${HOSTNAME}.log for details."
    exit 1
fi

# Execute the Jupyter Notebook inside the Singularity instance
singularity exec instance://insar_jupyter_"${USER}"_"${PROJECTNAME}" nohup /usr/local/bin/start-notebook.sh --NotebookApp.port=$PORT --NotebookApp.ip='0.0.0.0' --NotebookApp.notebook_dir="/work/CBI_InSAR/${PROJECTNAME}/home" --no-browser > "${PROJECTNAME}/logs/insar_jupyter_${USER}_${HOSTNAME}.log" 2>&1 &
