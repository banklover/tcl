#!/bin/csh

# Loop until the "done" file exists
while (! -e done)
    echo "waiting"
    sleep 1
end

# Run the "run.csh" script once the "done" file is detected
./run.csh