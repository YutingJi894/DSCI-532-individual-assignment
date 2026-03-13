# Individual Assignment Dashboard

This repository contains an individual Shiny for R dashboard based on the group project on non-market housing in Vancouver. The app allows users to filter projects by local area and view summary metrics and a bar chart of clientele unit totals.

## Deployments

The dashboard is hosted on Posit Connect. Use the links below to access the live versions:

- 

## Locally Running the Dashboard

### Cloning the Repository

Clone this GitHub repository and navigate to the project folder using the following commands:

```bash
git clone https://github.com/YutingJi894/DSCI-532-individual-assignment.git
cd DSCI-532-individual-assignment
```
### Install the packages
Install the required packages with
```bash
R -e "install.packages(c('shiny', 'bslib', 'dplyr', 'readr', 'ggplot2', 'rsconnect'), repos='https://cloud.r-project.org')"
```
After adding or removing packages, regenerate the deployment manifest with:
```bash
R -e "rsconnect::writeManifest()"
```
### Running the Dashboard

Run the dashboard using Shiny with the following command:

```bash
R -e "shiny::runApp()"
```
