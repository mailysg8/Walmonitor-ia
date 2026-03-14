# Walmonitor-ia

## Overview

Walmonitor is a dashboard for visualizing the performance of Walmart stores across different branches and time periods. It provides insights into sales trends, customer trends and other key performance indicators to help stakeholders make informed decisions.

## Instructions

To access app, click on this link : (https://019cee2d-3fd5-285e-a6ac-5dcfaf9a98f6.share.connect.posit.cloud)[https://019cee2d-3fd5-285e-a6ac-5dcfaf9a98f6.share.connect.posit.cloud]

You can run this app locally following the instructions below.

1. Clone this repository:

    ```bash
    git clone https://github.com/mailysg8/Walmonitor-ia.git
    ```

2. Navigate to the project directory locally:

    ```bash
    cd Walmonitor-ia
    ```

3. Open the project in RStudio and install the required packages by running the following in the RStudio Console :

    ```r
    install.packages(c("shiny","bslib","dplyr","plotly","ggplot2","stringr"))
    ```

4. Run the app by running the following command in the Console:

    ```bash
    shiny::runApp('mds/532/Walmonitor-ia/src')
    ```

5. The app will open automatically in a new window. Alternatively, check the Console for the local URL (e.g. `http://127.0.0.1:6487`) and open it in your browser.

