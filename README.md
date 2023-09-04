# Bash Script 

## Color Codes

The script uses color codes to make the output more visually informative:
- Red: Indicates an error or important message.
- Yellow: Used for status messages and warnings.
- Green: Indicates successful execution.

### update.sh

This bash script is designed to perform the following tasks:
- Update snap packages
- Update apt-get packages
- Check if updates were made for snap packages

### Script Details
- The script starts by checking if it's being run as the root user. If not, it will display an error message and exit.
- It then updates snap packages using the `snap refresh` command and displays the output.
- Next, it updates apt-get packages using `apt-get update` and `apt-get upgrade`.
- Finally, the script checks if any updates were made for snap packages by examining the output of the snap refresh command.

### Example Output

Here is an example of what the script's output might look like:

```bash
Updating snap packages...
All snaps are up to date.
Updating apt-get packages...
...
Snap updates were made.
Script Finished!
```
